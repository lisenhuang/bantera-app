import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'auth_session_notifier.dart';

class VoiceConversationRequest {
  VoiceConversationRequest(this.owner, this.requestedAt);

  final String owner;
  final DateTime requestedAt;

  // A delayed launch or a change of account must never open the microphone later.
  bool isCurrent(String? currentOwner) =>
      currentOwner == owner &&
      DateTime.now().difference(requestedAt) < const Duration(minutes: 1);
}

class VoiceConversationShortcut {
  static final pending = ValueNotifier<VoiceConversationRequest?>(null);

  static void initialize() {
    if (!Platform.isIOS) return;
    const EventChannel(
      'bantera/voice_shortcut',
    ).receiveBroadcastStream().listen(
      (event) {
        final owner = AuthSessionNotifier.instance.session?.cacheKey;
        if (event is int && owner != null) {
          pending.value = VoiceConversationRequest(
            owner,
            DateTime.fromMillisecondsSinceEpoch(event),
          );
        }
      },
      onError: (Object error) =>
          debugPrint('Voice shortcut unavailable: ${error.runtimeType}'),
    );
  }
}
