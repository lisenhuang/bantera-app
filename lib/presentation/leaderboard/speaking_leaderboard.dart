import '../profile/goal_motion.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import '../../core/auth_session_notifier.dart';
import '../../core/chat_session_notifier.dart';
import '../../domain/models/chat_models.dart';
import '../../domain/activity/speaking_leaderboard_period.dart';
import '../chats/chat_conversation_screen.dart';
import '../../core/word_activity_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/last_snapshot_cache.dart';
import '../../l10n/app_localizations.dart';
import '../shared/learning_language_label.dart';
import '../shared/language_code_label.dart';
import '../shared/profile_avatar.dart';
import 'leaderboard_motion.dart';

/// Use the first space-separated name without guessing name order or splitting
/// continuous-script names. The full profile value remains untouched.
String? leaderboardFirstName(String? name) {
  final value = name?.trim();
  if (value == null || value.isEmpty) return null;
  return value
      .split(
        RegExp(r'[\s\u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]+'),
      )
      .first;
}

class SpeakingReport {
  SpeakingReport(this.data);
  final Map<String, dynamic> data;
  List<Map<String, dynamic>> get rows => (data['rows'] as List)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  Map<String, dynamic> get you => Map<String, dynamic>.from(data['you'] as Map);
  int get periodDays => speakingLeaderboardPeriodDays(data);
  int get nextOffset =>
      (data['nextOffset'] as int?) ??
      ((data['offset'] as int?) ?? 0) + rows.length;

  bool sameWindow(SpeakingReport other) =>
      periodDays == other.periodDays &&
      [
        'fromDate',
        'throughDate',
        'fromUtc',
        'throughUtc',
      ].every((key) => data[key] == other.data[key]);

  SpeakingReport append(SpeakingReport page) {
    if (!sameWindow(page)) throw StateError('Leaderboard window changed');
    final keys = rows.map((row) => row['key']).toSet();
    return SpeakingReport({
      ...data,
      'rows': [...rows, ...page.rows.where((row) => keys.add(row['key']))],
      'hasMore': page.data['hasMore'],
      'nextOffset': page.nextOffset,
    });
  }

  String get fingerprint => jsonEncode([
    rows.take((data['limit'] as int?) ?? 100).toList(),
    data['you'],
    data['fromDate'],
    data['throughDate'],
    periodDays,
    data['fromUtc'],
    data['throughUtc'],
  ]);
  String range(String locale) {
    if (data['fromUtc'] is String && data['throughUtc'] is String) {
      final format = DateFormat.yMMMd(locale).add_Hms();
      return '${format.format(DateTime.parse(data['fromUtc']).toLocal())} – ${format.format(DateTime.parse(data['throughUtc']).toLocal())}';
    }
    final format = DateFormat.yMMMd(locale);
    return '${format.format(DateTime.parse(data['fromDate']))} – ${format.format(DateTime.parse(data['throughDate']))} · UTC';
  }
}

/// Keep every displayed page in one exact reporting window. A configuration
/// change during pagination starts over with a fresh first page.
Future<SpeakingReport> loadSpeakingLeaderboardPages({
  required Future<Map<String, dynamic>> Function({int offset, String? until})
  loadPage,
  SpeakingReport? appendTo,
  int retainRows = 0,
}) async {
  var next = SpeakingReport(
    await loadPage(
      offset: appendTo?.nextOffset ?? 0,
      until: appendTo?.data['throughUtc'] as String?,
    ),
  );
  if (appendTo != null) {
    if (!appendTo.sameWindow(next)) {
      return SpeakingReport(await loadPage(offset: 0));
    }
    return appendTo.append(next);
  }
  while (next.data['hasMore'] == true && next.rows.length < retainRows) {
    final page = SpeakingReport(
      await loadPage(
        offset: next.nextOffset,
        until: next.data['throughUtc'] as String?,
      ),
    );
    if (!next.sameWindow(page)) {
      return SpeakingReport(await loadPage(offset: 0));
    }
    if (page.rows.isEmpty) break;
    next = next.append(page);
  }
  return next;
}

