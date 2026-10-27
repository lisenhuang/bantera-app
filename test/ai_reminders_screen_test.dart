import 'dart:async';
import 'package:app/infrastructure/ai/ai_api_client.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/chats/ai/ai_reminders_screen.dart';
import 'package:app/presentation/shared/swipe_action_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeApi extends AiApiClient {
  final calls = <String>[];
  bool fail = false;
  Completer<void>? gate;
  List<Map> items = [
    {
      'id': 'one',
      'reminder': 'Review words',
      'delivery': 'message',
      'dueAt': '2026-10-27T10:00:00Z',
      'status': 'scheduled',
    },
    {
      'id': 'two',
      'reminder': 'Already delivered',
      'delivery': 'call',
      'dueAt': '2026-10-26T10:00:00Z',
      'status': 'answered',
    },
  ];
  @override
  Future<dynamic> reminderRequest(
    String owner,
    String method, [
    String path = '',
  ]) async {
    calls.add('$method $path');
    if (method == 'GET') return items.map((i) => Map.of(i)).toList();
    await gate?.future;
    if (fail) throw StateError('network');
    if (path == '/history') {
      items = [];
      return {'remaining': <Map>[]};
    }
    items.removeWhere((i) => path.endsWith('/${i['id']}'));
    return null;
  }
}

void main() {
  Widget page(FakeApi api) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: AiRemindersScreen(api: api, owner: 'test'),
  );
  testWidgets(
    'swipe only reveals, API success removes, failures keep the reminder',
    (tester) async {
      final api = FakeApi();
      await tester.pumpWidget(page(api));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(SwipeActionCard).first,
        const Offset(-220, 0),
      );
      await tester.pumpAndSettle();
      expect(api.calls.where((c) => c.startsWith('DELETE')), isEmpty);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      api.fail = true;
      await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
      await tester.pumpAndSettle();
      expect(find.text('Review words'), findsOneWidget);
      api.fail = false;
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      api.gate = Completer<void>();
      await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Review words'), findsOneWidget);
      api.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Review words'), findsNothing);
      expect(api.calls, contains('DELETE /history/one'));
    },
  );
  testWidgets('clear all confirms and retains every card when API fails', (
    tester,
  ) async {
    final api = FakeApi();
    await tester.pumpWidget(page(api));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(api.calls.where((c) => c.startsWith('DELETE')), isEmpty);
    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    api.fail = true;
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.byType(SwipeActionCard), findsNWidgets(2));
    api.fail = false;
    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.byType(SwipeActionCard), findsNothing);
    expect(api.calls, contains('DELETE /history'));
  });
}
