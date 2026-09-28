import 'package:app/domain/models/chat_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('old backend response permits direct calls', () {
    final config = ChatIceServersConfig.fromJson({
      'iceServers': [
        {
          'urls': ['stun:stun.l.google.com:19302'],
        },
      ],
    }).toPeerConnectionConfiguration();
    expect(config['iceTransportPolicy'], 'all');
    expect(config['iceServers'], hasLength(1));
  });

  test('TURN only reaches native WebRTC with temporary credentials', () {
    final config = ChatIceServersConfig.fromJson({
      'iceTransportPolicy': 'relay',
      'iceServers': [
        {
          'urls': ['turns:turn.cloudflare.com:443?transport=tcp'],
          'username': 'temporary-user',
          'credential': 'temporary-password',
        },
      ],
    }).toPeerConnectionConfiguration();
    expect(config['iceTransportPolicy'], 'relay');
    final server = (config['iceServers'] as List).single as Map;
    expect(server['username'], 'temporary-user');
    expect(server['credential'], 'temporary-password');
  });

  test('unavailable relay never changes relay-only policy to all', () {
    final config = ChatIceServersConfig.fromJson({
      'iceTransportPolicy': 'relay',
      'iceServers': [],
    }).toPeerConnectionConfiguration();
    expect(config['iceTransportPolicy'], 'relay');
    expect(config['iceServers'], isEmpty);
  });
}
