import 'dart:io';

FileType? getFileType(File file) {
  if (file.path.endsWith('.mp3')) return FileType.music;
  if (file.path.endsWith('.mp4')) return FileType.video;
  if (file.path.endsWith('.mov')) return FileType.video;
  if (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg')) return FileType.image;
  if (file.path.endsWith('.png')) return FileType.image;
  return null;
}

String getMimeType(String filePath) {
  if (filePath.endsWith('.mp4')) return 'video/mp4';
  if (filePath.endsWith('.mov')) return 'video/quicktime';
  if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg')) return 'image/jpeg';
  if (filePath.endsWith('.png')) return 'image/png';
  return 'application/octet-stream';
}


FileType getMediaType(String path) {
  if (path.contains('.mp3')) return FileType.music;
  if (path.contains('.mp4')) return FileType.video;
  if (path.contains('.mov')) return FileType.video;
  if (path.contains('.jpg') || path.contains('.jpeg')) return FileType.image;
  if (path.contains('.png')) return FileType.image;
  return FileType.image;
}

enum FileType {
  image,
  video,
  music,
}