import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'auth_session_notifier.dart';

class VoiceConversationRequest {
  VoiceConversationRequest(this.owner, this.requestedAt);

  final String owner;
  final DateTime requestedAt;

  // A delayed launch or a change of account must never open the microphone later.
  static const lifetime = Duration(minutes: 1);

  bool isCurrent(String? currentOwner) {
    final age = DateTime.now().difference(requestedAt);
    return currentOwner == owner && !age.isNegative && age < lifetime;
  }
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
