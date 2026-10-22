import 'package:app/presentation/shared/app_viewport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('resizing preserves input and respects asymmetric side insets', (
    tester,
  ) async {
    final text = TextEditingController();
    addTearDown(text.dispose);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const contentKey = ValueKey('content');
    for (final (size, insets) in [
      (const Size(402, 874), const EdgeInsets.only(right: 64, bottom: 24)),
      (const Size(744, 1133), const EdgeInsets.only(right: 64, bottom: 24)),
      (const Size(1133, 744), const EdgeInsets.only(left: 64, bottom: 24)),
      (const Size(320, 600), const EdgeInsets.only(right: 32, bottom: 24)),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              padding: insets,
              viewPadding: insets,
            ),
            child: AppViewport(
              child: Scaffold(
                body: SizedBox.expand(
                  key: contentKey,
                  child: TextField(controller: text),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byKey(contentKey));
      expect(rect.left, insets.left);
      expect(rect.right, size.width - insets.right);
      final media = MediaQuery.of(tester.element(find.byKey(contentKey)));
      expect(media.padding.left, 0);
      expect(media.padding.right, 0);
      expect(media.padding.bottom, 24);
      if (text.text.isEmpty) {
        await tester.enterText(find.byType(TextField), 'Keep my reply');
      }
      expect(find.text('Keep my reply'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
