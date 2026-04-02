import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ProfileImageOptimizer {
  ProfileImageOptimizer._();

  static const int maxDimension = 256;

  static Future<File> optimize(File sourceFile) async {
    final formatSpec = _formatForPath(sourceFile.path);
    if (formatSpec == null) {
      return sourceFile;
    }

    final originalLength = await sourceFile.length();
    final targetFile = await _targetFile(formatSpec.targetExtension);

    try {
      final compressed = await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        targetFile.path,
        minWidth: maxDimension,
        minHeight: maxDimension,
        quality: formatSpec.quality,
        format: formatSpec.format,
        keepExif: false,
      );

      if (compressed == null) {
        return sourceFile;
      }

      final compressedFile = File(compressed.path);
      final compressedLength = await compressedFile.length();
      return compressedLength < originalLength ? compressedFile : sourceFile;
    } on UnsupportedError {
      return sourceFile;
    } catch (_) {
      return sourceFile;
    }
  }

  static _ImageFormatSpec? _formatForPath(String path) {
    final extension = _normalizedExtension(path);
    return switch (extension) {
      'jpg' => const _ImageFormatSpec(
        format: CompressFormat.jpeg,
        quality: 82,
        targetExtension: 'jpg',
      ),
      'jpeg' => const _ImageFormatSpec(
        format: CompressFormat.jpeg,
        quality: 82,
        targetExtension: 'jpeg',
      ),
      'png' => const _ImageFormatSpec(
        format: CompressFormat.png,
        quality: 100,
        targetExtension: 'png',
      ),
      'webp' => const _ImageFormatSpec(
        format: CompressFormat.webp,
        quality: 80,
        targetExtension: 'webp',
      ),
      'heic' => const _ImageFormatSpec(
        format: CompressFormat.heic,
        quality: 70,
        targetExtension: 'heic',
      ),
      'heif' => const _ImageFormatSpec(
        format: CompressFormat.heic,
        quality: 70,
        targetExtension: 'heif',
      ),
      _ => null,
    };
  }

  static String _normalizedExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == path.length - 1) {
      return '';
    }

    return path.substring(dotIndex + 1).toLowerCase();
  }

  static Future<File> _targetFile(String extension) async {
    final directory = await getTemporaryDirectory();
    final filename =
        'bantera-profile-${DateTime.now().microsecondsSinceEpoch}.$extension';
    return File('${directory.path}/$filename');
  }
}

class _ImageFormatSpec {
  const _ImageFormatSpec({
    required this.format,
    required this.quality,
    required this.targetExtension,
  });

  final CompressFormat format;
  final int quality;
  final String targetExtension;
}
