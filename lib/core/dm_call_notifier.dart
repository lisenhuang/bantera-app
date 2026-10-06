import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/models/chat_models.dart';
import '../infrastructure/auth_api_client.dart';
import '../infrastructure/chat_api_client.dart';
import '../infrastructure/callkit_service.dart';
import '../infrastructure/push_notifications_service.dart';
import 'auth_session_notifier.dart';
import 'ai_callback_notifier.dart';
import 'chat_session_notifier.dart';

enum DmCallMediaKind { audio, video }

enum DmCallPhase { idle, outgoing, incoming, connecting, connected, error }

enum DmCallErrorCode {
  microphoneDenied,
  microphoneSettings,
  cameraDenied,
  cameraSettings,
  busy,
  unavailable,
  networkRestricted,
  failed,
}

class DmCallNotifier extends ChangeNotifier {
  DmCallNotifier._() {
    AuthSessionNotifier.instance.addListener(_handleAuthChanged);
    ChatSessionNotifier.instance.realtimeEvents.listen((event) {
      final generation = _generation;
      unawaited(
        _handleRealtimeEvent(event).catchError((Object error) async {
          if (generation == _generation && isActive) {
            await _failActiveCall(DmCallErrorCode.failed);
          }
        }),
      );
    });
    PushNotificationsService.instance.latestNotificationTap.addListener(
      _handleLatestNotificationTap,
    );
    CallKitService.instance.events.listen((event) {
      unawaited(_handleCallKitEvent(event));
    });
    unawaited(
      CallKitService.instance.initialize(
        AuthSessionNotifier.instance.session?.userId,
      ),
    );
    unawaited(_loadInitialNotificationTap());
    unawaited(_ensureRenderersReady());
  }

  static final DmCallNotifier instance = DmCallNotifier._();

  final ChatApiClient _apiClient = ChatApiClient.instance;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  Timer? _callTimer;
  Timer? _connectTimer;
  Timer? _incomingStatusTimer;
  bool _checkingIncoming = false;
  bool _accepting = false;
  int _generation = 0;
  Future<void>? _resetting;
  final List<RTCIceCandidate> _pendingIce = [];
  bool _remoteDescriptionReady = false;
  Completer<void>? _acceptConfirmation;

  DmCallPhase _phase = DmCallPhase.idle;
  DmCallMediaKind? _mediaKind;
  ChatUserSummary? _peerUser;
  String? _callId;
  bool _isIncoming = false;
  bool _isMuted = false;
  bool _isSpeakerEnabled = true;
  bool _isCameraEnabled = true;
  bool _renderersReady = false;
  Duration _connectedDuration = Duration.zero;
  DateTime? _connectedAt;
  DmCallErrorCode? _errorCode;
  Map<String, String>? _pendingNotificationPayload;

  DmCallPhase get phase => _phase;
  DmCallMediaKind? get mediaKind => _mediaKind;
  ChatUserSummary? get peerUser => _peerUser;
  bool get isIncoming => _isIncoming;
  bool get isMuted => _isMuted;
  bool get isSpeakerEnabled => _isSpeakerEnabled;
  bool get isCameraEnabled => _isCameraEnabled;
  bool get hasVideo => _mediaKind == DmCallMediaKind.video;
  bool get isActive => _phase != DmCallPhase.idle;
  Duration get connectedDuration => _connectedDuration;
  DmCallErrorCode? get errorCode => _errorCode;

  bool get shouldShowSettingsAction =>
      _errorCode == DmCallErrorCode.microphoneSettings ||
      _errorCode == DmCallErrorCode.cameraSettings;

