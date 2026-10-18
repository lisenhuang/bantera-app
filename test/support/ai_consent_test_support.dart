import 'dart:io';
import 'package:app/core/ai_consent.dart';
import 'package:flutter_test/flutter_test.dart';

/// Existing HTTP contract tests use a local server and synthetic tokens. Give
/// them explicit stored permission without changing the production default.
Future<Future<void> Function(String)> approvedAiConsentForTest() async {
  final directory = await Directory.systemTemp.createTemp(
    'bantera-approved-ai',
  );
  final consent = AiConsent(
    currentOwner: () => 'test',
    directory: () async => directory,
  )..present = () async => true;
  expect(await consent.request(), true);
  addTearDown(() async {
    consent.dispose();
    await directory.delete(recursive: true);
  });
  return (_) => consent.require('test');
}
