import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<Uint8List?> generateThumbnail(String videoUrl) async {
  return await VideoThumbnail.thumbnailData(
    video: videoUrl,
    imageFormat: ImageFormat.JPEG,
    // maxWidth: 500, // Thumbnail width
    quality: 100,
  );
}
