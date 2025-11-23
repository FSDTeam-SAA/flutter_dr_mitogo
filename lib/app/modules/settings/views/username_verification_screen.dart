import 'dart:io';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/utils/image_picker.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UsernameVerificationScreen extends StatelessWidget {
  UsernameVerificationScreen({super.key});

  final userController = Get.find<UserController>();

  final Rxn<File> _frontId = Rxn<File>();
  final Rxn<File> _backId = Rxn<File>();
  final Rxn<File> _selfieId = Rxn<File>();

  Future<void> selectImage({required Rxn<File> file}) async {
    File? image = await pickImage();
    if (image != null) {
      file.value = image;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: ListView(
            children: [
              SizedBox(height: Get.height * 0.03),
              Text(
                "full_legal_name".tr,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Color(0xFF312A2A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: Get.height * 0.01),
              CustomTextField(
                bgColor: Color(0xffF7F7F9),
                hintText: "enter_your_full_legal_name".tr,
              ),
              SizedBox(height: Get.height * 0.03),

              InkWell(
                onTap: () async {
                  await selectImage(file: _frontId);
                },
                child: Obx(() {
                  return Container(
                    height: Get.height * 0.2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 1, color: Colors.grey),
                      image:
                          _frontId.value != null
                              ? DecorationImage(
                                image: FileImage(_frontId.value!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _frontId.value != null
                            ? null
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.image,
                                  size: 45,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "front_id".tr,
                                      style: Get.textTheme.bodyMedium!.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "jpg_png_max_25mb".tr,
                                      style: Get.textTheme.bodySmall!.copyWith(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                  );
                }),
              ),
              SizedBox(height: Get.height * 0.03),

              InkWell(
                onTap: () async {
                  await selectImage(file: _backId);
                },
                child: Obx(() {
                  return Container(
                    height: Get.height * 0.2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 1, color: Colors.grey),
                      image:
                          _backId.value != null
                              ? DecorationImage(
                                image: FileImage(_backId.value!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _backId.value != null
                            ? null
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.image,
                                  size: 45,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "back_id".tr,
                                      style: Get.textTheme.bodyMedium!.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "jpg_png_max_25mb".tr,
                                      style: Get.textTheme.bodySmall!.copyWith(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                  );
                }),
              ),
              SizedBox(height: Get.height * 0.03),

              InkWell(
                onTap: () async {
                  await selectImage(file: _selfieId);
                },
                child: Obx(() {
                  return Container(
                    height: Get.height * 0.2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 1, color: Colors.grey),
                      image:
                          _selfieId.value != null
                              ? DecorationImage(
                                image: FileImage(_selfieId.value!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _selfieId.value != null
                            ? null
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.image,
                                  size: 45,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "selfie_id".tr,
                                      style: Get.textTheme.bodyMedium!.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "jpg_png_max_25mb".tr,
                                      style: Get.textTheme.bodySmall!.copyWith(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                  );
                }),
              ),
              SizedBox(height: Get.height * 0.03),
              CustomButton(
                ontap: () async {
                  if (_frontId.value == null ||
                      _backId.value == null ||
                      _selfieId.value == null) {
                    CustomSnackbar.showErrorToast(
                      "please_upload_all_documents".tr,
                    );
                    return;
                  }
                  await userController.verificationRequest(
                    frontId: _frontId.value!,
                    backId: _backId.value!,
                    selfieId: _selfieId.value!,
                  );
                },
                isLoading: userController.isloading,
                borderRadius: BorderRadius.circular(15),
                child: Text(
                  "submit".tr,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "username_verification".tr,
        style: Get.textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: InkWell(
          onTap: () => Get.back(),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ),
      leadingWidth: 45,
    );
  }
}