class SpeakingLeaderboardCard extends StatefulWidget {
  const SpeakingLeaderboardCard({
    super.key,
    this.preview,
    this.active = true,
    this.refreshTick = 0,
  });
  final bool active;
  final int refreshTick;
  final SpeakingReport? preview;
  @override
  State<SpeakingLeaderboardCard> createState() =>
      _SpeakingLeaderboardCardState();
}

class _SpeakingLeaderboardCardState extends State<SpeakingLeaderboardCard>
    with WidgetsBindingObserver {
  SpeakingReport? _report;
  bool _failed = false;
  int _epoch = 0;
  Timer? _refresh;
  DateTime? _lastLoad;
  @override
  void initState() {
    super.initState();
    _owner = AuthSessionNotifier.instance.session?.cacheKey;
    final cached = _owner == null
        ? null
        : LastSnapshotCache.leaderboard.peek(_owner!);
    _report =
        widget.preview ?? (cached == null ? null : SpeakingReport(cached));
    if (widget.preview == null) {
      AuthSessionNotifier.instance.addListener(_accountChanged);
      WordActivityNotifier.instance.addListener(_activityChanged);
      WidgetsBinding.instance.addObserver(this);
      if (widget.active) unawaited(_load(sync: true));
    }
  }

  @override
  void didUpdateWidget(SpeakingLeaderboardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.preview != null) {
      _report = widget.preview;
      return;
    }
    if (!widget.active) _refresh?.cancel();
    if (widget.active &&
        (!oldWidget.active || widget.refreshTick != oldWidget.refreshTick)) {
      _refresh?.cancel();
      unawaited(_load(sync: true));
    }
  }

  void _activityChanged() {
    if (!widget.active || _refresh?.isActive == true) return;
    final elapsed = _lastLoad == null
        ? const Duration(minutes: 1)
        : DateTime.now().difference(_lastLoad!);
    final wait = elapsed >= const Duration(seconds: 30)
        ? const Duration(seconds: 2)
        : const Duration(seconds: 30) - elapsed;
    _refresh = Timer(wait, () {
      if (mounted &&
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        unawaited(_load());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.active) {
      _refresh?.cancel();
      unawaited(_load(sync: true));
    }
  }

  String? _owner;
  void _accountChanged() {
    if (_owner == AuthSessionNotifier.instance.session?.cacheKey) return;
    _epoch++;
    setState(() {
      _report = null;
      _failed = false;
    });
    unawaited(_load());
  }

  Future<void> _load({bool sync = false}) async {
    final session = AuthSessionNotifier.instance.session;
    final epoch = ++_epoch;
    _owner = session?.cacheKey;
    if (session == null) return;
    _lastLoad = DateTime.now();
    unawaited(_restoreCache(session.cacheKey, epoch));
    try {
      if (sync) await WordActivityNotifier.instance.syncForLeaderboard();
      if (!mounted || epoch != _epoch || session.cacheKey != _owner) return;
      final report = SpeakingReport(
        await AuthApiClient.instance.speakingLeaderboard(
          accessToken: session.accessToken,
          configured: true,
        ),
      );
      if (mounted &&
          epoch == _epoch &&
          _owner == AuthSessionNotifier.instance.session?.cacheKey) {
        unawaited(
          LastSnapshotCache.leaderboard.save(session.cacheKey, report.data),
        );
        setState(() {
          _report = report;
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted && epoch == _epoch) setState(() => _failed = true);
    }
  }

  Future<void> _restoreCache(String owner, int epoch) async {
    final cached = await LastSnapshotCache.leaderboard.read(owner);
    if (mounted &&
        epoch == _epoch &&
        _report == null &&
        cached != null &&
        owner == AuthSessionNotifier.instance.session?.cacheKey) {
      setState(() => _report = SpeakingReport(cached));
    }
  }

  @override
  void dispose() {
    AuthSessionNotifier.instance.removeListener(_accountChanged);
    if (widget.preview == null) {
      WordActivityNotifier.instance.removeListener(_activityChanged);
    }
    WidgetsBinding.instance.removeObserver(this);
    _refresh?.cancel();
    _epoch++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = Theme.of(context).colorScheme;
    final own = _report?.you;
    return Padding(
      padding: EdgeInsets.zero,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: c.primary.withValues(alpha: .18)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SpeakingLeaderboardScreen(),
              ),
            );
            if (mounted && widget.preview == null) await _load();
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events_outlined, color: c.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.leaderboardTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: c.primary),
                  ],
                ),
                if (_report != null) ...[
                  const SizedBox(height: 6),
                  Text(l.leaderboardPeriodScope(_report!.periodDays)),
                ],
                const SizedBox(height: 16),
                if (own != null)
                  Wrap(
                    spacing: 28,
                    runSpacing: 10,
                    children: [
                      _metric(
                        own['rank'] == null ? '—' : '#${own['rank']}',
                        l.leaderboardYourPosition,
                        c.primary,
                      ),
                      _metric(
                        NumberFormat.decimalPattern(
                          l.localeName,
                        ).format(own['spokenWords']),
                        l.leaderboardSpokenWords,
                        c.onSurface,
                        count: own['spokenWords'] as num,
                      ),
                    ],
                  )
                else if (_failed)
                  Text(l.leaderboardError)
                else
                  const LinearProgressIndicator(minHeight: 2),
                const SizedBox(height: 12),
                Text(
                  l.leaderboardOpen,
                  style: TextStyle(
                    color: c.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metric(String value, String label, Color color, {num? count}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (count != null)
            AnimatedSpokenCount(
              key: ValueKey((
                _owner,
                widget.refreshTick,
                widget.active,
                GoalMotion.revisionOf(context),
              )),
              fromZero: widget.active,
              value: count,
              locale: AppLocalizations.of(context)!.localeName,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          if (count == null)
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
}

class SpeakingLeaderboardScreen extends StatefulWidget {
  const SpeakingLeaderboardScreen({super.key});
  @override
  State<SpeakingLeaderboardScreen> createState() =>
      _SpeakingLeaderboardScreenState();
}

class _SpeakingLeaderboardScreenState extends State<SpeakingLeaderboardScreen> {
  SpeakingReport? _report;
  bool _busy = false, _failed = false;
  int _days = 30;
  bool _canChoosePeriod = false;
  bool _isAdmin = false;
  Timer? _timer;
  String? _owner;
  int _epoch = 0;
  @override
  void initState() {
    super.initState();
    _owner = AuthSessionNotifier.instance.session?.cacheKey;
    _isAdmin = AuthSessionNotifier.instance.session?.isAdmin == true;
    final cached = _owner == null
        ? null
        : LastSnapshotCache.leaderboard.peek(_owner!);
    if (cached != null && !_isAdmin) {
      _report = SpeakingReport(cached);
    }
    AuthSessionNotifier.instance.addListener(_accountChanged);
    unawaited(_load());
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _load(quiet: true),
    );
  }

  void _accountChanged() {
    final owner = AuthSessionNotifier.instance.session?.cacheKey;
    final isAdmin = AuthSessionNotifier.instance.session?.isAdmin == true;
    if (owner == _owner && isAdmin == _isAdmin) return;
    _owner = owner;
    _isAdmin = isAdmin;
    _epoch++;
    setState(() {
      _report = null;
      _busy = false;
      _days = 30;
      _canChoosePeriod = false;
    });
    unawaited(_load());
  }

  Future<void> _load({bool quiet = false}) async {
    if (_busy ||
        (quiet &&
            (WidgetsBinding.instance.lifecycleState !=
                    AppLifecycleState.resumed ||
                ModalRoute.of(context)?.isCurrent != true))) {
      return;
    }
    final session = AuthSessionNotifier.instance.session;
    if (session == null) return;
    final epoch = ++_epoch;
    final days = _days;
    if (!_isAdmin) unawaited(_restoreCache(session.cacheKey, epoch));
    setState(() {
      _busy = true;
      if (!quiet) _failed = false;
    });
    try {
      if (!quiet) await WordActivityNotifier.instance.syncForLeaderboard();
      if (!mounted || epoch != _epoch || session.cacheKey != _owner) return;
      final next = await loadSpeakingLeaderboardPages(
        loadPage: ({int offset = 0, String? until}) async {
          if (!mounted || epoch != _epoch || session.cacheKey != _owner) {
            throw StateError('Leaderboard request superseded');
          }
          return AuthApiClient.instance.speakingLeaderboard(
            accessToken: session.accessToken,
            days: days,
            configured: !_isAdmin,
            offset: offset,
            until: until,
          );
        },
        retainRows: _report?.rows.length ?? 0,
      );
      if (!mounted || epoch != _epoch || session.cacheKey != _owner) return;
      if (!_isAdmin) {
        unawaited(
          LastSnapshotCache.leaderboard.save(session.cacheKey, next.data),
        );
      }
      setState(() {
        _canChoosePeriod = _isAdmin && next.data['canChoosePeriod'] == true;
        _report = next;
        _failed = false;
      });
    } on AuthApiException catch (error) {
      if (mounted && epoch == _epoch) {
        if (days != 30 && error.statusCode == 403) {
          _canChoosePeriod = false;
          _selectPeriod(30, force: true);
        } else {
          setState(() => _failed = true);
        }
      }
    } catch (_) {
      if (mounted && epoch == _epoch) setState(() => _failed = true);
    } finally {
      if (mounted && epoch == _epoch) setState(() => _busy = false);
    }
  }

  Future<void> _restoreCache(String owner, int epoch) async {
    final cached = await LastSnapshotCache.leaderboard.read(owner);
    if (mounted &&
        epoch == _epoch &&
        _report == null &&
        cached != null &&
        !_isAdmin &&
        owner == _owner &&
        owner == AuthSessionNotifier.instance.session?.cacheKey) {
      setState(() {
        _report = SpeakingReport(cached);
      });
    }
  }

  Future<void> _loadMore() async {
    if (_busy || _report?.data['hasMore'] != true) return;
    final session = AuthSessionNotifier.instance.session;
    if (session == null || session.cacheKey != _owner) return;
    final cutoff = DateTime.tryParse(
      _report?.data['throughUtc'] as String? ?? '',
    );
    if (cutoff != null &&
        DateTime.now().toUtc().difference(cutoff) >
            const Duration(minutes: 14)) {
      await _load();
      return;
    }
    final epoch = ++_epoch;
    final days = _days;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final next = await loadSpeakingLeaderboardPages(
        loadPage: ({int offset = 0, String? until}) async {
          if (!mounted || epoch != _epoch || session.cacheKey != _owner) {
            throw StateError('Leaderboard request superseded');
          }
          return AuthApiClient.instance.speakingLeaderboard(
            accessToken: session.accessToken,
            days: days,
            configured: !_isAdmin,
            offset: offset,
            until: until,
          );
        },
        appendTo: _report!,
      );
      if (!mounted || epoch != _epoch || session.cacheKey != _owner) return;
      setState(() {
        _report = next;
        _canChoosePeriod = _isAdmin && next.data['canChoosePeriod'] == true;
      });
      if (!_isAdmin) {
        unawaited(
          LastSnapshotCache.leaderboard.save(session.cacheKey, next.data),
        );
      }
    } on AuthApiException catch (error) {
      if (mounted && epoch == _epoch) {
        if (days != 30 && error.statusCode == 403) {
          _canChoosePeriod = false;
          _selectPeriod(30, force: true);
        } else {
          setState(() => _failed = true);
        }
      }
    } catch (_) {
      if (mounted && epoch == _epoch) setState(() => _failed = true);
    } finally {
      if (mounted && epoch == _epoch) setState(() => _busy = false);
    }
  }

  Future<void> _openChat(Map<String, dynamic> row) async {
    if (!_canChoosePeriod ||
        AuthSessionNotifier.instance.session?.isAdmin != true ||
        row['isMe'] == true ||
        row['adminUserId'] is! String)
      return;
    final owner = _owner;
    final id = row['adminUserId'] as String;
    final existing = await ChatSessionNotifier.instance
        .directMessageThreadForUser(id);
    if (!mounted ||
        owner != _owner ||
        !_canChoosePeriod ||
        AuthSessionNotifier.instance.session?.isAdmin != true)
      return;
    final partner = ChatUserSummary.fromJson({...row, 'id': id});
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => existing == null
            ? ChatConversationScreen.directUser(partner: partner)
            : ChatConversationScreen.thread(thread: existing),
      ),
    );
  }

  void _selectPeriod(int days, {bool force = false}) {
    if ((!force &&
            (!_canChoosePeriod ||
                AuthSessionNotifier.instance.session?.isAdmin != true)) ||
        days == _days ||
        ![1, 7, 30].contains(days))
      return;
    _epoch++; // Discard old refresh and pagination responses, even during loading.
    setState(() {
      _days = days;
      _report = null;
      _busy = false;
      _failed = false;
    });
    unawaited(_load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _epoch++;
    AuthSessionNotifier.instance.removeListener(_accountChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SpeakingLeaderboardView(
    key: ValueKey('$_owner/$_days'),
    days: _days,
    onPeriodChanged:
        _canChoosePeriod &&
            AuthSessionNotifier.instance.session?.isAdmin == true
        ? _selectPeriod
        : null,
    onOpenChat:
        _canChoosePeriod &&
            AuthSessionNotifier.instance.session?.isAdmin == true
        ? _openChat
        : null,
    report: _report,
    loading: _busy && _report == null,
    failed: _failed,
    loadingMore: _busy && _report != null,
    onLoadMore: _loadMore,
    onRefresh: _load,
  );
}

class SpeakingLeaderboardView extends StatefulWidget {
  const SpeakingLeaderboardView({
    super.key,
    this.report,
    this.loading = false,
    this.failed = false,
    this.hasUpdate = false,
    this.loadingMore = false,
    this.onLoadMore,
    this.days = 30,
    this.onPeriodChanged,
    this.onOpenChat,
    required this.onRefresh,
  });
  final SpeakingReport? report;
  final bool loading, failed, hasUpdate, loadingMore;
  final int days;
  final ValueChanged<int>? onPeriodChanged;
  final Future<void> Function(Map<String, dynamic>)? onOpenChat;
  final Future<void> Function()? onLoadMore;
  final Future<void> Function() onRefresh;
  @override
  State<SpeakingLeaderboardView> createState() =>
      _SpeakingLeaderboardViewState();
}

class _SpeakingLeaderboardViewState extends State<SpeakingLeaderboardView> {
  final _scroll = ScrollController();
  final _rowKeys = <Object, GlobalKey<LeaderboardMotionRowState>>{};
  Map<Object, double?> _fromTops = {};
  int _motionRevision = 0;

  @override
  void didUpdateWidget(SpeakingLeaderboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onOpenChat != null && widget.onOpenChat == null) {
      _dismissConfirmation();
    }
    if (!identical(widget.report, oldWidget.report)) {
      _fromTops = {
        for (final entry in _rowKeys.entries)
          entry.key: entry.value.currentState?.visualTop,
      };
      _motionRevision++;
      final keys = widget.report?.rows.map((row) => row['key']).toSet() ?? {};
      _rowKeys.removeWhere((key, _) => !keys.contains(key));
    }
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_nearEnd);
  }

  void _nearEnd() {
    if (_scroll.hasClients &&
        _scroll.position.extentAfter < 200 &&
        !widget.loadingMore &&
        widget.report?.data['hasMore'] == true) {
      widget.onLoadMore?.call();
    }
  }

  @override
  void dispose() {
    _dismissConfirmation();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = Theme.of(context).colorScheme;
    final report = widget.report;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            56 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 2),
        title: Text(
          l.leaderboardTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: widget.onRefresh,
                child: ListView(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  children: [
                    if (widget.onPeriodChanged != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12, right: 10),
                            child: Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 20,
                              color: c.primary,
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                for (final days in [30, 7, 1])
                                  ChoiceChip(
                                    key: ValueKey('leaderboard-period-$days'),
                                    label: Text(
                                      days == 30
                                          ? l.wordActivityThirtyDays
                                          : days == 7
                                          ? l.wordActivitySevenDays
                                          : '24H',
                                    ),
                                    selected: widget.days == days,
                                    onSelected: (_) =>
                                        widget.onPeriodChanged!(days),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else if (report != null)
                      Text(
                        l.leaderboardPeriodScope(report.periodDays),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: c.primary,
                        ),
                      ),
                    const SizedBox(height: 6),
                    if (report != null)
                      Text(
                        report.range(l.localeName),
                        style: TextStyle(
                          fontSize: 13,
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      l.leaderboardEncouragement,
                      style: TextStyle(fontSize: 14, color: c.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    if (widget.loading)
                      const LinearProgressIndicator(minHeight: 2),
                    if (widget.failed)
                      _notice(l.leaderboardError, action: l.leaderboardRefresh),
                    if (widget.hasUpdate)
                      _notice(
                        l.leaderboardUpdate,
                        action: l.leaderboardRefresh,
                      ),
                    if (report != null) ...[
                      if (report.rows.isEmpty) _notice(l.leaderboardEmpty),
                      if (report.you['rank'] == null)
                        _notice(l.leaderboardNoActivity),
                      for (final row in report.rows)
                        LeaderboardMotionRow(
                          key: _rowKeys.putIfAbsent(
                            row['key'],
                            () => GlobalKey<LeaderboardMotionRowState>(),
                          ),
                          revision: _motionRevision,
                          fromTop: _fromTops[row['key']],
                          scrollOffset: () =>
                              _scroll.hasClients ? _scroll.offset : 0,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SpeakingLeaderboardRow(
                              row: row,
                              onTap:
                                  widget.onOpenChat != null &&
                                      row['isMe'] != true &&
                                      row['adminUserId'] is String
                                  ? () => _confirmChat(row)
                                  : null,
                            ),
                          ),
                        ),
                      if (report.data['hasMore'] == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: widget.loadingMore
                              ? Center(
                                  child: Semantics(
                                    label: l.leaderboardLoading,
                                    child: const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : TextButton(
                                  onPressed: widget.onLoadMore,
                                  child: Text(l.leaderboardLoadMore),
                                ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        report.data['throughUtc'] != null
                            ? l.leaderboardRollingFootnote
                            : report.periodDays == 30
                            ? l.leaderboardFootnote
                            : l.leaderboardPeriodFootnote,
                        style: TextStyle(
                          fontSize: 12,
                          color: c.onSurfaceVariant,
                        ),
                      ),
                      if (report.data['includesLegacyDates'] == true) ...[
                        const SizedBox(height: 8),
                        Text(
                          l.leaderboardLegacy,
                          style: TextStyle(
                            fontSize: 12,
                            color: c.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ] else if (!widget.failed) ...[
                      const SizedBox(height: 20),
                      for (var i = 0; i < 5; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Semantics(
                            label: l.leaderboardLoading,
                            child: Container(
                              height: 86,
                              decoration: BoxDecoration(
                                color: c.surfaceContainerHighest.withValues(
                                  alpha: .5,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _openingChat = false;
  ModalRoute<bool>? _confirmationRoute;
  void _dismissConfirmation() {
    final route = _confirmationRoute;
    _confirmationRoute = null;
    if (route == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = route.navigator;
      if (navigator != null && route.isActive)
        navigator.removeRoute(route, false);
    });
  }

  Future<void> _confirmChat(Map<String, dynamic> row) async {
    if (_openingChat || widget.onOpenChat == null) return;
    _openingChat = true;
    final l = AppLocalizations.of(context)!;
    final name =
        leaderboardFirstName(row['name'] as String?) ?? l.leaderboardLearner;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          _confirmationRoute = ModalRoute.of<bool>(context);
          return AlertDialog(
            scrollable: true,
            icon: Icon(
              Icons.admin_panel_settings_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(l.chatMessageAction),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileAvatar(
                  radius: 28,
                  imageUrl: row['avatarUrl'] as String?,
                ),
                const SizedBox(height: 16),
                Text(l.leaderboardOpenChat(name)),
                const SizedBox(height: 20),
                _personDetail(
                  l.leaderboardNativeLanguage,
                  _languageDetail(
                    row['nativeLanguage'],
                    row['nativeLanguageFlag'],
                    l,
                  ),
                ),
                _personDetail(
                  l.leaderboardLearningLanguage,
                  _languageDetail(
                    row['learningLanguage'],
                    row['learningLanguageFlag'],
                    l,
                  ),
                ),
                _personDetail(l.leaderboardIpCountry, _countryDetail(row, l)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.chatMessageAction),
              ),
            ],
          );
        },
      );
      if (confirmed == true && mounted) await widget.onOpenChat?.call(row);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.onboardingLoadFailed)));
    } finally {
      _confirmationRoute = null;
      _openingChat = false;
    }
  }

  Widget _personDetail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 3),
          Text(value, textDirection: TextDirection.ltr),
        ],
      ),
    ),
  );

  String _languageDetail(Object? code, Object? flag, AppLocalizations l) {
    if (code is! String ||
        !RegExp(
          r'^[a-zA-Z]{2,3}(?:[-_][a-zA-Z0-9]{2,8})*$',
        ).hasMatch(code.trim())) {
      return l.permissionStatusUnknown;
    }
    final label = languageCodeLabel(code);
    final emoji =
        _countryFlag(flag) ?? _countryFlag(learningLanguageLabel(code).flag);
    return emoji == null ? label : '$label $emoji';
  }

  String _countryDetail(Map<String, dynamic> row, AppLocalizations l) {
    final code = (row['ipCountryCode'] as String?)?.trim().toUpperCase();
    if (code == null ||
        !RegExp(r'^[A-Z]{2}$').hasMatch(code) ||
        ['XX', 'ZZ'].contains(code))
      return l.permissionStatusUnknown;
    final flag =
        _countryFlag(row['ipCountryFlag']) ??
        String.fromCharCodes(code.codeUnits.map((c) => c + 0x1F1E6 - 65));
    return '$code $flag';
  }

  String? _countryFlag(Object? value) {
    if (value is! String) return null;
    final runes = value.runes.toList();
    return runes.length == 2 && runes.every((r) => r >= 0x1F1E6 && r <= 0x1F1FF)
        ? value
        : null;
  }

  Widget _notice(String text, {String? action}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(liveRegion: true, child: Text(text)),
        if (action != null)
          TextButton(
            onPressed: widget.loading ? null : widget.onRefresh,
            child: Text(action),
          ),
      ],
    ),
  );
}

class SpeakingLeaderboardRow extends StatelessWidget {
  const SpeakingLeaderboardRow({super.key, required this.row, this.onTap});
  final Map<String, dynamic> row;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: UserProfileNotifier.instance,
    builder: (context, _) => _buildRow(context),
  );

  Widget _buildRow(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = Theme.of(context).colorScheme;
    final mine = row['isMe'] == true;
    final name = leaderboardFirstName(row['name'] as String?);
    final rank = row['rank'] as num?;
    final profile = UserProfileNotifier.instance;
    final ownProfile =
        mine &&
        profile.profile != null &&
        profile.profile!.id == AuthSessionNotifier.instance.session?.userId;
    final language = goalLearningLanguageLabel(
      ownProfile
          ? profile.learningLanguage
          : row['learningLanguage'] as String?,
    );
    final accent = mine
        ? c.primary
        : switch (rank?.toInt()) {
            1 =>
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFE4BF66)
                  : const Color(0xFF886514),
            2 =>
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFBFC7D6)
                  : const Color(0xFF667085),
            3 =>
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFDCA078)
                  : const Color(0xFF91603E),
            _ => c.onSurfaceVariant,
          };
    final content = LayoutBuilder(
      builder: (context, bounds) {
        final stacked =
            MediaQuery.textScalerOf(context).scale(16) > 22 ||
            bounds.maxWidth < 270;
        final total = AnimatedSpokenCount(
          key: ValueKey('leaderboard-total-${row['key']}'),
          fromZero: true,
          value: row['spokenWords'] as num,
          locale: l.localeName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: mine ? c.primary : c.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 34,
              child: Text(
                rank == null
                    ? '—'
                    : NumberFormat.decimalPattern(l.localeName).format(rank),
                key: ValueKey('leaderboard-rank-${row['key']}'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ProfileAvatar(
              key: ValueKey('leaderboard-avatar-${row['key']}'),
              radius: 19,
              imageUrl: row['avatarUrl'] as String?,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${name == null || name.isEmpty ? l.leaderboardLearner : name}${mine ? ' · ${l.leaderboardYou}' : ''}',
                    maxLines: stacked ? null : 2,
                    overflow: stacked ? null : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: c.onSurface,
                    ),
                  ),
                  if (language.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        language,
                        style: TextStyle(
                          fontSize: 12,
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (stacked)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: total,
                    ),
                ],
              ),
            ),
            if (!stacked) ...[const SizedBox(width: 8), total],
          ],
        );
      },
    );
    return Material(
      color: mine ? c.primary.withValues(alpha: .09) : c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: mine
              ? c.primary.withValues(alpha: .4)
              : c.outlineVariant.withValues(alpha: .6),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 14, 14, 14),
          child: content,
        ),
      ),
    );
  }
}