  Future<void> startOutgoingCall({
    required ChatUserSummary recipient,
    required DmCallMediaKind mediaKind,
  }) async {
    if (_phase != DmCallPhase.idle) {
      return;
    }

    final generation = _generation;
    if (!await _ensurePermissions(mediaKind)) {
      notifyListeners();
      return;
    }

    if (_generation != generation || _phase != DmCallPhase.idle) return;
    _phase = DmCallPhase.outgoing;
    _mediaKind = mediaKind;
    _peerUser = recipient;
    _isIncoming = false;
    _errorCode = null;
    _callId = null;
    _connectedDuration = Duration.zero;
    notifyListeners();

    await ChatSessionNotifier.instance.ensureRealtimeConnected();
    if (_generation != generation || _phase != DmCallPhase.outgoing) return;
    final sent = await ChatSessionNotifier.instance.sendRealtimeEvent(
      'call.invite',
      <String, Object?>{
        'recipientUserId': recipient.id,
        'mediaKind': mediaKind.name,
      },
    );
    if (!sent) {
      await _setError(DmCallErrorCode.unavailable);
    }
  }

  Future<void> acceptIncomingCall({bool fromSystem = false}) async {
    if (_phase != DmCallPhase.incoming ||
        _callId == null ||
        _mediaKind == null) {
      return;
    }

    if (CallKitService.instance.supported && !fromSystem) {
      await CallKitService.instance.report('requestAnswer', {
        'callId': _callId,
      });
      return;
    }
    if (_accepting) return;
    _accepting = true;
    final acceptingId = _callId;
    if (!await _ensurePermissions(_mediaKind!)) {
      _accepting = false;
      await _sendRejectAndReset();
      notifyListeners();
      return;
    }

    try {
      if (_callId != acceptingId) return;
      await ChatSessionNotifier.instance.ensureRealtimeConnected();
      if (_callId != acceptingId) return;
      await _createLocalMedia();
      await _ensurePeerConnection();
      if (_callId != acceptingId) return;
      _phase = DmCallPhase.connecting;
      _startConnectTimeout();
      notifyListeners();
      _acceptConfirmation = Completer<void>();
      await ChatSessionNotifier.instance.ensureRealtimeConnected();
      final sent = await ChatSessionNotifier.instance.sendRealtimeEvent(
        'call.accept',
        <String, Object?>{
          'callId': _callId,
          'deviceId': CallKitService.instance.deviceId,
        },
      );
      if (!sent) {
        await _setError(DmCallErrorCode.unavailable);
      } else if (CallKitService.instance.supported) {
        await _acceptConfirmation!.future.timeout(const Duration(seconds: 10));
        if (_callId == acceptingId) {
          await CallKitService.instance.update('answerReady', acceptingId);
        }
      }
    } catch (_) {
      if (_callId == acceptingId) {
        await _sendEndIfNeeded();
        await _setError(DmCallErrorCode.failed);
      }
    } finally {
      _accepting = false;
    }
  }

  Future<void> declineIncomingCall() async {
    await _sendRejectAndReset();
  }

  Future<void> endCurrentCall() async {
    final ending = _sendEndIfNeeded();
    await _resetState();
    await ending;
  }

  Future<void> toggleMute() async {
    final stream = _localStream;
    if (stream == null) {
      return;
    }

    _isMuted = !_isMuted;
    for (final track in stream.getAudioTracks()) {
      track.enabled = !_isMuted;
    }
    notifyListeners();
    await _sendMediaUpdate();
  }

  Future<void> toggleSpeaker() async {
    _isSpeakerEnabled = !_isSpeakerEnabled;
    await Helper.setSpeakerphoneOn(_isSpeakerEnabled);
    notifyListeners();
  }

  Future<void> toggleCamera() async {
    if (!hasVideo || _localStream == null) {
      return;
    }

    _isCameraEnabled = !_isCameraEnabled;
    for (final track in _localStream!.getVideoTracks()) {
      track.enabled = _isCameraEnabled;
    }
    notifyListeners();
    await _sendMediaUpdate();
  }

  Future<void> switchCamera() async {
    final tracks = _localStream?.getVideoTracks() ?? const <MediaStreamTrack>[];
    if (!hasVideo || tracks.isEmpty) {
      return;
    }

    await Helper.switchCamera(tracks.first);
  }

  Future<void> dismissError() async {
    if (_phase == DmCallPhase.error) {
      await _resetState();
    }
  }

