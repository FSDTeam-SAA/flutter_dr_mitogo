import 'dart:io';

import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/utils/image_picker.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final Rxn<File> _selectedPicture = Rxn<File>();
  void selectImage() async {
    File? image = await pickImage();
    if (image != null) {
      _selectedPicture.value = image;
    }
  }

  final userController = Get.find<UserController>();
  final displayNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  final countryController = TextEditingController();
  final workController = TextEditingController();
  final educationController = TextEditingController();

  void preloadAllFields() {
    final userModel = userController.userModel.value;
    displayNameController.text = userModel?.displayName ?? "";
    phoneNumberController.text = userModel?.phoneNumber ?? "";
    emailController.text = userModel?.email ?? "";
    bioController.text = userModel?.bio ?? "";
    workController.text = userModel?.work ?? "";
    educationController.text = userModel?.education ?? "";
  }

  @override
  Widget build(BuildContext context) {
    preloadAllFields();
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.bgGradient),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: StaggeredColumnAnimation(
              children: [
                SizedBox(height: Get.height * 0.04),
                Center(
                  child: Stack(
                    children: [
                      Obx(() {
                        final userModel = userController.userModel.value;
                        return Container(
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
                                    : DecorationImage(
                                      image: NetworkImage(
                                        userModel?.avatarUrl ?? "",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        );
                      }),
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
                SizedBox(height: Get.height * 0.05),
                Text(
                  "edit_your_profile".tr,
                  style: Get.textTheme.bodyMedium!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text("put_info_to_complete".tr, style: Get.textTheme.bodySmall),
                SizedBox(height: Get.height * 0.05),
                Text("display_name".tr, style: Get.textTheme.bodyMedium),
                const SizedBox(height: 5),
                CustomTextField(
                  controller: displayNameController,
                  hintText: "John",
                  bgColor: const Color(0xFFF7F7F9),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                const SizedBox(height: 15),
                Text("phone_number".tr, style: Get.textTheme.bodyMedium),
                const SizedBox(height: 5),
                CustomTextField(
                  controller: phoneNumberController,
                  hintText: "+91-554-131-890",
                  bgColor: const Color(0xFFF7F7F9),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                const SizedBox(height: 15),
                Text("email".tr, style: Get.textTheme.bodyMedium),
                const SizedBox(height: 5),
                CustomTextField(
                  controller: emailController,
                  hintText: "enter_email",
                  bgColor: const Color(0xFFF7F7F9),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),

                const SizedBox(height: 15),
                Text("education".tr, style: Get.textTheme.bodyMedium),
                const SizedBox(height: 5),
                CustomTextField(
                  controller: educationController,
                  hintText: "B.sc",
                  bgColor: const Color(0xFFF7F7F9),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                const SizedBox(height: 15),
                Text("work".tr, style: Get.textTheme.bodyMedium),
                const SizedBox(height: 5),
                CustomTextField(
                  controller: workController,
                  hintText: "Software Eng.",
                  bgColor: const Color(0xFFF7F7F9),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                const SizedBox(height: 15),
                Text("biography".tr, style: Get.textTheme.bodyMedium),
                const SizedBox(height: 5),
                CustomTextField(
                  controller: bioController,
                  hintText:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  minLines: 4,
                  maxLines: 5,
                  bgColor: const Color(0xFFF7F7F9),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  ontap: () async {
                    UserModel userModel = UserModel();
                    if (displayNameController.text.isNotEmpty) {
                      userModel.displayName = displayNameController.text;
                    }
                    if (phoneNumberController.text.isNotEmpty) {
                      userModel.phoneNumber = phoneNumberController.text;
                    }
                    if (emailController.text.isNotEmpty) {
                      userModel.email = emailController.text;
                    }
                    if (bioController.text.isNotEmpty) {
                      userModel.bio = bioController.text;
                    }
                    if (educationController.text.isNotEmpty) {
                      userModel.education = educationController.text;
                    }
                    if (workController.text.isNotEmpty) {
                      userModel.work = workController.text;
                    }
                    await userController.editProfile(
                      userModel: userModel,
                      avater: _selectedPicture.value,
                    );
                  },
                  isLoading: userController.isloading,
                  child: Text(
                    "save_changes".tr,
                    style: Get.textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
