import 'dart:io';
import 'package:app/core/settings_notifier.dart';
import 'package:app/domain/models/chat_models.dart';
import 'package:app/presentation/chats/chat_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

ChatUserSummary person(String id, String? learning, String? native) =>
    ChatUserSummary(
      id: id,
      name: id,
      avatarUrl: null,
      learningLanguage: learning,
      learningLanguageDisplay: null,
      nativeLanguage: native,
      nativeLanguageDisplay: null,
      isOnline: true,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final people = [
    person('unrelated', 'es-ES', 'zh-CN'),
    person('same-native-peer', 'en-US', 'zh'),
    person('exchange', 'zh-CN', 'en-GB'),
    person('learner-of-my-native', 'zh-Hans', 'es'),
    person('peer', 'en-AU', 'es'),
    person('native', 'fr-FR', 'en'),
    person('existing', 'ja-JP', 'zh'),
    person('unset', null, null),
  ];
  List<ChatUserSummary> discover() => discoverableOnlineUsers(
    users: people,
    existingDmUserIds: {'existing'},
    learningLanguage: 'en-NZ',
    nativeLanguage: 'zh-CN',
  );
  test(
    'discovery removes shared-native-only matches and leaves DM input untouched',
    () {
      expect(discover().map((p) => p.id), [
        'exchange',
        'learner-of-my-native',
        'peer',
        'native',
      ]);
      expect(people.singleWhere((p) => p.id == 'existing').isOnline, isTrue);
      expect(people.length, 8);
    },
  );
  test(
    'locale variants match existing chat families without matching missing values',
    () {
      expect(sameChatLanguage(' EN_nz ', 'en-US'), isTrue);
      expect(sameChatLanguage('zh', 'zh-Hans-CN'), isTrue);
      expect(sameChatLanguage('zh-CN', 'zh-TW'), isFalse);
      expect(sameChatLanguage('zh-CN', 'yue-CN'), isFalse);
      expect(sameChatLanguage(null, null), isFalse);
      expect(sameChatLanguage(' ', ''), isFalse);
    },
  );
  test(
    'legacy discovery preferences are preserved but cannot expose same-native strangers',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'bantera-discovery-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/settings.json');
      final settings = SettingsNotifier.forTesting(settingsFile: file);
      await settings.initialize();
      expect(settings.hideSameNativeSpeakers('alice'), isFalse);
      await settings.setHideSameNativeSpeakers('alice', true);
      await settings.setHideSameNativeSpeakers('bob', false);
      final restored = SettingsNotifier.forTesting(settingsFile: file);
      await restored.initialize();
      expect(restored.hideSameNativeSpeakers('alice'), isTrue);
      expect(restored.hideSameNativeSpeakers('bob'), isFalse);
      expect(restored.hideSameNativeSpeakers(null), isFalse);
      await restored.setHideSameNativeSpeakers('alice', false);
      final reopened = SettingsNotifier.forTesting(settingsFile: file);
      await reopened.initialize();
      expect(reopened.hideSameNativeSpeakers('alice'), isFalse);
      expect(discover().any((p) => p.id == 'same-native-peer'), isFalse);
      expect(people.singleWhere((p) => p.id == 'existing').isOnline, isTrue);
    },
  );
}
