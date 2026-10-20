import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/practice/practice_answer_matcher.dart';

void main() {
  final cases =
      jsonDecode(
            File('test/fixtures/practice_matching.json').readAsStringSync(),
          )
          as List;
  for (final row in cases.cast<Map<String, dynamic>>()) {
    test(row['name'] as String, () {
      expect(
        PracticeAnswerMatcher.match(
          row['transcript'] as String,
          (row['choices'] as List).cast<String>(),
          row['locale'] as String,
          uncertainWords: (row['uncertainWords'] as List).cast<String>(),
        ),
        row['expected'],
      );
    });
  }
}
