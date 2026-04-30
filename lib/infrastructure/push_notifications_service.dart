import 'dart:io';

import 'package:flutter/services.dart';

class PushNotificationToken {
  const PushNotificationToken({required this.token, required this.isSandbox});

  factory PushNotificationToken.fromMap(Map<Object?, Object?> map) {
    return PushNotificationToken(
      token: map['token']?.toString() ?? '',
      isSandbox: map['isSandbox'] == true,
    );
  }

  final String token;
  final bool isSandbox;
}

class PushNotificationsService {
  PushNotificationsService._();

  static final PushNotificationsService instance = PushNotificationsService._();
  static const MethodChannel _channel = MethodChannel(
    'bantera/push_notifications',
  );

  Future<PushNotificationToken?> getCachedToken() async {
    if (!Platform.isIOS) {
      return null;
    }

    final response = await _channel.invokeMapMethod<Object?, Object?>(
      'getCachedPushToken',
    );
    if (response == null) {
      return null;
    }
    final token = PushNotificationToken.fromMap(response);
    return token.token.trim().isEmpty ? null : token;
  }

  Future<PushNotificationToken?> requestAuthorizationAndRegister() async {
    if (!Platform.isIOS) {
      return null;
    }

    final response = await _channel.invokeMapMethod<Object?, Object?>(
      'requestAuthorizationAndRegister',
    );
    if (response == null) {
      return null;
    }
    final token = PushNotificationToken.fromMap(response);
    return token.token.trim().isEmpty ? null : token;
  }
}
