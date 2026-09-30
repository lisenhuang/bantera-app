import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/activity/daily_word_goal.dart';
import '../../l10n/app_localizations.dart';

typedef GoalReminderSelection = ({TimeOfDay time, List<int> weekdays});

String goalReminderRepeatSummary(BuildContext context, List<int> weekdays) {
  final l10n = AppLocalizations.of(context)!;
  final days = weekdays.toSet();
  if (days.isEmpty) return l10n.dailyGoalRepeatNever;
  if (days.length == 7) return l10n.dailyGoalRepeatEveryDay;
  if (days.length == 5 && days.containsAll([1, 2, 3, 4, 5])) {
    return l10n.dailyGoalRepeatWeekdays;
  }
  if (days.length == 2 && days.containsAll([6, 7])) {
    return l10n.dailyGoalRepeatWeekends;
  }
  final format = DateFormat.E(Localizations.localeOf(context).toLanguageTag());
  return [
    for (var day = 1; day <= 7; day++)
      if (days.contains(day)) format.format(DateTime(2024, 1, day)),
  ].join(', ');
}

Future<GoalReminderSelection?> showGoalReminderTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
  List<int> initialWeekdays = DailyWordGoal.weekdays,
}) {
  FocusScope.of(context).unfocus();
  return showModalBottomSheet<GoalReminderSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .9,
    ),
    builder: (_) => _GoalReminderTimePicker(
      initialTime: initialTime,
      initialWeekdays: initialWeekdays,
    ),
  );
}

class _GoalReminderTimePicker extends StatefulWidget {
  const _GoalReminderTimePicker({
    required this.initialTime,
    required this.initialWeekdays,
  });
  final TimeOfDay initialTime;
  final List<int> initialWeekdays;

  @override
  State<_GoalReminderTimePicker> createState() =>
      _GoalReminderTimePickerState();
}

class _GoalReminderTimePickerState extends State<_GoalReminderTimePicker> {
  late TimeOfDay _selected = widget.initialTime;
  late final Set<int> _weekdays = widget.initialWeekdays.toSet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final names = DateFormat.E(locale).dateSymbols.NARROWWEEKDAYS;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  Expanded(
                    child: Text(
                      l10n.dailyGoalNotificationTime,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop((
                      time: _selected,
                      weekdays: List<int>.unmodifiable(
                        _weekdays.toList()..sort(),
                      ),
                    )),
                    child: Text(l10n.confirmLabel),
                  ),
                ],
              ),
              SizedBox(
                height: 256,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.onSurface.withValues(alpha: .12),
                        border: Border.all(color: colors.outlineVariant),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      itemExtent: 48,
                      backgroundColor: Colors.transparent,
                      selectionOverlayBuilder:
                          (_, {required selectedIndex, required columnCount}) =>
                              const SizedBox.shrink(),
                      initialDateTime: DateTime(
                        2000,
                        1,
                        1,
                        widget.initialTime.hour,
                        widget.initialTime.minute,
                      ),
                      onDateTimeChanged: (value) =>
                          _selected = TimeOfDay.fromDateTime(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dailyGoalRepeatLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              goalReminderRepeatSummary(
                                context,
                                _weekdays.toList(),
                              ),
                              textAlign: TextAlign.end,
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      Row(
                        children: [
                          for (var day = 1; day <= 7; day++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: Semantics(
                                  selected: _weekdays.contains(day),
                                  button: true,
                                  label: DateFormat.EEEE(
                                    locale,
                                  ).format(DateTime(2024, 1, day)),
                                  child: InkWell(
                                    key: ValueKey('reminder-weekday-$day'),
                                    customBorder: const CircleBorder(),
                                    onTap: () => setState(() {
                                      if (!_weekdays.add(day))
                                        _weekdays.remove(day);
                                    }),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: _weekdays.contains(day)
                                              ? null
                                              : Border.all(
                                                  color: colors.outline,
                                                  width: 1.5,
                                                ),
                                          color: _weekdays.contains(day)
                                              ? CupertinoColors.activeOrange
                                              : colors.surfaceContainerHighest,
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: FittedBox(
                                              child: Text(
                                                names[day % 7],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                  color: _weekdays.contains(day)
                                                      ? Colors.black
                                                      : colors.onSurface,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_weekdays.isEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.dailyGoalRepeatOnceHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
