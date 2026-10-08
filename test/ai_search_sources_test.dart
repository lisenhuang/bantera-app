import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/infrastructure/ai/ai_web_search.dart';
import 'package:app/presentation/chats/ai/ai_search_sources.dart';
import 'package:app/l10n/app_localizations.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('search sources fit narrow $brightness bubble', (tester) async {
      final message = AiMessage(
        role: 'model',
        webSearchQuery: 'A detailed public search question',
        webSearchStatus: 'complete',
        sources: [
          const AiWebSource(
            'A long official page title with helpful search results and details',
            'https://www.example.com/weather',
            'Forecast',
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 260,
                child: AiSearchSources(message: message),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Sources'), findsOneWidget);
      expect(find.text('www.example.com'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(tester.takeException(), isNull);
      message.webSearchStatus = 'unavailable';
      await tester.pumpWidget(const SizedBox());
    });
  }
}
