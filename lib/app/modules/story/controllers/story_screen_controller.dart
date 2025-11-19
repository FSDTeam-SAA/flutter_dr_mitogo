import 'dart:io';
import 'package:casarancha/app/utils/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoryScreenController extends GetxController {
  final TextEditingController descriptionController = TextEditingController();
  final RxList<File> selectedMedia = <File>[].obs;

  Future<void> selectImage() async {
    final File? file = await pickImage();
    if (file != null) {
      selectedMedia.add(File(file.path));
    }
  }

  Future<void> selectVideo() async {
    final File? file = await pickVideo();
    if (file != null) {
      selectedMedia.add(File(file.path));
    }
  }

  void removeMedia(int index) {
    selectedMedia.removeAt(index);
  }

  

  @override
  void dispose() {
    descriptionController.clear();
    super.dispose();
  }
}
