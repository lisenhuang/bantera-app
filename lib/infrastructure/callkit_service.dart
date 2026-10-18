import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'push_notifications_service.dart';

class CallKitService {
  CallKitService._({bool? supportedOverride})
    : _supportedOverride = supportedOverride,
      _available = supportedOverride ?? false {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'event' && call.arguments is Map) {
        final event = Map<String, dynamic>.from(call.arguments as Map);
        if (event['event'] == 'availabilityChanged') {
          _available = event['available'] == true;
          tokenChanges.value++;
        }
        if (event['event'] == 'token' || event['event'] == 'tokenInvalidated') {
          tokenChanges.value++;
        }
        _events.add(event);
      }
    });
  }
  @visibleForTesting
  CallKitService.forTesting() : this._(supportedOverride: true);

  final bool? _supportedOverride;
  bool _available;
  Future<void>? _refreshing;
  static final instance = CallKitService._();
  static const _channel = MethodChannel('bantera/callkit');
  final _events = StreamController<Map<String, dynamic>>.broadcast(sync: true);
  final tokenChanges = ValueNotifier<int>(0);
  Stream<Map<String, dynamic>> get events => _events.stream;
  String? deviceId;
  bool get _hasNativeBridge => _supportedOverride ?? Platform.isIOS;
  bool get supported => _hasNativeBridge && _available;

  Future<void> initialize(String? userId) async {
    if (!_hasNativeBridge) return;
    final response = await _channel.invokeMapMethod<String, dynamic>('ready', {
      'userId': userId,
    });
    deviceId = response?['deviceId'] as String?;
    _available = response?['available'] as bool? ?? _available;
    tokenChanges.value++;
  }

  Future<void> setUser(String? userId) async {
    if (_hasNativeBridge) {
      await _channel.invokeMethod<void>('setUser', {'userId': userId});
    }
  }

  Future<PushNotificationToken?> token() async {
    if (!_hasNativeBridge) return null;
    final response = await _channel.invokeMapMethod<Object?, Object?>('token');
    if (response == null) return null;
    _available = response['available'] as bool? ?? _available;
    if (!supported) return null;
    final token = PushNotificationToken.fromMap(response);
    return token.token.isEmpty ? null : token;
  }

  Future<bool> report(String method, Map<String, Object?> payload) async {
    await refreshAvailability();
    if (!supported) return true;
    return await _channel.invokeMethod<bool>(method, payload) ?? false;
  }

  Future<void> update(String method, String? callId) async {
    if (supported && callId != null) {
      await _channel.invokeMethod<void>(method, {'callId': callId});
    }
  }

  Future<void> refreshAvailability() async {
    if (!_hasNativeBridge || _supportedOverride != null) return;
    if (_refreshing != null) return _refreshing;
    final task = token().then((_) {});
    _refreshing = task;
    try {
      await task;
    } finally {
      _refreshing = null;
    }
  }

  Future<List<String>> revokedTokens() async {
    if (!_hasNativeBridge) return [];
    return (await _channel.invokeListMethod<String>('revokedTokens')) ?? [];
  }

  Future<void> acknowledgeRevokedToken(String token) async {
    if (!_hasNativeBridge) return;
    await _channel.invokeMethod<void>('ackRevokedToken', {'token': token});
  }
}
