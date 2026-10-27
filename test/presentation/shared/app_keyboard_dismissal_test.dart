import 'package:app/presentation/shared/app_keyboard_dismissal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets(
      'outside touch dismisses fields without consuming actions: $platform',
      (tester) async {
        final first = FocusNode(), second = FocusNode();
        final controller = TextEditingController();
        addTearDown(first.dispose);
        addTearDown(second.dispose);
        addTearDown(controller.dispose);
        var presses = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            builder: (_, child) => AppKeyboardDismissal(child: child!),
            home: Scaffold(
              body: Column(
                children: [
                  const SizedBox(height: 40),
                  TextField(
                    key: const ValueKey('search'),
                    focusNode: first,
                    controller: controller,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: controller.clear,
                      ),
                    ),
                  ),
                  TextFormField(
                    key: const ValueKey('target'),
                    focusNode: second,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 40),
                  const Text('Outside the inputs'),
                  FilledButton(
                    onPressed: () => presses++,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(const ValueKey('search')));
        await tester.enterText(
          find.byKey(const ValueKey('search')),
          'Japanese',
        );
        await tester.pump();
        expect(first.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();
        expect(first.hasFocus, isTrue);
        expect(controller.text, isEmpty);
        await tester.enterText(
          find.byKey(const ValueKey('search')),
          'Japanese',
        );
        await tester.tap(find.text('Outside the inputs'));
        await tester.pump();
        expect(first.hasFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
        expect(controller.text, 'Japanese');
        await tester.tap(find.byKey(const ValueKey('search')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('target')));
        await tester.pump();
        expect(first.hasFocus, isFalse);
        expect(second.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
        await tester.tap(find.text('Save'));
        await tester.pump();
        expect(presses, 1);
        expect(second.hasFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant({platform}),
    );

    for (final surface in ['page', 'dialog', 'sheet']) {
      testWidgets(
        'global dismissal reaches $surface search on $platform',
        (tester) async {
          final focus = FocusNode();
          addTearDown(focus.dispose);
          final content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Language selection'),
              ),
              TextField(
                key: const ValueKey('language-search'),
                focusNode: focus,
              ),
              const SizedBox(height: 40),
            ],
          );
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: platform),
              builder: (_, child) => AppKeyboardDismissal(child: child!),
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    child: const Text('Open'),
                    onPressed: () {
                      switch (surface) {
                        case 'page':
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => Scaffold(body: content),
                            ),
                          );
                        case 'dialog':
                          showDialog<void>(
                            context: context,
                            builder: (_) => Dialog(child: content),
                          );
                        case 'sheet':
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (_) => content,
                          );
                      }
                    },
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('language-search')));
          await tester.pump();
          expect(focus.hasFocus, isTrue);
          expect(tester.testTextInput.isVisible, isTrue);
          await tester.tap(find.text('Language selection'));
          await tester.pump();
          expect(focus.hasFocus, isFalse);
          expect(tester.testTextInput.isVisible, isFalse);
          expect(find.text('Language selection'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
        variant: TargetPlatformVariant({platform}),
      );
    }
  }
}
