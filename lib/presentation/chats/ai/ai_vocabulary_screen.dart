import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/auth_session_notifier.dart';
import '../../../infrastructure/ai/ai_vocabulary.dart';
import '../../../l10n/app_localizations.dart';

class AiVocabularyScreen extends StatefulWidget {
  const AiVocabularyScreen({super.key, this.repository});
  final AiVocabulary? repository;
  @override
  State<AiVocabularyScreen> createState() => _AiVocabularyScreenState();
}

class _AiVocabularyScreenState extends State<AiVocabularyScreen> {
  late final _store =
      widget.repository ??
      AiVocabulary(AuthSessionNotifier.instance.session!.cacheKey);
  List<VocabularyWord>? _words;
  String _query = '';
  bool _dueOnly = false, _oldest = false, _failed = false, _loading = false;
  @override
  void initState() {
    super.initState();
    AiVocabulary.changes.addListener(_changed);
    AuthSessionNotifier.instance.addListener(_changed);
    unawaited(_load());
  }

  @override
  void dispose() {
    AiVocabulary.changes.removeListener(_changed);
    AuthSessionNotifier.instance.removeListener(_changed);
    super.dispose();
  }

  void _changed() => unawaited(_load());
  Future<void> _load() async {
    if (_loading) return;
    _loading = true;
    try {
      final words = await _store.words();
      if (mounted) {
        setState(() {
          _words = words;
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _words = null;
          _failed = true;
        });
      }
    } finally {
      _loading = false;
    }
  }

