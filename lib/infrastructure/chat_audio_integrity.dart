import 'dart:io';
import 'package:crypto/crypto.dart';
import 'auth_api_client.dart';

/// A receipt is safe only after the bytes and the durable saved file both match.
class ChatAudioIntegrity {
  static Future<void> confirmSaved({
    required File file,
    required Future<bool> Function() isCommitted,
    required Future<void> Function() acknowledge,
    int? expectedBytes,
    String? expectedSha256,
  }) async {
    if (!await isCommitted()) {
      throw StateError('Chat audio was not committed locally.');
    }
    await verifyFile(
      file,
      expectedBytes: expectedBytes,
      expectedSha256: expectedSha256,
    );
    await acknowledge();
  }

  static void verifyBytes(
    List<int> bytes, {
    int? expectedBytes,
    String? expectedSha256,
  }) {
    if (bytes.isEmpty ||
        (expectedBytes != null && bytes.length != expectedBytes) ||
        (expectedSha256 != null &&
            sha256.convert(bytes).toString() != expectedSha256.toLowerCase())) {
      throw const AuthApiException(
        code: 'chat_download_incomplete',
        message:
            'Could not download this voice message completely. Please try again.',
      );
    }
  }

  static Future<void> verifyFile(
    File file, {
    int? expectedBytes,
    String? expectedSha256,
  }) async {
    final size = await file.length();
    if (size <= 0 ||
        expectedBytes != null && size != expectedBytes ||
        expectedSha256 != null &&
            (await sha256.bind(file.openRead()).first).toString() !=
                expectedSha256.toLowerCase()) {
      throw const AuthApiException(
        code: 'chat_download_incomplete',
        message:
            'Could not save this voice message completely. Please try again.',
      );
    }
  }
}
