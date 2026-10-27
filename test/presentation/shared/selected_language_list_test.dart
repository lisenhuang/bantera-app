import 'package:app/presentation/shared/selected_language_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selected language opens in view with wrapped and large text', (
    tester,
  ) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              height: 320,
              width: 240,
              child: SelectedLanguageList(
                controller: controller,
                identifiers: List.generate(40, (i) => 'lang-$i'),
                selectedIdentifier: 'lang-30',
                itemBuilder: (context, i) => ListTile(
                  title: Text(
                    'Language $i with a long name',
                    textScaler: const TextScaler.linear(1.8),
                  ),
                  subtitle: Text('lang-$i'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));
    final row = tester.getRect(find.text('lang-30'));
    final viewport = tester.getRect(find.byType(SingleChildScrollView));
    expect(viewport.contains(row.center), isTrue);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
