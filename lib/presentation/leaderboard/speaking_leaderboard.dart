import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/word_activity_notifier.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../l10n/app_localizations.dart';
import '../shared/learning_language_label.dart';
import '../shared/profile_avatar.dart';

class SpeakingReport {
  SpeakingReport(this.data);
  final Map<String, dynamic> data;
  List<Map<String, dynamic>> get rows => (data['rows'] as List)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  Map<String, dynamic> get you => Map<String, dynamic>.from(data['you'] as Map);
  String get fingerprint => jsonEncode([
    rows.take((data['limit'] as int?) ?? 100).toList(),
    data['you'],
    data['fromDate'],
    data['throughDate'],
  ]);
  String range(String locale) {
    final format = DateFormat.yMMMd(locale);
    return '${format.format(DateTime.parse(data['fromDate']))} – ${format.format(DateTime.parse(data['throughDate']))} · UTC';
  }
}

class SpeakingLeaderboardCard extends StatefulWidget {
  const SpeakingLeaderboardCard({super.key, this.preview});
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
    _report = widget.preview;
    if (widget.preview == null) {
      AuthSessionNotifier.instance.addListener(_accountChanged);
      WordActivityNotifier.instance.addListener(_activityChanged);
      WidgetsBinding.instance.addObserver(this);
      unawaited(_load());
    }
  }

  void _activityChanged() {
    if (_refresh?.isActive == true) return;
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
    if (state == AppLifecycleState.resumed) _activityChanged();
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

  Future<void> _load() async {
    final session = AuthSessionNotifier.instance.session;
    final epoch = ++_epoch;
    _owner = session?.cacheKey;
    if (session == null) return;
    _lastLoad = DateTime.now();
    try {
      final report = SpeakingReport(
        await AuthApiClient.instance.speakingLeaderboard(
          accessToken: session.accessToken,
        ),
      );
      if (mounted &&
          epoch == _epoch &&
          _owner == AuthSessionNotifier.instance.session?.cacheKey) {
        setState(() {
          _report = report;
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted && epoch == _epoch) setState(() => _failed = true);
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
                    Icon(Icons.graphic_eq_rounded, color: c.primary),
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
                const SizedBox(height: 6),
                Text(
                  l.leaderboardScope,
                  style: TextStyle(fontSize: 13, color: c.onSurfaceVariant),
                ),
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

  Widget _metric(String value, String label, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
  SpeakingReport? _report, _pending;
  bool _busy = false, _failed = false;
  int _nextOffset = 100;
  Timer? _timer;
  String? _owner;
  int _epoch = 0;
  @override
  void initState() {
    super.initState();
    _owner = AuthSessionNotifier.instance.session?.cacheKey;
    AuthSessionNotifier.instance.addListener(_accountChanged);
    unawaited(_load());
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _load(quiet: true),
    );
  }

  void _accountChanged() {
    final owner = AuthSessionNotifier.instance.session?.cacheKey;
    if (owner == _owner) return;
    _owner = owner;
    _epoch++;
    setState(() {
      _report = null;
      _pending = null;
      _busy = false;
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
    setState(() {
      _busy = true;
      if (!quiet) _failed = false;
    });
    try {
      if (!quiet) await WordActivityNotifier.instance.sync();
      final next = SpeakingReport(
        await AuthApiClient.instance.speakingLeaderboard(
          accessToken: session.accessToken,
        ),
      );
      if (!mounted || epoch != _epoch || session.cacheKey != _owner) return;
      setState(() {
        if (quiet && _report != null) {
          _pending = next.fingerprint == _report!.fingerprint ? null : next;
        } else {
          _report = next;
          _nextOffset = ((next.data['offset'] as int?) ?? 0) + next.rows.length;
          _pending = null;
        }
        _failed = false;
      });
    } catch (_) {
      if (mounted && epoch == _epoch) setState(() => _failed = true);
    } finally {
      if (mounted && epoch == _epoch) setState(() => _busy = false);
    }
  }

  Future<void> _loadMore() async {
    if (_busy || _report?.data['hasMore'] != true) return;
    final session = AuthSessionNotifier.instance.session;
    if (session == null || session.cacheKey != _owner) return;
    final epoch = ++_epoch;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final next = SpeakingReport(
        await AuthApiClient.instance.speakingLeaderboard(
          accessToken: session.accessToken,
          offset: _nextOffset,
        ),
      );
      if (!mounted || epoch != _epoch || session.cacheKey != _owner) return;
      if (next.data['throughDate'] != _report!.data['throughDate']) {
        final fresh = SpeakingReport(
          await AuthApiClient.instance.speakingLeaderboard(
            accessToken: session.accessToken,
          ),
        );
        if (mounted && epoch == _epoch) setState(() => _pending = fresh);
        return;
      }
      final keys = _report!.rows.map((row) => row['key']).toSet();
      setState(() {
        _report = SpeakingReport({
          ..._report!.data,
          'rows': [
            ..._report!.rows,
            ...next.rows.where((row) => !keys.contains(row['key'])),
          ],
          'hasMore': next.data['hasMore'],
        });
        _nextOffset = (next.data['offset'] as int) + next.rows.length;
      });
    } catch (_) {
      if (mounted && epoch == _epoch) setState(() => _failed = true);
    } finally {
      if (mounted && epoch == _epoch) setState(() => _busy = false);
    }
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
    report: _report,
    loading: _busy && _report == null,
    failed: _failed,
    hasUpdate: _pending != null,
    loadingMore: _busy && _report != null,
    onLoadMore: _loadMore,
    onRefresh: () async {
      if (_pending != null) {
        setState(() {
          _report = _pending;
          _nextOffset = _pending!.rows.length;
          _pending = null;
        });
      } else {
        await _load();
      }
    },
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
    required this.onRefresh,
  });
  final SpeakingReport? report;
  final bool loading, failed, hasUpdate, loadingMore;
  final Future<void> Function()? onLoadMore;
  final Future<void> Function() onRefresh;
  @override
  State<SpeakingLeaderboardView> createState() =>
      _SpeakingLeaderboardViewState();
}

class _SpeakingLeaderboardViewState extends State<SpeakingLeaderboardView> {
  final _scroll = ScrollController();
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
                    Text(
                      l.leaderboardScope,
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
                        Padding(
                          key: ValueKey(row['key']),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SpeakingLeaderboardRow(row: row),
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
                        l.leaderboardFootnote,
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
  const SpeakingLeaderboardRow({super.key, required this.row});
  final Map<String, dynamic> row;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = Theme.of(context).colorScheme;
    final mine = row['isMe'] == true;
    final name = (row['name'] as String?)?.trim();
    final rank = row['rank'] as num?;
    final language = goalLearningLanguageLabel(
      row['learningLanguage'] as String?,
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
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, bounds) {
            final stacked =
                MediaQuery.textScalerOf(context).scale(16) > 22 ||
                bounds.maxWidth < 270;
            final identity = Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    rank == null
                        ? '—'
                        : NumberFormat.decimalPattern(
                            l.localeName,
                          ).format(rank),
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
                  radius: 19,
                  imageUrl: row['avatarUrl'] as String?,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${name == null || name.isEmpty ? l.leaderboardLearner : name}${mine ? ' · ${l.leaderboardYou}' : ''}',
                    maxLines: stacked ? null : 2,
                    overflow: stacked ? null : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: c.onSurface,
                    ),
                  ),
                ),
              ],
            );
            final total = Text(
              NumberFormat.decimalPattern(
                l.localeName,
              ).format(row['spokenWords']),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: mine ? c.primary : c.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            );
            return stacked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      identity,
                      Padding(
                        padding: const EdgeInsets.only(left: 90, top: 8),
                        child: total,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: identity),
                      const SizedBox(width: 8),
                      total,
                    ],
                  );
          },
        ),
        if (language.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 90, top: 6),
            child: Text(
              l.wordActivityLearningLanguage(language),
              style: TextStyle(fontSize: 12, color: c.onSurfaceVariant),
            ),
          ),
      ],
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 14, 14, 14),
        child: content,
      ),
    );
  }
}
