import 'dart:typed_data';
import 'package:app/infrastructure/ai/ai_image_input.dart';
import 'package:app/infrastructure/ai/ai_image_search.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('large input becomes JPEG, <=1080 longest side, without metadata', () {
    final source = img.Image(width: 1800, height: 900);
    source.textData = {'Description': 'Private metadata'};
    final png = img.encodePng(source);
    final large = Uint8List(300 * 1024)..setAll(0, png);
    final prepared = AiImageInput.normalize((bytes: large, forceJpeg: false));
    final result = img.decodeJpg(prepared.bytes)!;
    expect(prepared.mime, 'image/jpeg');
    expect([result.width, result.height], [1080, 540]);
    expect(result.exif.isEmpty, true);
    expect(prepared.bytes.length, lessThanOrEqualTo(AiImageInput.maxBytes));
  });
  test('small PNG keeps its dimensions, format and pixels; no enlargement', () {
    final original = img.Image(width: 80, height: 120);
    original.setPixelRgb(10, 20, 12, 34, 56);
    final prepared = AiImageInput.normalize((
      bytes: img.encodePng(original),
      forceJpeg: false,
    ));
    final image = img.decodePng(prepared.bytes)!;
    expect(prepared.mime, 'image/png');
    expect([image.width, image.height], [80, 120]);
    expect(image.getPixel(10, 20).r, 12);
    final converted = AiImageInput.normalize((
      bytes: img.encodePng(original),
      forceJpeg: true,
    ));
    expect(img.decodeJpg(converted.bytes)!.width, 80);
  });
  test(
    'invalid data rejected; local attachments survive message serialization',
    () {
      expect(
        () => AiImageInput.normalize((bytes: Uint8List(20), forceJpeg: false)),
        throwsFormatException,
      );
      const image = AiImageAttachment(
        title: 'Image',
        url: '',
        sourceUrl: '',
        author: '',
        license: '',
        mime: 'image/jpeg',
        file: 'abc-123.jpg',
        userAttached: true,
      );
      final message = AiMessage(role: 'user', images: [image], failed: true);
      final restored = AiMessage.fromJson(message.toJson());
      expect(restored.images.single.file, 'abc-123.jpg');
      expect(restored.images.single.userAttached, true);
      expect(
        AiImageAttachment.fromJson({
          ...image.toJson(),
          'file': '../secret.jpg',
        }),
        null,
      );
      expect(
        AiImageAttachment.fromJson({...image.toJson(), 'userAttached': false}),
        null,
      );
    },
  );
}
