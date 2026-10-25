import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

IconData practiceLevelStateIcon(String state) => switch (state) {
  'passed' => Icons.check_circle_outline_rounded,
  'practicing' => Icons.lock_open_rounded,
  _ => Icons.lock_outline_rounded,
};

String practiceLevelStateLabel(AppLocalizations l, String state) =>
    switch (state) {
      'passed' => l.quickLevelPassed,
      'practicing' => l.quickLevelPracticing,
      _ => l.quickLevelStateLocked,
    };
