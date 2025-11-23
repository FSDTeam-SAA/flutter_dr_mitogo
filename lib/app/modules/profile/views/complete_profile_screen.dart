import 'dart:io';

import 'package:casarancha/app/modules/profile/widgets/complete_profile_form_field.dart';
import 'package:casarancha/app/utils/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CompleteProfileScreen extends StatelessWidget {
  CompleteProfileScreen({super.key});

  final Rxn<File> _selectedPicture = Rxn<File>();
  void selectImage() async {
    File? image = await pickImage();
    if (image != null) {
      _selectedPicture.value = image;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height * 0.1),
              Center(
                child: Stack(
                  children: [
                    Obx(
                      () => Container(
                        height: Get.height * 0.13,
                        width: Get.height * 0.13,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 2, color: Colors.grey),
                          color: Colors.grey.shade50,
                          image:
                              _selectedPicture.value != null
                                  ? DecorationImage(
                                    image: FileImage(_selectedPicture.value!),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                        ),
                        child:
                            _selectedPicture.value == null
                                ? FaIcon(FontAwesomeIcons.solidImage, size: 30)
                                : SizedBox.shrink(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 5,
                      child: InkWell(
                        onTap: selectImage,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: AppColors.primaryColor,
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Get.height * 0.02),
              Center(
                child: Text(
                  'complete_profile'.tr,
                  style: Get.textTheme.bodyLarge,
                ),
              ),
              Center(
                child: Text(
                  "welcome_complete_profile".tr,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodySmall,
                ),
              ),
              SizedBox(height: Get.height * 0.04),
              CompleteProfileFormFields(selectedPicture: _selectedPicture),
            ],
          ),
        ),
      ),
    );
  }
}
