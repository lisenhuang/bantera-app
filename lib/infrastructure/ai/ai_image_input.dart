import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

typedef PreparedAiImage = ({Uint8List bytes, String mime});

/// Local copies only: orient, strip metadata, then enforce the transport bound.
class AiImageInput {
  static const maxCount = 4;
  static const compressionThreshold = 256 * 1024;
  static const maxBytes = 1024 * 1024;
  static Future<PreparedAiImage> prepare(String path) async {
    final file = File(path);
    if (await file.length() > 25 * 1024 * 1024) {
      throw const FormatException('Image too large');
    }
    var bytes = await file.readAsBytes();
    if (bytes.length > compressionThreshold ||
        img.findDecoderForData(bytes) == null) {
      // Native downsampling avoids decoding a full 48 MP camera photo in Dart.
      // It also handles HEIC/HEIF; final longest-side sizing is shared.
      final converted = await FlutterImageCompress.compressWithFile(
        path,
        minWidth: 1080,
        minHeight: 1080,
        quality: 90,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
      if (converted == null) throw const FormatException('Unsupported image');
      bytes = converted;
      return compute(normalize, (bytes: bytes, forceJpeg: true));
    }
    return compute(normalize, (bytes: bytes, forceJpeg: false));
  }

  @visibleForTesting
  static PreparedAiImage normalize(({Uint8List bytes, bool forceJpeg}) input) {
    final decoder = img.findDecoderForData(input.bytes);
    final info = decoder?.startDecode(input.bytes);
    if (info == null || info.width * info.height > 40000000) {
      throw const FormatException('Unsupported image');
    }
    final decoded = decoder!.decodeFrame(0);
    if (decoded == null) throw const FormatException('Unsupported image');
    var image = img.bakeOrientation(decoded);
    final compress =
        input.forceJpeg ||
        input.bytes.length > compressionThreshold ||
        (decoder is! img.JpegDecoder && decoder is! img.PngDecoder);
    if (compress && (image.width > 1080 || image.height > 1080)) {
      image = img.copyResize(
        image,
        width: image.width >= image.height ? 1080 : null,
        height: image.height > image.width ? 1080 : null,
        interpolation: img.Interpolation.average,
      );
    }
    image.exif.clear();
    image.iccProfile = null;
    image.textData?.clear();
    final png = !compress && decoder is img.PngDecoder;
    var bytes = png
        ? img.encodePng(image)
        : img.encodeJpg(image, quality: compress ? 85 : 95);
    if (bytes.length > maxBytes) bytes = img.encodeJpg(image, quality: 65);
    if (bytes.length > maxBytes) throw const FormatException('Image too large');
    return (
      bytes: bytes,
      mime:
          png && bytes.length <= maxBytes && img.PngDecoder().isValidFile(bytes)
          ? 'image/png'
          : 'image/jpeg',
    );
  }
}
