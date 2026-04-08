import 'package:flutter/material.dart';

import '../../core/user_profile_notifier.dart';
import '../../infrastructure/video_processing_service.dart';
import '../shared/locale_flag.dart';

class LearningLanguageSetupScreen extends StatefulWidget {
  const LearningLanguageSetupScreen({super.key});

  @override
  State<LearningLanguageSetupScreen> createState() =>
      _LearningLanguageSetupScreenState();
}

class _LearningLanguageSetupScreenState
    extends State<LearningLanguageSetupScreen> {
  List<TranscriptionLocaleOption>? _locales;
  bool _isLoading = true;
  String? _error;
  String _searchText = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadLocales();
  }

  Future<void> _loadLocales() async {
    try {
      final locales =
          await VideoProcessingService.instance.fetchSupportedLocales();
      if (!mounted) return;
      setState(() {
        _locales = locales.where((o) => o.identifier != 'zh-TW').toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectLocale(TranscriptionLocaleOption locale) async {
    setState(() => _isSaving = true);
    final ok =
        await UserProfileNotifier.instance.updateLearningLanguage(locale.identifier);
    if (mounted) setState(() => _isSaving = false);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            UserProfileNotifier.instance.errorMessage ?? 'Failed to save.',
          ),
        ),
      );
    }
  }

  List<TranscriptionLocaleOption> get _filtered {
    final all = _locales ?? [];
    if (_searchText.isEmpty) return all;
    final q = _searchText.toLowerCase();
    return all
        .where((l) =>
            l.displayName.toLowerCase().contains(q) ||
            l.identifier.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                'What language are\nyou learning?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We'll use this to show you the right content.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (v) => setState(() => _searchText = v),
                decoration: InputDecoration(
                  hintText: 'Search languages…',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading || _isSaving) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: Colors.red.shade700)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadLocales();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final items = _filtered;
    if (items.isEmpty) {
      return const Center(child: Text('No matching languages.'));
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final locale = items[index];
        final flag = flagEmojiForLocale(locale.identifier);
        return ListTile(
          leading: Text(flag, style: const TextStyle(fontSize: 24)),
          title: Text(locale.displayName),
          subtitle: Text(
            locale.identifier,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () => _selectLocale(locale),
        );
      },
    );
  }
}
