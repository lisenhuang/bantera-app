import 'dart:typed_data';
import 'package:image/image.dart' as img;

Uint8List encodeWordActivityJpeg(Uint8List png) {
  final decoded = img.decodePng(png);
  if (decoded == null) throw StateError('Image export failed');
  return img.encodeJpg(decoded, quality: 94, chroma: img.JpegChroma.yuv444);
}
