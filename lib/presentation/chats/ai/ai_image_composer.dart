import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../infrastructure/ai/ai_history_store.dart';
import '../../../infrastructure/ai/ai_image_input.dart';
import '../../../l10n/app_localizations.dart';
import 'ai_chat_controller.dart';
import 'ai_image_cards.dart';

/// Attachment UI exists only in the AI composer, never the DM composer.
class AiImageComposer extends StatefulWidget {
  const AiImageComposer({super.key, required this.chat, required this.child});
  final AiChatController chat;
  final Widget child;
  @override
  State<AiImageComposer> createState() => _AiImageComposerState();
}

class _AiImageComposerState extends State<AiImageComposer> {
  bool _picking = false;
  Future<void> _pick() async {
    final chat = widget.chat;
    if (_picking || !chat.canEditImages) return;
    setState(() => _picking = true);
    final l = AppLocalizations.of(context)!;
    try {
      final source = await showModalBottomSheet<int>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l.aiAttachmentHint),
              ),
              for (final item in [
                (Icons.camera_alt_outlined, l.aiCamera),
                (Icons.photo_library_outlined, l.aiPhotos),
                (Icons.folder_open, l.aiFiles),
              ].indexed)
                ListTile(
                  leading: Icon(item.$2.$1),
                  title: Text(item.$2.$2),
                  onTap: () => Navigator.pop(context, item.$1),
                ),
            ],
          ),
        ),
      );
      if (source == null || !mounted || !chat.canEditImages) return;
      final room = AiImageInput.maxCount - chat.draftImages.length;
      if (room <= 0) return;
      List<String> paths;
      switch (source) {
        case 0:
          final file = await ImagePicker().pickImage(
            source: ImageSource.camera,
            requestFullMetadata: false,
          );
          paths = file == null ? [] : [file.path];
        case 1:
          // image_picker requires a limit >= 2; one remaining slot uses single selection.
          if (room == 1) {
            final file = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              requestFullMetadata: false,
            );
            paths = file == null ? [] : [file.path];
          } else {
            paths = (await ImagePicker().pickMultiImage(
              limit: room,
              requestFullMetadata: false,
            )).map((f) => f.path).toList();
          }
        default:
          paths = (await openFiles(
            acceptedTypeGroups: [
              const XTypeGroup(
                label: 'Images',
                extensions: ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'],
                uniformTypeIdentifiers: ['public.image'],
                mimeTypes: ['image/*'],
              ),
            ],
          )).map((f) => f.path).toList();
      }
      if (!mounted || !chat.canEditImages) return;
      if (paths.length > room) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.aiAttachmentHint)));
      }
      await chat.attachImages(paths.take(room).toList());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.aiAttachmentError)));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final l = AppLocalizations.of(context)!;
    final images = chat.draftImages;
    final canEdit = !_picking && chat.canEditImages;
    final colors = Theme.of(context).colorScheme;
    final preparing = _picking || chat.preparingImages;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final image = images[index];
                        return SizedBox(
                          width: 84,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () => AiImageCards(
                                      message: AiMessage(role: 'user'),
                                      path: chat.store.path,
                                    ).openPreview(context, image),
                                    child: Image.file(
                                      File(chat.store.path(image.file!)),
                                      fit: BoxFit.cover,
                                      cacheWidth: 180,
                                      semanticLabel:
                                          '${l.aiImages} ${index + 1}',
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton.filledTonal(
                                  tooltip: l.aiRemoveImage,
                                  onPressed: canEdit
                                      ? () => chat.removeDraftImage(image)
                                      : null,
                                  icon: Icon(
                                    canEdit ? Icons.close : Icons.lock_outline,
                                    size: 16,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (!chat.canEditImages && !chat.preparingImages)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l.aiAttachmentLocked,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: IgnorePointer(ignoring: preparing, child: widget.child),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                tooltip: l.aiAttachImages,
                style: IconButton.styleFrom(
                  fixedSize: const Size.square(48),
                  shape: const CircleBorder(),
                ),
                onPressed:
                    !preparing &&
                        canEdit &&
                        images.length < AiImageInput.maxCount
                    ? _pick
                    : null,
                icon: preparing
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
