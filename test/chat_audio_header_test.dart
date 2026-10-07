import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/chats/chat_bubble_parts.dart';

void main() {
  testWidgets(
    'audio row keeps controls in order with expanded timeline at large text sizes',
    (tester) async {
      for (final scale in [1.0, 2.0, 3.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: SizedBox(
                    width: 260,
                    child: ChatAudioHeader(
                      playing: false,
                      progress: 0,
                      duration: '3:00',
                      onPlay: () {},
                      trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.translate),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final play = tester.getRect(find.byIcon(Icons.play_arrow_rounded));
        final duration = tester.getRect(find.text('3:00'));
        final progress = tester.getRect(find.byType(LinearProgressIndicator));
        final translate = tester.getRect(find.byIcon(Icons.translate));
        expect(play.center.dx, lessThan(duration.center.dx));
        expect(duration.right, lessThan(progress.left));
        expect(progress.right, lessThan(translate.left));
        expect(progress.width, greaterThan(35));
        expect(progress.center.dy, closeTo(play.center.dy, 1));
      }
    },
  );
}