  String _date(DateTime date) => DateFormat.yMMMd(
    Localizations.localeOf(context).toString(),
  ).format(date.toLocal());
  void _error() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.onboardingLoadFailed),
        ),
      );
    }
  }

  Future<void> _review(VocabularyWord word) async {
    try {
      final result = await _store.execute({'action': 'review', 'id': word.id});
      if (result['ok'] != true) {
        _error();
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.vocabReviewed)),
        );
      }
      await _load();
    } catch (_) {
      _error();
    }
  }

  Future<void> _delete(VocabularyWord word) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.vocabRemove),
        content: Text(word.word),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.deleteLabel),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      final result = await _store.execute({'action': 'remove', 'id': word.id});
      if (result['ok'] != true) _error();
      await _load();
    } catch (_) {
      _error();
    }
  }

  Future<void> _edit([VocabularyWord? entry]) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _WordEditor(store: _store, entry: entry),
    );
    await _load();
  }

  Future<void> _detail(VocabularyWord word) async {
    final l = AppLocalizations.of(context)!;
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word.word,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(word.meaning, style: Theme.of(context).textTheme.bodyLarge),
              if (word.example.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    word.example,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                '${word.language} · ${l.vocabLearned} ${_date(word.learnedAt)}',
              ),
              if (word.reviewedAt != null)
                Text('${l.vocabReviewed}: ${_date(word.reviewedAt!)}'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context, 'review'),
                  icon: const Icon(Icons.check),
                  label: Text(l.vocabMarkReviewed),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context, 'edit'),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l.vocabEdit),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context, 'delete'),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l.deleteLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (result == 'edit') await _edit(word);
    if (result == 'delete') await _delete(word);
    if (result == 'review') await _review(word);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final now = DateTime.now();
    final all = _words ?? [];
    final dueCount = all.where((w) => !w.dueAt.isAfter(now)).length;
    var visible = all
        .where(
          (w) =>
              (!_dueOnly || !w.dueAt.isAfter(now)) &&
              '${w.word} ${w.meaning} ${w.language}'.toLowerCase().contains(
                _query.toLowerCase(),
              ),
        )
        .toList();
    if (_oldest) visible = visible.reversed.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(l.vocabTitle),
        actions: [
          IconButton(
            onPressed: _failed ? null : () => _edit(),
            icon: const Icon(Icons.add),
            tooltip: l.vocabAdd,
          ),
        ],
      ),
      body: _failed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.onboardingLoadFailed),
                  TextButton(
                    onPressed: _load,
                    child: Text(l.permissionsRefresh),
                  ),
                ],
              ),
            )
          : _words == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${all.length}',
                                        style: theme.textTheme.displaySmall
                                            ?.copyWith(
                                              color: colors.onPrimaryContainer,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      Text(
                                        l.vocabSaved,
                                        style: TextStyle(
                                          color: colors.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.auto_stories_outlined,
                                      color: colors.onPrimaryContainer,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '$dueCount ${l.vocabDue}',
                                      style: TextStyle(
                                        color: colors.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(l.vocabHelp, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 16),
                          TextField(
                            onChanged: (value) =>
                                setState(() => _query = value),
                            decoration: InputDecoration(
                              hintText: l.vocabSearch,
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              ChoiceChip(
                                label: Text(l.vocabAll),
                                selected: !_dueOnly,
                                onSelected: (_) =>
                                    setState(() => _dueOnly = false),
                              ),
                              ChoiceChip(
                                label: Text(l.vocabDue),
                                selected: _dueOnly,
                                onSelected: (_) =>
                                    setState(() => _dueOnly = true),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.swap_vert, size: 18),
                                label: Text(
                                  _oldest ? l.vocabOldest : l.vocabNewest,
                                ),
                                onPressed: () =>
                                    setState(() => _oldest = !_oldest),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (visible.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.bookmark_border_rounded,
                              size: 56,
                              color: colors.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              all.isEmpty ? l.vocabEmpty : l.vocabNoMatches,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final word = visible[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            margin: EdgeInsets.zero,
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => _detail(word),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            word.word,
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      word.meaning,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      '${word.language} · ${l.vocabLearned} ${_date(word.learnedAt)}',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
                      child: Text(
                        l.vocabPrivacy,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _WordEditor extends StatefulWidget {
  const _WordEditor({required this.store, this.entry});
  final AiVocabulary store;
  final VocabularyWord? entry;
  @override
  State<_WordEditor> createState() => _WordEditorState();
}

class _WordEditorState extends State<_WordEditor> {
  final _form = GlobalKey<FormState>();
  late final _word = TextEditingController(text: widget.entry?.word);
  late final _meaning = TextEditingController(text: widget.entry?.meaning);
  late final _example = TextEditingController(text: widget.entry?.example);
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _word.dispose();
    _meaning.dispose();
    _example.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await widget.store.execute({
        'action': widget.entry == null ? 'add' : 'update',
        if (widget.entry != null) 'id': widget.entry!.id,
        'word': _word.text,
        'meaning': _meaning.text,
        'example': _example.text,
      });
      if (!mounted) return;
      if (result['ok'] == true) {
        Navigator.pop(context);
        return;
      }
      setState(
        () => _error = result['alreadySaved'] == true
            ? AppLocalizations.of(context)!.vocabDuplicate
            : AppLocalizations.of(context)!.onboardingLoadFailed,
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context)!.onboardingLoadFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text(widget.entry == null ? l.vocabAdd : l.vocabEdit),
        scrollable: true,
        content: SizedBox(
          width: 440,
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _word,
                  maxLength: 100,
                  enabled: !_saving,
                  decoration: InputDecoration(labelText: l.vocabWord),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l.vocabRequired : null,
                ),
                TextFormField(
                  controller: _meaning,
                  maxLength: 600,
                  minLines: 2,
                  maxLines: 4,
                  enabled: !_saving,
                  decoration: InputDecoration(labelText: l.vocabMeaning),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l.vocabRequired : null,
                ),
                TextFormField(
                  controller: _example,
                  maxLength: 600,
                  minLines: 1,
                  maxLines: 3,
                  enabled: !_saving,
                  decoration: InputDecoration(labelText: l.vocabExample),
                ),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l.saveLabel),
          ),
        ],
      ),
    );
  }
}
