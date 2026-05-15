import 'dart:async';

import 'package:app/infrastructure/auth_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requestRefresh deduplicates concurrent refresh callbacks', () async {
    var calls = 0;
    final releaseRefresh = Completer<void>();

    AuthApiClient.instance.setTokenRefresher(() async {
      calls += 1;
      await releaseRefresh.future;
      return 'token-$calls';
    });

    final first = AuthApiClient.instance.requestRefresh();
    final second = AuthApiClient.instance.requestRefresh();

    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);

    releaseRefresh.complete();
    expect(await first, 'token-1');
    expect(await second, 'token-1');

    AuthApiClient.instance.setTokenRefresher(() async => null);
  });
}
