import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/chat_session_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../chats/chat_conversation_screen.dart';
import 'word_activity_image_encoder.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/activity/word_activity.dart';
import '../../core/auth_session_notifier.dart';
import '../../l10n/app_localizations.dart';
import 'word_activity_share_card.dart';
import '../shared/learning_language_label.dart';

class WordActivityShareScreen extends StatefulWidget {
  const WordActivityShareScreen({
    super.key,
    required this.name,
    required this.today,
    required this.week,
    required this.total,
    this.avatarUrl,
    this.avatarPath,
    this.learningLanguage,
  });
  final String name;
  final WordTotals today;
  final WordTotals week;
  final WordTotals total;
  final String? avatarUrl;
  final String? avatarPath;
  final String? learningLanguage;

  @override
  State<WordActivityShareScreen> createState() =>
      _WordActivityShareScreenState();
}

class _WordActivityShareScreenState extends State<WordActivityShareScreen> {
  final _captureKey = GlobalKey();
  static const _photos = MethodChannel('bantera/photos');
  ImageProvider? _avatar;
  bool _preparing = true;
  bool _busy = false;
  bool _started = false;
  bool _assetError = false;
  String? _ownerId;
  String? _nativeLanguage;
  Uint8List? _cachedJpeg;

  @override
  void initState() {
    super.initState();
    _ownerId = AuthSessionNotifier.instance.session?.userId;
    _nativeLanguage = UserProfileNotifier.instance.nativeLanguage;
    AuthSessionNotifier.instance.addListener(_accountChanged);
  }

  void _accountChanged() {
    if (_ownerId == AuthSessionNotifier.instance.session?.userId) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    AuthSessionNotifier.instance.removeListener(_accountChanged);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _prepare();
    }
  }

  Future<void> _prepare() async {
    var failed = false;
    for (final asset in [
      WordActivityShareCard.backgroundAsset,
      WordActivityShareCard.qrAsset,
      'assets/icon.png',
    ]) {
      if (!mounted) return;
      await precacheImage(
        AssetImage(asset),
        context,
        onError: (_, _) {
          failed = true;
        },
      );
    }
    ImageProvider? avatar;
    final path = widget.avatarPath;
    final url = widget.avatarUrl;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      avatar = FileImage(File(path));
    } else if (url != null && url.isNotEmpty) {
      avatar = NetworkImage(url);
    }
    if (avatar != null && mounted) {
      var avatarFailed = false;
      try {
        await precacheImage(
          avatar,
          context,
          onError: (_, _) {
            avatarFailed = true;
          },
        ).timeout(const Duration(seconds: 8));
      } catch (_) {
        avatarFailed = true;
      }
      if (avatarFailed) avatar = null;
    }
    if (mounted) {
      setState(() {
        _avatar = avatar;
        _assetError = failed;
        _preparing = false;
      });
    }
  }

  Future<Uint8List> _jpeg() async {
    if (_cachedJpeg != null) return _cachedJpeg!;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) throw StateError('Preview closed');
    final boundary =
        _captureKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Image export failed');
      final encoded = await compute(
        encodeWordActivityJpeg,
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      _cachedJpeg = encoded;
      return encoded;
    } finally {
      image.dispose();
    }
  }

  Future<void> _export({required bool save, Rect? origin}) async {
    if (_busy || _preparing || _assetError) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await _jpeg();
      if (!mounted ||
          _ownerId != AuthSessionNotifier.instance.session?.userId) {
        return;
      }
      if (save) {
        await _photos.invokeMethod<void>('saveImage', {'bytes': bytes});
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.wordActivitySaved)));
        }
      } else {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(bytes, mimeType: 'image/jpeg')],
            fileNameOverrides: ['bantera-word-progress.jpg'],
            sharePositionOrigin: origin,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is PlatformException && error.code == 'permission_denied'
                  ? l10n.wordActivityPhotoPermission
                  : save
                  ? l10n.wordActivitySaveFailed
                  : l10n.wordActivityShareFailed,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareToGroup(String groupKind, String language) async {
    if (_busy || _preparing || _ownerId == null || language.isEmpty) {
      return;
    }
    setState(() => _busy = true);
    Directory? temp;
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await _jpeg();
      if (!mounted ||
          _ownerId != AuthSessionNotifier.instance.session?.userId) {
        return;
      }
      temp = await Directory.systemTemp.createTemp('bantera-group-share-');
      final file = await File(
        '${temp.path}/achievement.jpg',
      ).writeAsBytes(bytes);
      final chat = ChatSessionNotifier.instance;
      final message = await chat.sendGroupImage(
        imageFile: file,
        language: language,
        groupKind: groupKind,
        ownerId: _ownerId!,
      );
      if (!mounted ||
          _ownerId != AuthSessionNotifier.instance.session?.userId) {
        return;
      }
      final groups = await chat.watchGroups().first;
      if (!mounted) return;
      final thread = groups
          .where((group) => group.threadId == message.threadId)
          .firstOrNull;
      if (thread != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => ChatConversationScreen.thread(thread: thread),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.wordActivitySentToGroup)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.wordActivityShareFailed)));
      }
    } finally {
      if (temp != null) {
        try {
          await temp.delete(recursive: true);
        } catch (_) {}
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = !_busy && !_preparing && !_assetError;
    final preview = _preparing
        ? const CircularProgressIndicator()
        : _assetError
        ? Text(l10n.wordActivityShareFailed)
        : AspectRatio(
            aspectRatio: 9 / 16,
            child: FittedBox(
              fit: BoxFit.contain,
              child: RepaintBoundary(
                key: _captureKey,
                child: WordActivityShareCard(
                  name: widget.name,
                  learningLanguage: widget.learningLanguage,
                  avatar: _avatar,
                  today: widget.today,
                  week: widget.week,
                  total: widget.total,
                ),
              ),
            ),
          );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wordActivityPreview)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: preview),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  Builder(
                    builder: (buttonContext) => FilledButton.icon(
                      onPressed: enabled
                          ? () {
                              final box =
                                  buttonContext.findRenderObject()!
                                      as RenderBox;
                              _export(
                                save: false,
                                origin:
                                    box.localToGlobal(Offset.zero) & box.size,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.ios_share),
                      label: Text(l10n.wordActivityShare),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: enabled ? () => _export(save: true) : null,
                    icon: const Icon(Icons.download_outlined),
                    label: Text(l10n.wordActivitySavePhotos),
                  ),
                  if (_ownerId != null)
                    for (final destination in [
                      (kind: 'learning', language: widget.learningLanguage),
                      (kind: 'native', language: _nativeLanguage),
                    ])
                      if (learningLanguageLabel(
                        destination.language,
                      ).name.isNotEmpty)
                        OutlinedButton.icon(
                          key: ValueKey('share-${destination.kind}-group'),
                          onPressed: enabled
                              ? () => _shareToGroup(
                                  destination.kind,
                                  destination.language!,
                                )
                              : null,
                          icon: Text(
                            learningLanguageLabel(destination.language).flag,
                          ),
                          label: Text(
                            '${learningLanguageLabel(destination.language).name} ${l10n.chatGroupLabel}',
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
