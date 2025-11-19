import 'dart:io';

import 'package:casarancha/app/utils/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class VerificationController extends GetxController {
  RxInt currentStep = 0.obs;
  RxBool isLoading = false.obs;
  RxString selectedIdType = "".obs;
  Rxn<File?> frontIdImage = Rxn<File?>(null);
  Rxn<File?> backIdImage = Rxn<File?>(null);
  Rxn<File?> selfieImage = Rxn<File?>(null);

  final RxList<Map<String, String>> idTypes =
      [
        {'id': 'passport', 'name': 'Passport'},
        {'id': 'student', 'name': 'Student ID'},
        {'id': 'driving', 'name': 'Driving License'},
        {'id': 'national', 'name': 'National ID'},
      ].obs;

  void nextStep() {
    if (currentStep < 4) {
      currentStep++;
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
    }
  }

  void selectImage({
    ImageSource? imageSource,
    required Rxn<File?> image,
  }) async {
    try {
      final pickedFile = await pickImage(imageSource: imageSource);
      if (pickedFile != null) {
        image.value = File(pickedFile.path);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
