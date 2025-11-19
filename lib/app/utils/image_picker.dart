import 'dart:io';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<File?> pickImage({ImageSource? imageSource}) async {
  final pickedFile = await ImagePicker().pickImage(
    source: imageSource ?? ImageSource.gallery,
    imageQuality: 50,
  );
  if (pickedFile != null) {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
      dir.path,
      "${DateTime.now().millisecondsSinceEpoch}_${path.basename(pickedFile.path)}",
    );

    // Compress further
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      pickedFile.path,
      targetPath,
      quality: 50,
    );

    if (compressedFile != null) {
      return File(compressedFile.path);
    }
  }
  return null;
}

Future<File?> pickAudio() async {
  final pickedFile = await ImagePicker().pickMedia();
  if (pickedFile != null) {
    return File(pickedFile.path);
  }
  return null;
}

Future<List<File>?> pickMultipleImages() async {
  try {
    final picker = ImagePicker();
    List<XFile> pickedFiles = await picker.pickMultiImage(limit: 10);

    if (pickedFiles.isNotEmpty) {
      List<File> compressedFiles = [];

      for (var file in pickedFiles) {
        final dir = await getTemporaryDirectory();
        final targetPath = path.join(
          dir.path,
          "${DateTime.now().millisecondsSinceEpoch}.jpg",
        );

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          file.path,
          targetPath,
          quality: 65,
        );

        if (compressedFile != null) {
          compressedFiles.add(File(compressedFile.path));
        }
      }

      return compressedFiles;
    }
    return null;
  } catch (e) {
    debugPrint('Error picking multiple images: $e');
    return null;
  }
}

Future<List<File>?> pickNoCompressedImages() async {
  try {
    final picker = ImagePicker();
    List<XFile> pickedFiles = await picker.pickMultiImage(limit: 5);

    if (pickedFiles.isNotEmpty) {
      List<File> files = [];

      for (var file in pickedFiles) {
        files.add(File(file.path));
      }

      return files;
    }
    return null;
  } catch (e) {
    debugPrint('Error picking multiple images: $e');
    return null;
  }
}

Future<File?> pickVideo() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      compressionQuality: 50,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }

    // final pickedFile = await ImagePicker().pickVideo(
    //   source: ImageSource.gallery,
    // );

    // if (pickedFile != null) {
    //   final compressedVideo = await VideoCompress.compressVideo(
    //     pickedFile.path,
    //     quality: VideoQuality.MediumQuality,
    //     deleteOrigin: false,
    //   );

    //   return compressedVideo?.file;
    // }

    return null;
  } catch (e) {
    CustomSnackbar.showErrorToast("Failed to pick and compress video, Select new file");
    debugPrint(e.toString());
  }
  return null;
}

Future<File?> pickMp3Audio() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['mp3'], // only mp3
    compressionQuality: 50,
  );

  if (result != null && result.files.single.path != null) {
    return File(result.files.single.path!);
  }
  return null;
}
