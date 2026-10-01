import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/word_activity_notifier.dart';
import '../../core/goal_reminder_service.dart';
import '../../domain/activity/daily_word_goal.dart';
import '../../domain/activity/word_activity.dart';
import '../../l10n/app_localizations.dart';
import 'goal_reminder_time_picker.dart';
import 'word_activity_visuals.dart';

String goalMinutes(BuildContext context, double value) =>
    (NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    )..maximumFractionDigits = 1).format(value);

class DailyWordGoalSection extends StatelessWidget {
  const DailyWordGoalSection({
    super.key,
    required this.goal,
    required this.today,
    required this.onEdit,
  });
  final DailyWordGoal? goal;
  final WordTotals today;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final target = goal;
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: .6),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.dailyGoalTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (target != null)
                    IconButton(
                      onPressed: onEdit,
                      tooltip: l10n.dailyGoalEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                ],
              ),
              if (target == null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.dailyGoalSet),
                  ),
                )
              else ...[
                for (final item in [
                  (
                    listening: true,
                    summary: l10n.wordActivityListeningSummary,
                    count: today.listened,
                    target: target.listened,
                  ),
                  (
                    listening: false,
                    summary: l10n.wordActivitySpeakingSummary,
                    count: today.spoken,
                    target: target.spoken,
                  ),
                ].where((item) => item.target > 0)) ...[
                  const SizedBox(height: 10),
                  Semantics(
                    label: item.summary(
                      'today',
                      '${number.format(item.count)}/${number.format(item.target)}',
                      item.target,
                    ),
                    child: ExcludeSemantics(
                      child: Row(
                        children: [
                          Tooltip(
                            message: item.listening
                                ? l10n.wordActivityListening
                                : l10n.wordActivitySpeaking,
                            child: ActivityIcon(listening: item.listening),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: number.format(item.count),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  TextSpan(
                                    text: l10n.dailyGoalProgress(
                                      '',
                                      number.format(item.target),
                                    ),
                                  ),
                                ],
                              ),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          if (item.count >= item.target) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle_rounded,
                              color: activityColor(
                                context,
                                listening: item.listening,
                              ),
                              size: 22,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    color: activityColor(context, listening: item.listening),
                    backgroundColor: activityColor(
                      context,
                      listening: item.listening,
                    ).withValues(alpha: .10),
                    semanticsLabel: item.listening
                        ? l10n.wordActivityListening
                        : l10n.wordActivitySpeaking,
                    value: (item.count / item.target).clamp(0.0, 1.0),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  target.listened == 0 && target.spoken == 0
                      ? l10n.dailyGoalNoRequirement
                      : today.listened >= target.listened &&
                            today.spoken >= target.spoken
                      ? l10n.dailyGoalReached
                      : l10n.dailyGoalTimeTotal(
                          goalMinutes(context, target.totalMinutes),
                        ),
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

class DailyWordGoalScreen extends StatefulWidget {
  const DailyWordGoalScreen({super.key, this.notifier});
  final WordActivityNotifier? notifier;
  @override
  State<DailyWordGoalScreen> createState() => _DailyWordGoalScreenState();
}

class _DailyWordGoalScreenState extends State<DailyWordGoalScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _listening;
  late final TextEditingController _speaking;
  late final WordActivityNotifier _notifier;
  String? _ownerId;
  int? _preset;
  bool _busy = false;
  bool _notificationsEnabled = true;
  DateTime? _oneTimeReminderDate;
  List<int> _notificationWeekdays = DailyWordGoal.weekdays;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier ?? WordActivityNotifier.instance;
    _ownerId = _notifier.accountId;
    final initial = _notifier.dailyGoal ?? DailyWordGoal.forMinutes(10);
    _notificationsEnabled = initial.notificationsEnabled;
    _notificationWeekdays = initial.notificationWeekdays;
    _oneTimeReminderDate = initial.notificationOnceAt;
    _notificationTime = TimeOfDay(
      hour: initial.notificationHour,
      minute: initial.notificationMinute,
    );
    _listening = TextEditingController(text: '${initial.listened}');
    _speaking = TextEditingController(text: '${initial.spoken}');
    for (final minutes in [5, 10, 20, 30]) {
      final preset = DailyWordGoal.forMinutes(minutes);
      if (initial.listened == preset.listened &&
          initial.spoken == preset.spoken) {
        _preset = minutes;
      }
    }
  }

  @override
  void dispose() {
    _listening.dispose();
    _speaking.dispose();
    super.dispose();
  }

  DailyWordGoal? get _selection {
    final listened = int.tryParse(_listening.text);
    final spoken = int.tryParse(_speaking.text);
    if (listened == null || spoken == null) return null;
    final value = DailyWordGoal(
      listened: listened,
      spoken: spoken,
      notificationsEnabled: _notificationsEnabled,
      notificationHour: _notificationTime.hour,
      notificationMinute: _notificationTime.minute,
      notificationWeekdays: _notificationWeekdays,
      notificationOnceAt: _notificationWeekdays.isEmpty
          ? _oneTimeReminderDate
          : null,
    );
    return value.isValid ? value : null;
  }

  Future<void> _confirmRemoveGoal() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        alignment: Alignment.center,
        title: Text(l10n.dailyGoalRemove),
        content: Text(l10n.dailyGoalRemoveConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(l10n.dailyGoalRemove),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _save(remove: true);
  }

  Future<void> _save({bool remove = false}) async {
    if (_busy || (!remove && !_form.currentState!.validate())) return;
    if (!remove && _notificationsEnabled && _notificationWeekdays.isEmpty) {
      final now = DateTime.now();
      if (_oneTimeReminderDate == null || !_oneTimeReminderDate!.isAfter(now)) {
        var next = DateTime(
          now.year,
          now.month,
          now.day,
          _notificationTime.hour,
          _notificationTime.minute,
        );
        if (!next.isAfter(now)) {
          next = DateTime(
            now.year,
            now.month,
            now.day + 1,
            _notificationTime.hour,
            _notificationTime.minute,
          );
        }
        _oneTimeReminderDate = next;
      }
    }
    setState(() => _busy = true);
    if (!remove &&
        _notificationsEnabled &&
        widget.notifier == null &&
        (_selection?.totalMinutes ?? 0) > 0) {
      await GoalReminderService.instance.requestPermission();
    }
    final saved = await _notifier.setDailyGoal(
      remove ? null : _selection,
      ownerId: _ownerId,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (saved) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dailyGoalSaveFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final goal = _selection;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dailyGoalTitle)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.dailyGoalChoose,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final minutes in [5, 10, 20, 30])
                  ChoiceChip(
                    showCheckmark: false,
                    label: Text(l10n.dailyGoalPreset('$minutes')),
                    selected: _preset == minutes,
                    onSelected: _busy
                        ? null
                        : (_) => setState(() {
                            _preset = minutes;
                            final goal = DailyWordGoal.forMinutes(minutes);
                            _listening.text = '${goal.listened}';
                            _speaking.text = '${goal.spoken}';
                          }),
                  ),
                ChoiceChip(
                  showCheckmark: false,
                  label: Text(l10n.dailyGoalCustom),
                  selected: _preset == null,
                  onSelected: _busy
                      ? null
                      : (_) => setState(() => _preset = null),
                ),
              ],
            ),
            const SizedBox(height: 24),
            for (final field in [
              (
                key: 'listening-goal',
                controller: _listening,
                label: l10n.dailyGoalListeningTarget,
                minutes: goal?.listeningMinutes,
                icon: Icons.headphones_outlined,
              ),
              (
                key: 'speaking-goal',
                controller: _speaking,
                label: l10n.dailyGoalSpeakingTarget,
                minutes: goal?.speakingMinutes,
                icon: Icons.mic_none_outlined,
              ),
            ]) ...[
              TextFormField(
                key: ValueKey(field.key),
                controller: field.controller,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  labelText: field.label,
                  helperText: '${l10n.dailyGoalNoRequirement}: 0',
                  helperMaxLines: 2,
                  prefixIcon: Icon(field.icon),
                  border: const OutlineInputBorder(),
                ),
                validator: (text) {
                  final value = int.tryParse(text ?? '');
                  return value == null ||
                          value < 0 ||
                          value > DailyWordGoal.maxWords
                      ? l10n.dailyGoalValidation
                      : null;
                },
                onChanged: (_) => setState(() => _preset = null),
              ),
              const SizedBox(height: 8),
              if (field.minutes != null)
                Text(
                  field.minutes == 0
                      ? l10n.dailyGoalNoRequirement
                      : l10n.dailyGoalEstimate(
                          goalMinutes(context, field.minutes!),
                        ),
                ),
              const SizedBox(height: 24),
            ],
            if (goal != null && goal.totalMinutes > 0)
              Text(
                l10n.dailyGoalTimeTotal(
                  goalMinutes(context, goal.totalMinutes),
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 12),
            Text(
              l10n.dailyGoalTimeHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            SwitchListTile.adaptive(
              key: const ValueKey('daily-goal-notifications'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.dailyGoalNotificationLabel),
              subtitle: Text(l10n.dailyGoalNotificationHint),
              value: _notificationsEnabled,
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _notificationsEnabled = value),
            ),
            if (_notificationsEnabled)
              ListTile(
                key: const ValueKey('daily-goal-notification-time'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_outlined),
                title: Text(l10n.dailyGoalNotificationTime),
                subtitle: Text(
                  goalReminderRepeatSummary(context, _notificationWeekdays),
                ),
                trailing: Text(_notificationTime.format(context)),
                onTap: _busy
                    ? null
                    : () async {
                        final time = await showGoalReminderTimePicker(
                          context,
                          initialTime: _notificationTime,
                          initialWeekdays: _notificationWeekdays,
                        );
                        if (mounted && time != null) {
                          setState(() {
                            if (_notificationTime != time.time ||
                                !_notificationWeekdays.toSet().containsAll(
                                  time.weekdays,
                                ) ||
                                _notificationWeekdays.length !=
                                    time.weekdays.length) {
                              _oneTimeReminderDate = null;
                            }
                            _notificationTime = time.time;
                            _notificationWeekdays = time.weekdays;
                          });
                        }
                      },
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : () => _save(),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.doneLabel),
            ),
            if (_notifier.dailyGoal != null)
              TextButton(
                onPressed: _busy ? null : _confirmRemoveGoal,
                child: Text(l10n.dailyGoalRemove),
              ),
          ],
        ),
      ),
    );
  }
}
