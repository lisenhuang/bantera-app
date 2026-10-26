import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Short requests around a durable server job. A disconnect never means regenerate.
class AiOperationClient {
  AiOperationClient({
    required this.http,
    required this.baseUrl,
    required this.token,
    required this.ensureActive,
    this.pollInterval = const Duration(seconds: 3),
    this.budget = const Duration(minutes: 12),
    this.requestTimeout = const Duration(seconds: 15),
  });
  final HttpClient http;
  final Uri baseUrl;
  final Future<String> Function(bool refresh) token;
  final Future<void> Function() ensureActive;
  final Duration pollInterval, budget, requestTimeout;

  Future<Map<String, dynamic>> run(
    String path,
    Map<String, dynamic> body, {
    required String jobId,
    void Function(Map<String, dynamic>)? onProgress,
  }) async {
    final deadline = DateTime.now().add(budget);
    var accepted = false;
    var submissions = 0;
    var refresh = false;
    while (DateTime.now().isBefore(deadline)) {
      await ensureActive();
      if (!accepted && ++submissions > 3) {
        throw const AiOperationException(
          202,
          'Could not confirm generation. Please check again later.',
        );
      }
      try {
        final (status, data) = await _request(
          accepted ? 'GET' : 'POST',
          accepted ? '/api/me/ai-jobs/$jobId' : path,
          accepted ? null : body,
          jobId,
          refresh,
        );
        refresh = false;
        if (status == 401) {
          if (accepted) {
            await token(true);
            continue;
          }
          refresh = true;
        } else if (status == 202) {
          accepted = true;
        } else if (status == 200) {
          // Retain compatibility with servers that still return a complete JSON result.
          if (!accepted) return data;
          onProgress?.call(data);
          if (data['status'] == 'done') {
            await ensureActive();
            return Map<String, dynamic>.from(data['result'] as Map);
          }
          if (data['status'] == 'failed' || data['status'] == 'cancelled') {
            throw AiOperationException(
              (data['statusCode'] as num?)?.toInt() ?? 503,
              (data['result'] as Map?)?['message']?.toString() ??
                  'Generation could not finish. Please try again.',
            );
          }
        } else if (status == 404 && accepted) {
          throw const AiOperationException(
            404,
            'This generation is no longer available.',
          );
        } else if (status < 500 && status != 408) {
          throw AiOperationException(
            status,
            data['message']?.toString() ??
                'Could not start generation. Please try again.',
          );
        }
      } on SocketException {
        // Retry the same ID, including when acceptance was lost.
      } on HttpException {
        // Reconnect to the same job.
      } on TimeoutException {
        // A timed-out status request does not cancel generation.
      } on FormatException {
        // A temporary non-JSON proxy response can be retried with the same ID.
      }
      await Future<void>.delayed(pollInterval);
    }
    throw const AiOperationException(
      202,
      'Still generating. Return later to check the result.',
    );
  }

  Future<(int, Map<String, dynamic>)> _request(
    String method,
    String path,
    Map<String, dynamic>? body,
    String id,
    bool refresh,
  ) async {
    final access = await token(refresh);
    await ensureActive();
    final request = await http
        .openUrl(method, baseUrl.resolve(path))
        .timeout(requestTimeout);
    try {
      await ensureActive();
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $access');
      request.headers.set('Prefer', 'respond-async');
      request.headers.set('Idempotency-Key', id);
      request.headers.contentType = ContentType.json;
      if (body != null) request.write(jsonEncode(body));
      final response = await request.close().timeout(requestTimeout);
      final text = await response
          .transform(utf8.decoder)
          .join()
          .timeout(requestTimeout);
      await ensureActive();
      return (
        response.statusCode,
        text.isEmpty
            ? <String, dynamic>{}
            : Map<String, dynamic>.from(jsonDecode(text) as Map),
      );
    } catch (_) {
      request.abort();
      rethrow;
    }
  }
}

class AiOperationException implements Exception {
  const AiOperationException(this.status, this.message);
  final int status;
  final String message;
  @override
  String toString() => message;
}
