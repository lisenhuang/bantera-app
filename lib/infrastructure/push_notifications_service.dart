import 'dart:io';

import 'package:flutter/foundation.dart';
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
  PushNotificationsService._() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static final PushNotificationsService instance = PushNotificationsService._();
  static const MethodChannel _channel = MethodChannel(
    'bantera/push_notifications',
  );
  final ValueNotifier<Map<String, String>?> latestNotificationTap =
      ValueNotifier<Map<String, String>?>(null);

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

  Future<PushNotificationToken?> registerIfAuthorized() async {
    if (!Platform.isIOS) {
      return null;
    }

    final response = await _channel.invokeMapMethod<Object?, Object?>(
      'registerIfAuthorized',
    );
    if (response == null) {
      return null;
    }
    final token = PushNotificationToken.fromMap(response);
    return token.token.trim().isEmpty ? null : token;
  }

  Future<Map<String, String>?> takeInitialNotificationTap() async {
    if (!Platform.isIOS) {
      return null;
    }

    final response = await _channel.invokeMapMethod<Object?, Object?>(
      'takeInitialNotification',
    );
    if (response == null) {
      return null;
    }
    return response.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
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

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method != 'notificationTapped') {
      return null;
    }

    final arguments = call.arguments;
    if (arguments is! Map) {
      return null;
    }
    latestNotificationTap.value = arguments.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
    return null;
  }
}
