import 'dart:io';
import 'package:casarancha/app/utils/image_picker.dart';
import 'package:get/get.dart';
import 'package:video_compress/video_compress.dart';

class ChatMediaPickerHelper extends GetxController {
  final Rxn<File> selectedFile = Rxn<File>(null);
  final Rxn<File> thumbnailData = Rxn<File>();
  final RxBool showMediaPreview = false.obs;
  final RxList<File> multipleMediaSelected = <File>[].obs;

  bool isVideoFile(String path) {
    return path.toLowerCase().endsWith('.mp4') ||
        path.toLowerCase().endsWith('.mov') ||
        path.toLowerCase().endsWith('.avi') ||
        path.toLowerCase().endsWith('.wmv') ||
        path.toLowerCase().endsWith('.mkv');
  }

  String? getFileType(String path) {
    if (isVideoFile(path)) {
      return "video";
    } else if (!path.toLowerCase().endsWith('.aac') &&
        !path.toLowerCase().endsWith('.mp3') &&
        !path.toLowerCase().endsWith('.wav')) {
      return "image";
    }
    return null;
  }

  Future<void> pickImageFromGallery() async {
    final file = await pickImage();
    if (file != null) {
      selectedFile.value = file;
      showMediaPreview.value = true;
    }
  }

  Future<void> selectMultipleImages() async {
    final files = await pickMultipleImages();
    if (files == null) return;
    if (multipleMediaSelected.isEmpty) {
      multipleMediaSelected.value = files;
      showMediaPreview.value = true;
    } else {
      multipleMediaSelected.addAll(files);
      showMediaPreview.value = true;
    }
  }

  Future<void> pickVideoFromGallery() async {
    final file = await pickVideo();
    if (file == null) return;
    selectedFile.value = file;
    showMediaPreview.value = true;

    try {
      File? thumbnail = await VideoCompress.getFileThumbnail(
        file.path,
        quality: 100,
        position: -1,
      );
      thumbnailData.value = thumbnail;
    } catch (_) {}
  }

  void resetState() {
    selectedFile.value = null;
    thumbnailData.value = null;
    showMediaPreview.value = false;
    multipleMediaSelected.clear();
  }

  @override
  void dispose() {
    resetState();
    super.dispose();
  }
}
