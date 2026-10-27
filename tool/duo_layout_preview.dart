// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'package:app/presentation/shared/adaptive_viewport_state.dart';
import 'package:app/domain/models/models.dart';
import 'package:app/presentation/practice/practice_player_screen.dart';
// Debug-only simulator fixtures. Never use this entry point in a release build.
import 'package:app/core/settings_notifier.dart';
import 'package:app/core/theme.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:app/presentation/chats/ai/ai_chat_screen.dart';
import 'package:app/presentation/chats/adaptive_chats_screen.dart';
import 'package:app/presentation/chats/chat_pane_navigation.dart';
import 'package:app/presentation/profile/profile_screen.dart';
import 'package:app/presentation/quick_practice/quick_practice_screen.dart';
import 'package:app/presentation/shared/adaptive_layout.dart';
import 'package:app/presentation/shared/adaptive_navigation.dart';
import 'package:app/presentation/shared/app_viewport.dart';
import 'package:app/presentation/shared/animated_tab_icon.dart';
import 'package:app/presentation/shared/goal_tab_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  if (!kDebugMode) throw StateError('Simulator fixtures require debug mode');
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsNotifier.instance.initialize();
  final data = ByteData(44 + 16000 * 2 * 12);
  void tag(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      data.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  data.setUint32(4, data.lengthInBytes - 8, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, 16000, Endian.little);
  data.setUint32(28, 32000, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  tag(36, 'data');
  data.setUint32(40, data.lengthInBytes - 44, Endian.little);
  await File(
    '${Directory.systemTemp.path}/duo-fixture.wav',
  ).writeAsBytes(data.buffer.asUint8List());
  runApp(const Preview());
}

class Preview extends StatefulWidget {
  const Preview({super.key});
  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  int page = 0, replay = 0;
  bool large = false, dark = false;
  bool chatDetail = false;
  final controller = AiChatController.forTesting(
    AiHistoryStore('duo-layout-fixture'),
  );
  @override
  void initState() {
    super.initState();
    controller.loaded = true;
    controller.store.messages.addAll([
      AiMessage(role: 'user', text: 'How can I ask for directions politely?'),
      AiMessage(
        role: 'model',
        text: 'Try these phrases.',
        formattedText:
            '## Asking for directions\n\nStart with **“Excuse me”** to get someone’s attention. Then ask a short, clear question.\n\n'
            '| Situation | Example |\n|---|---|\n| Find a place | Where is the station? |\n| Ask for help | Could you show me on the map? |\n\n'
            'Try saying the first question aloud. We can practice together.',
      ),
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatPaneNavigatorKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (_) => AiChatScreen(controller: controller),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorObservers: [adaptiveViewportObserver],
    theme: dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(large ? 2.5 : 1)),
      child: AppViewport(child: child!),
    ),
    home: Builder(
      builder: (context) => Scaffold(
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'SIMULATOR FIXTURES · ${AdaptiveLayoutScope.of(context).edge.name}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Dialogue',
                    icon: const Icon(Icons.play_circle_outline),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PracticePlayerScreen(
                          mediaItem: MediaItem(
                            id: 'duo-fixture',
                            title: 'At the station',
                            description: 'Simulator fixture',
                            creator: User(
                              id: 'fixture',
                              displayName: 'Bantera',
                              avatarUrl: '',
                              firstLanguage: 'en-NZ',
                              learningLanguage: 'en-NZ',
                              level: 'A1',
                            ),
                            coverUrl: '',
                            localVideoPath:
                                '${Directory.systemTemp.path}/duo-fixture.wav',
                            spokenLanguage: 'en-NZ',
                            accent: 'en-NZ',
                            durationMs: 12000,
                            isAudioOnly: true,
                            transcriptionSource: 'fixture',
                            cues: [
                              Cue(
                                id: '1',
                                startTimeMs: 0,
                                endTimeMs: 4000,
                                originalText:
                                    'Excuse me, where is the station?',
                                translatedText: '',
                              ),
                              Cue(
                                id: '2',
                                startTimeMs: 4000,
                                endTimeMs: 8000,
                                originalText:
                                    'It is next to the bank, on your left.',
                                translatedText: '',
                              ),
                              Cue(
                                id: '3',
                                startTimeMs: 8000,
                                endTimeMs: 12000,
                                originalText: 'Thank you for your help.',
                                translatedText: '',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Large text',
                    onPressed: () => setState(() => large = !large),
                    icon: const Icon(Icons.text_increase),
                  ),
                  IconButton(
                    tooltip: 'Theme',
                    onPressed: () => setState(() => dark = !dark),
                    icon: const Icon(Icons.contrast),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AdaptiveMainNavigation(
                visible: page != 1 || !chatDetail,
                selectedIndex: page,
                onSelected: (value) => setState(() {
                  page = value;
                  replay++;
                }),
                items: [
                  BottomNavigationBarItem(
                    icon: AnimatedTabIcon(
                      kind: AnimatedTabKind.practice,
                      replayTick: replay,
                      selected: page == 0,
                    ),
                    label: 'Practice',
                  ),
                  BottomNavigationBarItem(
                    icon: AnimatedTabIcon(
                      kind: AnimatedTabKind.chats,
                      replayTick: replay,
                      selected: page == 1,
                    ),
                    label: 'Chats',
                  ),
                  BottomNavigationBarItem(
                    icon: LiveGoalTabIcon(replayTick: replay),
                    label: 'Goal',
                  ),
                ],
                body: IndexedStack(
                  index: page,
                  children: [
                    const QuickPracticeScreen.preview(
                      previewExercise: {
                        'id': 'duo-preview',
                        'level': 'A1',
                        'cue': 'Where is the station?',
                        'cueAudioUrl': '',
                        'translations': {
                          'cue': '¿Dónde está la estación?',
                          'option0': 'Está al lado del banco.',
                          'option1': 'Abre a las nueve.',
                        },
                        'choices': [
                          {'text': 'It’s next to the bank.', 'audioUrl': ''},
                          {'text': 'It opens at nine.', 'audioUrl': ''},
                        ],
                      },
                    ),
                    AdaptiveChatsScreen(
                      active: page == 1,
                      onDetailChanged: (value) =>
                          setState(() => chatDetail = value),
                    ),
                    ProfileScreen(active: page == 2, refreshTick: replay),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
