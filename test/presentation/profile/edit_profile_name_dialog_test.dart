import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/edit_profile_name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openDialog(
  WidgetTester tester,
  Future<bool> Function(String) save,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) => EditProfileNameDialog(
                initialName: 'Alex',
                validateName: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'Enter a name.' : null,
                onSave: save,
                errorMessage: () => 'Please try again.',
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('cancel discards edited name without saving', (tester) async {
    var calls = 0;
    await openDialog(tester, (_) async {
      calls++;
      return true;
    });
    await tester.enterText(find.byType(TextFormField), 'New name');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('empty names stay in the dialog and never reach save', (
    tester,
  ) async {
    var calls = 0;
    await openDialog(tester, (_) async {
      calls++;
      return true;
    });
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('Enter a name.'), findsOneWidget);
  });

  testWidgets('successful save sends trimmed name and closes dialog', (
    tester,
  ) async {
    String? saved;
    await openDialog(tester, (name) async {
      saved = name;
      return true;
    });
    await tester.enterText(find.byType(TextFormField), '  Alex Morgan  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved, 'Alex Morgan');
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed save preserves input and permits retry', (tester) async {
    var calls = 0;
    await openDialog(tester, (_) async => ++calls == 2);
    await tester.enterText(find.byType(TextFormField), 'Alex Morgan');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Please try again.'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller?.text,
      'Alex Morgan',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
