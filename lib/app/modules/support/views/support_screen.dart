import 'dart:io';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/utils/image_picker.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportScreen extends StatelessWidget {
  SupportScreen({super.key});

  final RxList<File> selectedMedias = <File>[].obs;
  final userController = Get.find<UserController>();

  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        width: Get.width,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          child: StaggeredColumnAnimation(
            children: [
              SizedBox(height: Get.height * 0.02),
              Text("topic".tr, style: Get.textTheme.bodyMedium),
              const SizedBox(height: 5),
              CustomTextField(
                hintText: "enter_topic_name".tr,
                controller: subjectController,
                // controller: controller.emailController,
              ),
              const SizedBox(height: 25),
              Text("message".tr, style: Get.textTheme.bodyMedium),
              const SizedBox(height: 5),
              CustomTextField(
                hintText: "enter_your_message".tr,
                minLines: 5,
                maxLines: 6,
                controller: messageController,
                // controller: controller.emailController,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  final attachments = await pickNoCompressedImages();
                  if (attachments != null) {
                    selectedMedias.addAll(attachments);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.image,
                        color: AppColors.primaryColor,
                        size: 40,
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "browse_images_or_drop_here".tr,
                            style: Get.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "jpg_png_max_25mb".tr,
                            style: Get.textTheme.bodyMedium!.copyWith(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              _buildSelectedMedia(),
              SizedBox(height: Get.height * 0.1),
              CustomButton(
                ontap: () async {
                  if (selectedMedias.isEmpty) {
                    CustomSnackbar.showErrorToast(
                      "please_select_at_least_one_image".tr,
                    );
                    return;
                  }
                  if (selectedMedias.length > 5) {
                    CustomSnackbar.showErrorToast(
                      "you_can_select_maximum_5_images".tr,
                    );
                    return;
                  }
                  if (subjectController.text.isEmpty) {
                    CustomSnackbar.showErrorToast("please_enter_a_subject".tr);
                    return;
                  }
                  if (messageController.text.isEmpty) {
                    CustomSnackbar.showErrorToast("please_enter_a_message".tr);
                    return;
                  }
                  await userController.createTicket(
                    attachments: selectedMedias,
                    subject: subjectController.text,
                    description: messageController.text,
                  );
                },
                isLoading: userController.isloading,
                child: Text(
                  "create".tr,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMedia() {
    return Obx(() {
      if (selectedMedias.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: Get.height * 0.08,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: selectedMedias.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final media = selectedMedias[index];
            return Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: Get.width * 0.18,
                  height: Get.height * 0.08,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(media, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      selectedMedias.removeAt(index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.xmark,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "get_help".tr,
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
