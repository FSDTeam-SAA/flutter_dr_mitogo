import 'dart:io';

import 'package:casarancha/app/utils/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class VerificationController extends GetxController {
  RxInt currentStep = 0.obs;
  RxBool isLoading = false.obs;
  RxString selectedIdType = "".obs;
  RxString verificationType = "profile".obs;
  Rxn<File?> frontIdImage = Rxn<File?>(null);
  Rxn<File?> backIdImage = Rxn<File?>(null);
  Rxn<File?> selfieImage = Rxn<File?>(null);
  final TextEditingController fullNameController = TextEditingController();
  RxString fullName = "".obs;

  final Map<String, List<Map<String, String>>> idTypesByVerification = {
    'profile': [
      {'id': 'national', 'name': 'National ID (NID)'},
    ],
    'work': [
      {'id': 'work', 'name': 'Work ID'},
    ],
    'school': [
      {'id': 'student', 'name': 'Student ID'},
    ],
  };
  final List<Map<String, String>> verificationTypes = const [
    {'id': 'profile', 'name': 'Name'},
    {'id': 'work', 'name': 'Work'},
    {'id': 'school', 'name': 'Education'},
  ];

  List<Map<String, String>> get availableIdTypes {
    return idTypesByVerification[verificationType.value] ??
        idTypesByVerification['profile']!;
  }

  String get selectedIdName {
    try {
      return availableIdTypes.firstWhere(
            (idType) => idType['id'] == selectedIdType.value,
          )['name'] ??
          "ID";
    } catch (_) {
      return "ID";
    }
  }

  void setVerificationType(String type) {
    verificationType.value = type;
    final options = availableIdTypes;
    if (options.isNotEmpty) {
      selectedIdType.value = options.first['id'] ?? "";
    } else {
      selectedIdType.value = "";
    }
  }

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

  @override
  void onInit() {
    super.onInit();
    if (selectedIdType.value.isEmpty && availableIdTypes.isNotEmpty) {
      selectedIdType.value = availableIdTypes.first['id'] ?? "";
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    super.onClose();
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
