import 'dart:io';

import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/modules/verification/controller/verification_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class VerificationBadgeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  const VerificationBadgeButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class BuildIdSelectionStep extends StatelessWidget {
  BuildIdSelectionStep({super.key});

  final _badgeController = Get.find<VerificationController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        const Text(
          'Select Your ID Type',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose the identification document you wish to verify with',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Wrap(
            spacing: 8,
            children: _badgeController.verificationTypes.map((type) {
              final isSelected = _badgeController.verificationType.value == type['id'];
              return ChoiceChip(
                label: Text(type['name']!),
                selected: isSelected,
                onSelected: (_) =>
                    _badgeController.setVerificationType(type['id'] ?? 'profile'),
                selectedColor: AppColors.primaryColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primaryColor : Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Full Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _badgeController.fullNameController,
          hintText: "Enter your full legal name",
          bgColor: Colors.white,
          onChanged: (value) => _badgeController.fullName.value = value.trim(),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final idTypes = _badgeController.availableIdTypes;
          RxString selectedIdType = _badgeController.selectedIdType;
          return Expanded(
            child: ListView.builder(
              itemCount: idTypes.length,
              itemBuilder: (context, index) {
                final idType = idTypes[index];
                return Obx(() {
                  final isSelected = idType['id'] == selectedIdType.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        selectedIdType.value = idType['id'] ?? "";
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primaryColor
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                          color: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              idType['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isSelected ? AppColors.primaryColor : null,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primaryColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          );
        }),
        const SizedBox(height: 16),
        Obx(
          () => ElevatedButton(
            onPressed:
                _badgeController.selectedIdType.value.isNotEmpty &&
                        _badgeController.fullNameController.text.trim().isNotEmpty
                    ? _badgeController.nextStep
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BuildFrontIdUploadStep extends StatelessWidget {
  BuildFrontIdUploadStep({super.key});

  final _badgeController = Get.find<VerificationController>();

  @override
  Widget build(BuildContext context) {
    final selectedIdName =
        _badgeController.selectedIdName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _badgeController.currentStep > 0
            ? InkWell(
              onTap: _badgeController.prevStep,
              child: const Icon(Icons.arrow_back),
            )
            : const SizedBox.shrink(),
        const SizedBox(height: 10),
        Text(
          'Upload Front of $selectedIdName',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Please upload a clear image of the front side of your $selectedIdName',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _showImageSourceOptions(_badgeController.frontIdImage);
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Obx(
                () =>
                    _badgeController.frontIdImage.value != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _badgeController.frontIdImage.value!,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to upload front of $selectedIdName',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => VerificationBadgeButton(
            onPressed:
                _badgeController.frontIdImage.value != null
                    ? _badgeController.nextStep
                    : null,
            text: "Continue",
          ),
        ),
      ],
    );
  }
}

class BuildBackIdUploadStep extends StatelessWidget {
  BuildBackIdUploadStep({super.key});

  final _badgeController = Get.find<VerificationController>();

  @override
  Widget build(BuildContext context) {
    final selectedIdName =
        _badgeController.selectedIdName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _badgeController.currentStep > 0
            ? InkWell(
              onTap: _badgeController.prevStep,
              child: const Icon(Icons.arrow_back),
            )
            : const SizedBox.shrink(),
        const SizedBox(height: 10),
        Text(
          'Upload Back of $selectedIdName',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Please upload a clear image of the back side of your $selectedIdName',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Obx(
          () => Expanded(
            child: GestureDetector(
              onTap: () {
                _showImageSourceOptions(_badgeController.backIdImage);
                print(_badgeController.backIdImage.value?.path);
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child:
                    _badgeController.backIdImage.value != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _badgeController.backIdImage.value!,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to upload back of $selectedIdName',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => VerificationBadgeButton(
            onPressed:
                _badgeController.backIdImage.value != null
                    ? _badgeController.nextStep
                    : null,
            text: "Continue",
          ),
        ),
      ],
    );
  }
}

class BuildReviewStep extends StatelessWidget {
  BuildReviewStep({super.key});

  final _verificationController = Get.find<VerificationController>();

  @override
  Widget build(BuildContext context) {
    final selectedIdName =
        _verificationController.selectedIdName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _verificationController.currentStep > 0
            ? InkWell(
              onTap: _verificationController.prevStep,
              child: const Icon(Icons.arrow_back),
            )
            : const SizedBox.shrink(),
        const SizedBox(height: 10),
        const Text(
          'Review & Submit',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please review your verification details before submission',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You\'ve selected $selectedIdName as your verification document',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Full Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _verificationController.fullNameController.text.trim(),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ID Front',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.file(
                  _verificationController.frontIdImage.value!,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ID Back',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.file(
                  _verificationController.backIdImage.value!,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image);
                  },
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selfie',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.file(
                  _verificationController.selfieImage.value!,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => VerificationBadgeButton(
            onPressed: _verificationController.isLoading.value
                ? null
                : () async {
                    if (_verificationController.frontIdImage.value == null ||
                        _verificationController.backIdImage.value == null ||
                        _verificationController.selfieImage.value == null) {
                      CustomSnackbar.showErrorToast(
                        "Please upload all required images before submitting.",
                      );
                      return;
                    }
                    _verificationController.isLoading.value = true;
                    try {
                      final userController = Get.find<UserController>();
                      await userController.verificationRequest(
                        frontId: _verificationController.frontIdImage.value!,
                        backId: _verificationController.backIdImage.value!,
                        selfieId: _verificationController.selfieImage.value!,
                        verificationType: _verificationController.verificationType.value,
                        idType: _verificationController.selectedIdType.value,
                        metadata: {
                          "fullName": _verificationController.fullNameController.text.trim(),
                        },
                      );
                    } finally {
                      _verificationController.isLoading.value = false;
                    }
                  },
            text:
                _verificationController.isLoading.value
                    ? "Processing..."
                    : "Submit for Verification",
          ),
        ),
      ],
    );
  }
}

class BuildSelfieStep extends StatelessWidget {
  BuildSelfieStep({super.key});

  final _badgeController = Get.find<VerificationController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _badgeController.currentStep > 0
            ? InkWell(
              onTap: _badgeController.prevStep,
              child: const Icon(Icons.arrow_back),
            )
            : const SizedBox.shrink(),
        const SizedBox(height: 10),
        const Text(
          'Take a Selfie',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please take a clear selfie of your face for identity verification',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _badgeController.selectImage(
                imageSource: ImageSource.camera,
                image: _badgeController.selfieImage,
              );
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Obx(
                () =>
                    _badgeController.selfieImage.value != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _badgeController.selfieImage.value!,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to take a selfie',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => VerificationBadgeButton(
            onPressed:
                _badgeController.selfieImage.value != null
                    ? _badgeController.nextStep
                    : null,
            text: "Continue",
          ),
        ),
      ],
    );
  }
}

void _showImageSourceOptions(Rxn<File?> image) {
  final badgeController = Get.find<VerificationController>();
  showModalBottomSheet(
    context: Get.context!,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('Take a Photo', style: Get.textTheme.bodyMedium!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
                onTap: () {
                  Navigator.pop(context);
                  badgeController.selectImage(
                    imageSource: ImageSource.camera,
                    image: image,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('Choose from Gallery', style: Get.textTheme.bodyMedium!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
                onTap: () {
                  Navigator.pop(context);
                  badgeController.selectImage(
                    imageSource: ImageSource.gallery,
                    image: image,
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