  Future<T> _withRetry<T>(Future<T> Function(String accessToken) action) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null) {
      throw const SessionExpiredException();
    }

    try {
      return await action(session.accessToken);
    } on AuthApiException catch (error) {
      if (error.code != 'token_expired') {
        rethrow;
      }

      final refreshed = await AuthSessionNotifier.instance
          .refreshAccessTokenForApi();
      if (refreshed == null) {
        throw const SessionExpiredException();
      }
      return action(refreshed);
    }
  }

  Future<void> _loadInitialNotificationTap() async {
    final payload = await PushNotificationsService.instance
        .takeInitialNotificationTap();
    if (payload != null) {
      await _handleNotificationTap(payload);
    }
  }

  void _handleLatestNotificationTap() {
    final payload =
        PushNotificationsService.instance.latestNotificationTap.value;
    if (payload != null) {
      unawaited(_handleNotificationTap(payload));
    }
  }

  Future<void> _handleNotificationTap(
    Map<String, String> payload, {
    bool fromSystem = false,
  }) async {
    if (payload['callerUserId'] == AiCallbackNotifier.identity) {
      await AiCallbackNotifier.instance.incoming(payload, system: fromSystem);
      return;
    }
    if (payload['type'] != 'incoming_call') {
      return;
    }
    if (!AuthSessionNotifier.instance.isAuthenticated) {
      _pendingNotificationPayload = payload;
      return;
    }
    if (_phase != DmCallPhase.idle) {
      return;
    }

    final callId = payload['callId'];
    final callerUserId = payload['callerUserId'];
    if (callId == null ||
        callId.isEmpty ||
        callerUserId == null ||
        callerUserId.isEmpty) {
      return;
    }

    _callId = callId;
    _mediaKind = payload['mediaKind'] == DmCallMediaKind.video.name
        ? DmCallMediaKind.video
        : DmCallMediaKind.audio;
    _peerUser = ChatUserSummary(
      id: callerUserId,
      name: (payload['callerName']?.trim().isNotEmpty ?? false)
          ? payload['callerName']!.trim()
          : 'Bantera user',
      avatarUrl: (payload['callerAvatarUrl']?.trim().isNotEmpty ?? false)
          ? payload['callerAvatarUrl']!.trim()
          : null,
      learningLanguage: null,
      learningLanguageDisplay: null,
      nativeLanguage: null,
      nativeLanguageDisplay: null,
      isOnline: true,
    );
    _phase = DmCallPhase.incoming;
    _isIncoming = true;
    _errorCode = null;
    notifyListeners();
    if (!fromSystem) await CallKitService.instance.report('incoming', payload);
    _watchIncomingStatus();
  }

  Future<void> _handleCallKitEvent(Map<String, dynamic> event) async {
    if (AiCallbackNotifier.instance.handles(event)) return;
    final id = event['callId']?.toString().toLowerCase();
    try {
      switch (event['event']) {
        case 'incoming':
          await _handleNotificationTap({
            ...event.map((key, value) => MapEntry(key, value.toString())),
            'type': 'incoming_call',
          }, fromSystem: true);
          await ChatSessionNotifier.instance.ensureRealtimeConnected();
          await _checkIncomingStatus();
        case 'answer':
          if (_callId == id) {
            await acceptIncomingCall(fromSystem: true);
          } else {
            await CallKitService.instance.update('end', id);
          }
        case 'ended':
          if (_callId == id) {
            if (_phase == DmCallPhase.incoming) {
              await declineIncomingCall();
            } else {
              await endCurrentCall();
            }
          }
        case 'mute':
          if (_callId == id && _isMuted != (event['muted'] == true)) {
            await toggleMute();
          }
      }
    } catch (_) {
      if (id != null && _callId == id) await _resetState();
      await CallKitService.instance.update('end', id);
    }
  }

  void _watchIncomingStatus() {
    _incomingStatusTimer?.cancel();
    if (!CallKitService.instance.supported) return;
    _incomingStatusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_checkIncomingStatus());
    });
  }

  Future<void> _checkIncomingStatus() async {
    final id = _callId;
    if (id == null ||
        _phase != DmCallPhase.incoming ||
        _accepting ||
        _checkingIncoming) {
      return;
    }
    _checkingIncoming = true;
    try {
      final state = await _withRetry(
        (token) => _apiClient.callState(token, id),
      ).timeout(const Duration(seconds: 5));
      if (_callId == id &&
          _phase == DmCallPhase.incoming &&
          !_accepting &&
          state != 'pending') {
        await _resetState();
      }
    } on AuthApiException catch (error) {
      if (error.statusCode == 404 && _callId == id && !_accepting) {
        await _resetState();
      }
    } catch (_) {
      /* Native expiry timer bounds ringing when the network is unavailable. */
    } finally {
      _checkingIncoming = false;
    }
  }

  void _handleAuthChanged() {
    unawaited(
      CallKitService.instance.setUser(
        AuthSessionNotifier.instance.session?.userId,
      ),
    );
    if (!AuthSessionNotifier.instance.isAuthenticated && isActive) {
      unawaited(_resetState());
    }
    if (!AuthSessionNotifier.instance.isAuthenticated ||
        _pendingNotificationPayload == null) {
      return;
    }
    final payload = _pendingNotificationPayload!;
    _pendingNotificationPayload = null;
    unawaited(_handleNotificationTap(payload));
  }

  Future<void> _handleRealtimeEvent(Map<String, dynamic> event) async {
    final type = event['type']?.toString() ?? '';
    final payload = event['payload'];
    if (payload is! Map) {
      return;
    }

    final map = payload.map((key, value) => MapEntry(key.toString(), value));
    switch (type) {
      case 'call.outgoing.created':
        if (_phase != DmCallPhase.outgoing) {
          await ChatSessionNotifier.instance.sendRealtimeEvent('call.cancel', {
            'callId': map['callId'],
          });
          return;
        }
        _callId = map['callId']?.toString();
        final reported = await CallKitService.instance.report('outgoing', {
          'callId': _callId,
          'callerName': _peerUser?.name,
          'mediaKind': _mediaKind?.name,
        });
        if (!reported) await endCurrentCall();
        notifyListeners();
        return;
      case 'call.incoming':
        if (_callId == map['callId']?.toString()) return;
        if (_phase != DmCallPhase.idle) {
          final callId = map['callId']?.toString();
          if (callId != null) {
            await ChatSessionNotifier.instance.sendRealtimeEvent(
              'call.reject',
              <String, Object?>{'callId': callId, 'reason': 'busy'},
            );
          }
          return;
        }
        final callerJson = map['caller'];
        if (callerJson is! Map) {
          return;
        }
        _callId = map['callId']?.toString();
        _mediaKind = map['mediaKind']?.toString() == DmCallMediaKind.video.name
            ? DmCallMediaKind.video
            : DmCallMediaKind.audio;
        _peerUser = ChatUserSummary.fromJson(
          callerJson.map((key, value) => MapEntry(key.toString(), value)),
        );
        _phase = DmCallPhase.incoming;
        _isIncoming = true;
        _errorCode = null;
        notifyListeners();
        final incomingId = _callId;
        final reported = await CallKitService.instance.report('incoming', {
          'callId': incomingId,
          'callerUserId': _peerUser?.id,
          'callerName': _peerUser?.name,
          'mediaKind': _mediaKind?.name,
        });
        if (!reported && _callId == incomingId) await declineIncomingCall();
        _watchIncomingStatus();
        return;
      case 'call.accepted.self':
        if (_callId == map['callId']?.toString()) {
          if (map['deviceId'] != CallKitService.instance.deviceId) {
            await _resetState();
          } else {
            final confirmation = _acceptConfirmation;
            if (confirmation != null && !confirmation.isCompleted) {
              confirmation.complete();
            }
          }
        }
        return;
      case 'call.accepted':
        if (_phase != DmCallPhase.outgoing ||
            _callId != map['callId']?.toString()) {
          return;
        }
        final acceptedId = _callId;
        try {
          _phase = DmCallPhase.connecting;
          _startConnectTimeout();
          notifyListeners();
          await _createLocalMedia();
          await _ensurePeerConnection();
          await _createAndSendOffer();
        } catch (_) {
          if (_callId == acceptedId) {
            await _sendEndIfNeeded();
            await _setError(DmCallErrorCode.failed);
          }
        }
        return;
      case 'call.rejected':
        if (_callId == map['callId']?.toString()) {
          await _setError(DmCallErrorCode.unavailable);
        }
        return;
      case 'call.busy':
        if (_phase == DmCallPhase.outgoing) {
          await _setError(DmCallErrorCode.busy);
        }
        return;
      case 'call.unavailable':
        if (_phase == DmCallPhase.outgoing ||
            _callId == map['callId']?.toString()) {
          await _setError(DmCallErrorCode.unavailable);
        }
        return;
      case 'call.cancelled':
      case 'call.missed':
        if (_callId == map['callId']?.toString()) {
          await _setError(DmCallErrorCode.unavailable);
        }
        return;
      case 'call.ended':
        if (_callId == map['callId']?.toString()) {
          await _resetState();
        }
        return;
      case 'call.signal.offer':
        if (_callId == map['callId']?.toString()) {
          await _handleOffer(map);
        }
        return;
      case 'call.signal.answer':
        if (_callId == map['callId']?.toString()) {
          await _handleAnswer(map);
        }
        return;
      case 'call.signal.ice':
        if (_callId == map['callId']?.toString()) {
          await _handleIceCandidate(map);
        }
        return;
      case 'call.media.update':
        return;
    }
  }

  Future<bool> _ensurePermissions(DmCallMediaKind mediaKind) async {
    var microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      microphoneStatus = await Permission.microphone.request();
    }
    if (!microphoneStatus.isGranted) {
      _errorCode =
          microphoneStatus.isPermanentlyDenied || microphoneStatus.isRestricted
          ? DmCallErrorCode.microphoneSettings
          : DmCallErrorCode.microphoneDenied;
      _phase = DmCallPhase.error;
      return false;
    }

    if (mediaKind == DmCallMediaKind.video) {
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }
      if (!cameraStatus.isGranted) {
        _errorCode =
            cameraStatus.isPermanentlyDenied || cameraStatus.isRestricted
            ? DmCallErrorCode.cameraSettings
            : DmCallErrorCode.cameraDenied;
        _phase = DmCallPhase.error;
        return false;
      }
    }

    return true;
  }

  Future<void> _createLocalMedia() async {
    if (_localStream != null || _mediaKind == null) {
      return;
    }

    final generation = _generation;
    final mediaKind = _mediaKind;
    await _ensureRenderersReady();
    if (generation != _generation) throw StateError('Call ended');
    final stream = await navigator.mediaDevices.getUserMedia(<String, dynamic>{
      'audio': true,
      'video': mediaKind == DmCallMediaKind.video
          ? <String, dynamic>{
              'facingMode': 'user',
              'width': 960,
              'height': 1280,
              'frameRate': 24,
            }
          : false,
    });
    if (generation != _generation) {
      for (final track in stream.getTracks()) {
        await track.stop();
      }
      await stream.dispose();
      throw StateError('Call ended');
    }
    _localStream = stream;
    localRenderer.srcObject = stream;
    _isMuted = false;
    _isCameraEnabled = _mediaKind == DmCallMediaKind.video;
    await Helper.setSpeakerphoneOn(_isSpeakerEnabled);
  }

  Future<void> _ensurePeerConnection() async {
    if (_peerConnection != null) {
      return;
    }

    final generation = _generation;
    final iceConfig = await _withRetry(
      (accessToken) => _apiClient.fetchIceServers(accessToken: accessToken),
    );
    if (generation != _generation) throw StateError('Call ended');
    final configuration = iceConfig.toPeerConnectionConfiguration();

    final peerConnection = await createPeerConnection(configuration);
    if (generation != _generation) {
      await peerConnection.close();
      throw StateError('Call ended');
    }
    _peerConnection = peerConnection;

    final localStream = _localStream;
    if (localStream != null) {
      for (final track in localStream.getTracks()) {
        await peerConnection.addTrack(track, localStream);
      }
    }

    if (generation != _generation) throw StateError('Call ended');
    peerConnection.onTrack = (RTCTrackEvent event) {
      if (_peerConnection != peerConnection || event.streams.isEmpty) {
        return;
      }
      _remoteStream = event.streams.first;
      remoteRenderer.srcObject = _remoteStream;
      notifyListeners();
    };
    peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      if (_peerConnection != peerConnection ||
          _callId == null ||
          candidate.candidate == null) {
        return;
      }
      unawaited(
        ChatSessionNotifier.instance
            .sendRealtimeEvent('call.signal.ice', <String, Object?>{
              'callId': _callId,
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            }),
      );
    };
    peerConnection.onConnectionState = (RTCPeerConnectionState state) {
      if (_peerConnection != peerConnection || !isActive) return;
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _markConnected();
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        unawaited(_failActiveCall(DmCallErrorCode.networkRestricted));
      }
    };
  }

  Future<void> _createAndSendOffer() async {
    final peerConnection = _peerConnection;
    final currentCallId = _callId;
    if (peerConnection == null || currentCallId == null) {
      return;
    }

    final offer = await peerConnection.createOffer(<String, dynamic>{
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': hasVideo,
    });
    await peerConnection.setLocalDescription(offer);
    await ChatSessionNotifier.instance.sendRealtimeEvent(
      'call.signal.offer',
      <String, Object?>{'callId': currentCallId, 'sdp': offer.sdp},
    );
  }

  Future<void> _handleOffer(Map<String, dynamic> payload) async {
    final peerConnection = _peerConnection;
    final currentCallId = _callId;
    final sdp = payload['sdp']?.toString();
    if (peerConnection == null ||
        currentCallId == null ||
        sdp == null ||
        sdp.trim().isEmpty) {
      return;
    }

    await peerConnection.setRemoteDescription(
      RTCSessionDescription(sdp, 'offer'),
    );
    await _flushIceCandidates(peerConnection);
    final answer = await peerConnection.createAnswer(<String, dynamic>{
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': hasVideo,
    });
    await peerConnection.setLocalDescription(answer);
    await ChatSessionNotifier.instance.sendRealtimeEvent(
      'call.signal.answer',
      <String, Object?>{'callId': currentCallId, 'sdp': answer.sdp},
    );
  }

  Future<void> _handleAnswer(Map<String, dynamic> payload) async {
    final peerConnection = _peerConnection;
    final sdp = payload['sdp']?.toString();
    if (peerConnection == null || sdp == null || sdp.trim().isEmpty) {
      return;
    }

    await peerConnection.setRemoteDescription(
      RTCSessionDescription(sdp, 'answer'),
    );
    await _flushIceCandidates(peerConnection);
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> payload) async {
    final peerConnection = _peerConnection;
    final candidate = payload['candidate']?.toString();
    if (peerConnection == null ||
        candidate == null ||
        candidate.trim().isEmpty) {
      return;
    }

    final sdpMid = payload['sdpMid']?.toString();
    final sdpMLineIndex = (payload['sdpMLineIndex'] as num?)?.toInt();
    final ice = RTCIceCandidate(candidate, sdpMid, sdpMLineIndex);
    if (!_remoteDescriptionReady) {
      _pendingIce.add(ice);
      return;
    }
    await peerConnection.addCandidate(ice);
  }

  Future<void> _flushIceCandidates(RTCPeerConnection peer) async {
    if (peer != _peerConnection) return;
    _remoteDescriptionReady = true;
    final candidates = List<RTCIceCandidate>.from(_pendingIce);
    _pendingIce.clear();
    for (final ice in candidates) {
      if (peer == _peerConnection) await peer.addCandidate(ice);
    }
  }

  void _markConnected() {
    if (_phase == DmCallPhase.connected) {
      return;
    }
    _connectTimer?.cancel();
    _connectTimer = null;
    _phase = DmCallPhase.connected;
    _incomingStatusTimer?.cancel();
    unawaited(CallKitService.instance.update('connected', _callId));
    _connectedAt = DateTime.now();
    _connectedDuration = Duration.zero;
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final connectedAt = _connectedAt;
      if (connectedAt == null) {
        return;
      }
      _connectedDuration = DateTime.now().difference(connectedAt);
      notifyListeners();
    });
    notifyListeners();
  }

  void _startConnectTimeout() {
    _connectTimer?.cancel();
    _connectTimer = Timer(const Duration(seconds: 20), () {
      if (_phase == DmCallPhase.connecting) {
        unawaited(_failActiveCall(DmCallErrorCode.networkRestricted));
      }
    });
  }

  Future<void> _sendMediaUpdate() async {
    final currentCallId = _callId;
    if (currentCallId == null) {
      return;
    }

    await ChatSessionNotifier.instance
        .sendRealtimeEvent('call.media.update', <String, Object?>{
          'callId': currentCallId,
          'audioEnabled': !_isMuted,
          'videoEnabled': _isCameraEnabled,
        });
  }

  Future<void> _sendRejectAndReset() async {
    final id = _callId;
    final sending = id == null
        ? Future<void>.value()
        : _sendCallEnd('call.reject', id);
    await _resetState();
    await sending;
  }

  Future<void> _sendEndIfNeeded() async {
    final id = _callId;
    if (id == null) return;
    final type = _phase == DmCallPhase.outgoing ? 'call.cancel' : 'call.end';
    await _sendCallEnd(type, id);
  }

  Future<void> _sendCallEnd(String type, String id) async {
    try {
      await ChatSessionNotifier.instance.ensureRealtimeConnected().timeout(
        const Duration(seconds: 5),
      );
      await ChatSessionNotifier.instance.sendRealtimeEvent(type, {
        'callId': id,
      });
    } catch (_) {
      /* Local hang-up must always finish, even without signalling. */
    }
  }

  Future<void> _ensureRenderersReady() async {
    if (_renderersReady) {
      return;
    }
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    _renderersReady = true;
  }

  Future<void> _setError(DmCallErrorCode code) async {
    if (_resetting != null || _phase == DmCallPhase.idle) return;
    final generation = ++_generation;
    await CallKitService.instance.update('end', _callId);
    await _teardownMedia();
    if (generation != _generation) return;
    _phase = DmCallPhase.error;
    _errorCode = code;
    notifyListeners();
  }

  Future<void> _failActiveCall(DmCallErrorCode code) async {
    final ending = _sendEndIfNeeded();
    await _setError(code);
    await ending;
  }

  Future<void> _resetState() async {
    if (_resetting != null) return _resetting;
    final reset = _doResetState();
    _resetting = reset;
    try {
      await reset;
    } finally {
      _resetting = null;
    }
  }

  Future<void> _doResetState() async {
    _generation++;
    await CallKitService.instance.update('end', _callId);
    await _teardownMedia();
    _phase = DmCallPhase.idle;
    _mediaKind = null;
    _peerUser = null;
    _callId = null;
    _isIncoming = false;
    _isMuted = false;
    _isSpeakerEnabled = true;
    _isCameraEnabled = true;
    _connectedDuration = Duration.zero;
    _connectedAt = null;
    _errorCode = null;
    _accepting = false;
    final confirmation = _acceptConfirmation;
    if (confirmation != null && !confirmation.isCompleted) {
      confirmation.complete();
    }
    _acceptConfirmation = null;
    notifyListeners();
  }

  Future<void> _teardownMedia() async {
    _pendingIce.clear();
    _remoteDescriptionReady = false;
    _incomingStatusTimer?.cancel();
    _incomingStatusTimer = null;
    _callTimer?.cancel();
    _callTimer = null;
    _connectTimer?.cancel();
    _connectTimer = null;

    final peer = _peerConnection;
    final local = _localStream;
    final remote = _remoteStream;
    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    if (peer != null) {
      peer.onConnectionState = null;
      peer.onTrack = null;
      peer.onIceCandidate = null;
      try {
        await peer.close();
      } catch (_) {
        /* Already closed natively. */
      }
    }
    for (final stream in [local, remote]) {
      if (stream == null) continue;
      for (final track in stream.getTracks()) {
        try {
          await track.stop();
        } catch (_) {}
      }
      try {
        await stream.dispose();
      } catch (_) {}
    }
  }
}
