import 'package:app/infrastructure/callkit_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('bantera/callkit');
  final binding =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  test(
    'China disables native calls but preserves in-app calling and cleanup',
    () async {
      final service = CallKitService.forTesting();
      final calls = <MethodCall>[];
      binding.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        if (call.method == 'ready' || call.method == 'token') {
          return {
            'available': false,
            'token': 'must-not-leak',
            'deviceId': 'device-id',
          };
        }
        if (call.method == 'revokedTokens') return ['old-token'];
        return null;
      });
      await service.initialize('user-id');
      expect(service.supported, isFalse);
      expect(service.deviceId, 'device-id');
      expect(await service.token(), isNull);
      expect(await service.report('incoming', {'callId': 'incoming'}), isTrue);
      expect(await service.report('outgoing', {'callId': 'outgoing'}), isTrue);
      await service.update('end', 'incoming');
      await service.setUser(null);
      expect(await service.revokedTokens(), ['old-token']);
      await service.acknowledgeRevokedToken('old-token');
      expect(calls.map((c) => c.method), [
        'ready',
        'token',
        'setUser',
        'revokedTokens',
        'ackRevokedToken',
      ]);
      binding.setMockMethodCallHandler(channel, null);
    },
  );

  test(
    'native regional availability changes update system-call support',
    () async {
      final service = CallKitService.forTesting();
      for (final available in [false, true, false]) {
        final previous = service.tokenChanges.value;
        await binding.handlePlatformMessage(
          channel.name,
          const StandardMethodCodec().encodeMethodCall(
            MethodCall('event', {
              'event': 'availabilityChanged',
              'available': available,
            }),
          ),
          (_) {},
        );
        expect(service.supported, available);
        expect(service.tokenChanges.value, previous + 1);
      }
      binding.setMockMethodCallHandler(channel, null);
    },
  );

  test(
    'cold-start handshake preserves queued call events and device identity',
    () async {
      final service = CallKitService.forTesting();
      final events = <Map<String, dynamic>>[];
      final subscription = service.events.listen(events.add);
      binding.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'ready') {
          expect(call.arguments, {'userId': 'user-id'});
          await binding.handlePlatformMessage(
            channel.name,
            const StandardMethodCodec().encodeMethodCall(
              const MethodCall('event', {
                'event': 'incoming',
                'callId': 'call-id',
                'mediaKind': 'audio',
              }),
            ),
            (_) {},
          );
          return {
            'deviceId': 'device-id',
            'token': 'voip-token',
            'isSandbox': true,
          };
        }
        if (call.method == 'token') {
          return {'token': 'voip-token', 'isSandbox': true};
        }
        return null;
      });
      await service.initialize('user-id');
      expect(service.deviceId, 'device-id');
      expect(events.single['callId'], 'call-id');
      final token = await service.token();
      expect(token!.token, 'voip-token');
      expect(token.isSandbox, isTrue);
      await subscription.cancel();
      binding.setMockMethodCallHandler(channel, null);
    },
  );

  test(
    'answer is requested separately from backend acceptance and end',
    () async {
      final service = CallKitService.forTesting();
      final calls = <MethodCall>[];
      binding.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return call.method == 'requestAnswer' ? true : null;
      });
      expect(
        await service.report('requestAnswer', {'callId': 'call-id'}),
        isTrue,
      );
      expect(calls.map((c) => c.method), ['requestAnswer']);
      await service.update('answerReady', 'call-id');
      await service.update('end', 'call-id');
      expect(calls.map((c) => c.method), [
        'requestAnswer',
        'answerReady',
        'end',
      ]);
      expect(
        calls.every((c) => (c.arguments as Map)['callId'] == 'call-id'),
        isTrue,
      );
      binding.setMockMethodCallHandler(channel, null);
    },
  );
}
