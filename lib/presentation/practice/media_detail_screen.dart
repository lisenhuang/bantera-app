import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/auth_session_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../core/profile_stats_notifier.dart';
import '../../core/theme.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../shared/lesson_details_body.dart';
import 'practice_player_screen.dart';

class MediaDetailScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const MediaDetailScreen({super.key, required this.mediaItem});

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  bool? _isSaved;
  bool _savePending = false;
  bool _deleting = false;

  bool get _showsBanteraAiBranding =>
      widget.mediaItem.isAudioOnly &&
      widget.mediaItem.transcriptionSource.trim().toLowerCase() ==
          'ai generated';

  @override
  void initState() {
    super.initState();
    unawaited(_checkSaved());
  }

  Future<void> _checkSaved() async {
    final token = AuthSessionNotifier.instance.session?.accessToken;
    if (token == null) return;
    final saved = await AuthApiClient.instance.checkVideoSaved(
      accessToken: token,
      videoId: widget.mediaItem.id,
    );
    if (mounted) setState(() => _isSaved = saved);
  }

  Future<void> _toggleSave() async {
    final token = AuthSessionNotifier.instance.session?.accessToken;
    if (token == null) return;
    if (_savePending) return;

    setState(() => _savePending = true);
    try {
      if (_isSaved == true) {
        await AuthApiClient.instance.unsaveVideo(
          accessToken: token,
          videoId: widget.mediaItem.id,
        );
        if (mounted) setState(() => _isSaved = false);
        unawaited(ProfileStatsNotifier.instance.refresh());
      } else {
        await AuthApiClient.instance.saveVideo(
          accessToken: token,
          videoId: widget.mediaItem.id,
        );
        if (mounted) setState(() => _isSaved = true);
        unawaited(ProfileStatsNotifier.instance.refresh());
      }
    } catch (_) {
      // ignore network errors silently
    } finally {
      if (mounted) setState(() => _savePending = false);
    }
  }

  Future<void> _deleteDialogue() async {
    final session = AuthSessionNotifier.instance.session;
    if (session?.isAdmin != true || _deleting) return;
    final l = AppLocalizations.of(context)!;
    setState(() => _deleting = true);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.admin_panel_settings_outlined),
          title: Text(l.adminDeleteDialogue),
          content: Text(l.adminDeleteContentBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.deleteLabel),
            ),
          ],
        ),
      );
      if (confirmed != true ||
          !mounted ||
          AuthSessionNotifier.instance.session?.cacheKey != session!.cacheKey)
        return;
      await AuthApiClient.instance.deleteAdminContent(
        accessToken: session.accessToken,
        videoId: widget.mediaItem.id,
      );
      if (!mounted) return;
      unawaited(ProfileStatsNotifier.instance.refresh());
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.onboardingLoadFailed)));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.lessonDetailsTitle),
        actions: [
          if (AuthSessionNotifier.instance.session?.isAdmin == true &&
              widget.mediaItem.localVideoPath == null)
            PopupMenuButton<String>(
              enabled: !_deleting,
              tooltip: l10n.more,
              onSelected: (_) => _deleteDialogue(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings_outlined),
                      const SizedBox(width: 12),
                      Text(l10n.adminDeleteDialogue),
                    ],
                  ),
                ),
              ],
            ),
          if (_savePending)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(
                _isSaved == true ? Icons.bookmark : Icons.bookmark_border,
                color: _isSaved == true ? BanteraTheme.primaryColor : null,
              ),
              tooltip: _isSaved == true
                  ? l10n.lessonUnsaveTooltip
                  : l10n.lessonSaveTooltip,
              onPressed: AuthSessionNotifier.instance.session != null
                  ? _toggleSave
                  : null,
            ),
        ],
      ),
      body: LessonDetailsBody(
        mediaItem: widget.mediaItem,
        creatorName: _showsBanteraAiBranding ? 'Bantera AI' : null,
        creatorAvatar: _CreatorAvatar(
          avatarUrl: widget.mediaItem.creator.avatarUrl,
          showBanteraLogo: _showsBanteraAiBranding,
        ),
        onStartPractice: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PracticePlayerScreen(mediaItem: widget.mediaItem),
          ),
        ),
      ),
    );
  }
}

class _CreatorAvatar extends StatelessWidget {
  const _CreatorAvatar({required this.avatarUrl, this.showBanteraLogo = false});

  final String avatarUrl;
  final bool showBanteraLogo;

  @override
  Widget build(BuildContext context) {
    if (showBanteraLogo) {
      return const CircleAvatar(
        radius: 18,
        backgroundColor: Colors.transparent,
        backgroundImage: AssetImage('assets/icon.png'),
      );
    }

    final hasAvatar = avatarUrl.trim().isNotEmpty;
    return CircleAvatar(
      radius: 18,
      foregroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
      child: hasAvatar ? null : const Icon(Icons.person, size: 16),
    );
  }
}
