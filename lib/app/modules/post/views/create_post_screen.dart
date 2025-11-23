import 'dart:io';

import 'package:casarancha/app/modules/post/controller/create_post_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/utils/get_file_type.dart';
import 'package:casarancha/app/utils/image_picker.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_compress/video_compress.dart';

class CreatePostScreen extends StatelessWidget {
  final bool? anonymous;
  final String? originalPostId;
  final String? title;
  final String? groupId;
  final String? groupName;
  CreatePostScreen({
    super.key,
    this.anonymous,
    this.originalPostId,
    this.title,
    this.groupId,
    this.groupName,
  });

  final controller = Get.put(CreatePostController());

  @override
  Widget build(BuildContext context) {
    controller.isAnonymous.value = anonymous ?? false;
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: StaggeredColumnAnimation(
            children: [
              SizedBox(height: Get.height * 0.02),
              Text(
                "what_do_you_want_post".tr,
                style: Get.textTheme.labelLarge!.copyWith(fontSize: 15),
              ),
              SizedBox(height: Get.height * 0.03),
              if (anonymous != null || anonymous == true)
                _buildPostFeatureCard(
                  title: "post_as_anonymous".tr,
                  value: controller.isAnonymous,
                  onChanged: (value) {
                    controller.isAnonymous.value = value;
                  },
                ),
              _buildPostFeatureCard(
                title: "turn_on_verification_badge".tr,
                value: controller.isVerificationBadge,
                onChanged: (value) {
                  controller.isVerificationBadge.value = value;
                },
              ),
              _buildPostFeatureCard(
                title: "turn_off_comments".tr,
                value: controller.isComments,
                onChanged: (value) {
                  controller.isComments.value = value;
                },
              ),
              _buildPostFeatureCard(
                title: "show_post_time".tr,
                value: controller.showPostTime,
                onChanged: (value) {
                  controller.showPostTime.value = value;
                },
              ),
              const SizedBox(height: 3),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(15),
              //     color: Colors.white,
              //     border: Border.all(width: 1, color: Colors.grey.shade300),
              //     boxShadow: [
              //       BoxShadow(
              //         offset: Offset(0, 0),
              //         color: const Color.fromARGB(12, 0, 0, 0),
              //         spreadRadius: 1,
              //         blurRadius: 5,
              //       ),
              //     ],
              //   ),
              //   child: TextFormField(
              //     cursorColor: AppColors.primaryColor,
              //     style: GoogleFonts.poppins(
              //       fontSize: 12,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.black,
              //     ),
              //     onChanged: (value) {
              //       controller.onSearchChanged(value);
              //     },
              //     decoration: InputDecoration(
              //       prefixIcon: Icon(
              //         FontAwesomeIcons.tag,
              //         color: AppColors.primaryColor,
              //         size: 20,
              //       ),
              //       border: InputBorder.none,
              //       focusedBorder: InputBorder.none,
              //       enabledBorder: InputBorder.none,
              //       errorBorder: InputBorder.none,
              //       disabledBorder: InputBorder.none,
              //       contentPadding: const EdgeInsets.all(15),
              //       hintText: "Search people to tag",
              //       hintStyle: Get.textTheme.bodyMedium!.copyWith(
              //         color: Colors.grey,
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 10),
              // Obx(
              //   () =>
              //       controller.displayUsers.isNotEmpty
              //           ? Wrap(
              //             spacing: 8.0, // gap between adjacent chips
              //             children:
              //                 controller.displayUsers.map((user) {
              //                   return Chip(
              //                     label: Text(
              //                       user.displayName ?? '',
              //                       style: GoogleFonts.poppins(
              //                         fontSize: 12,
              //                         fontWeight: FontWeight.w600,
              //                         color: Colors.black,
              //                       ),
              //                     ),
              //                     backgroundColor: Colors.grey[200],
              //                     deleteIcon: const Icon(Icons.add, size: 18),
              //                     onDeleted: () {
              //                       // Handle adding the user (you can implement this later)
              //                     },
              //                   );
              //                 }).toList(),
              //           )
              //           : const SizedBox.shrink(),
              // ),
              // const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 0),
                      color: const Color.fromARGB(12, 0, 0, 0),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: TextFormField(
                  cursorColor: AppColors.primaryColor,
                  controller: controller.locationController,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      FontAwesomeIcons.location,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.all(15),
                    hintText: "location".tr,
                    hintStyle: Get.textTheme.bodyMedium!.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.createPoll,
                    arguments: {"groupId": groupId, "groupName": groupName},
                  );
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
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                            width: 1,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        child: Icon(
                          FontAwesomeIcons.plus,
                          size: 20,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "create_poll_here".tr,
                        style: Get.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        FontAwesomeIcons.chartSimple,
                        size: 20,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.03),
              CustomTextField(
                label: "write_something".tr,
                controller: controller.descriptionController,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                bgColor: Color.fromRGBO(244, 244, 247, 1),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                minLines: 5,
                maxLines: 6,
              ),
              SizedBox(height: Get.height * 0.01),
              _buildSelectedMedia(),
              SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMediaCard(
                    title: "photo".tr,
                    icon: FontAwesomeIcons.solidImage,
                    onTap: () async {
                      List<File>? images = await pickMultipleImages();
                      if (images != null) {
                        controller.selectedMedias.addAll(images);
                        controller.allMediaToPreview.addAll(images);
                      }
                    },
                    iconSize: 18,
                  ),
                  _buildMediaCard(
                    title: "video".tr,
                    icon: FontAwesomeIcons.video,
                    onTap: () async {
                      File? video = await pickVideo();
                      if (video == null) return;
                      final thumbnailFile =
                          await VideoCompress.getFileThumbnail(
                            video.path,
                            quality: 100,
                            position: -1,
                          );
                      if (thumbnailFile.path.isNotEmpty) {
                        controller.allMediaToPreview.add(thumbnailFile);
                      }
                      if (video.path.isNotEmpty) {
                        controller.selectedMedias.add(video);
                      }
                    },
                    iconSize: 18,
                  ),
                  _buildMediaCard(
                    title: "audio".tr,
                    icon: FontAwesomeIcons.fileAudio,
                    onTap: () async {
                      File? audio = await pickMp3Audio();
                      if (audio != null) {
                        controller.selectedMedias.add(audio);
                        controller.allMediaToPreview.add(audio);
                      }
                    },
                    iconSize: 18,
                  ),
                ],
              ),
              SizedBox(height: Get.height * 0.02),
              CustomButton(
                ontap: () async {
                  HapticFeedback.lightImpact();
                  if (controller.descriptionController.text.isEmpty &&
                      controller.selectedMedias.isEmpty) {
                    CustomSnackbar.showErrorToast(
                      "please_add_description".tr,
                    );
                    return;
                  }
                  await controller.createPost(
                    originalPostId: originalPostId,
                    postType: getPostType(),
                    visibilityType: getVisibilityType(),
                    groupId: groupId,
                    groupName: groupName,
                  );
                },
                isLoading: controller.isloading,
                borderRadius: BorderRadius.circular(15),
                child: Text(
                  "post".tr,
                  style: Get.textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  String? getPostType() {
    if (controller.isAnonymous.value) {
      return "ghost";
    }
    if (originalPostId == null) {
      return "regular";
    }
    return "repost";
  }

  String? getVisibilityType() {
    if (controller.isAnonymous.value) {
      return "ghost";
    }
    if (groupId != null) {
      return "group";
    }
    return "public";
  }

  Widget _buildSelectedMedia() {
    return Obx(() {
      if (controller.allMediaToPreview.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: Get.height * 0.08,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.allMediaToPreview.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final media = controller.allMediaToPreview[index];
            final mediaType = getFileType(media);
            if (mediaType == null) {
              return const SizedBox.shrink();
            }
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
                    child: buildMedia(mediaType, media),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      controller.allMediaToPreview.removeAt(index);
                      controller.selectedMedias.removeAt(index);
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

  Widget buildMedia(FileType fileType, File media) {
    switch (fileType) {
      case FileType.image:
        return Image.file(media, fit: BoxFit.cover);
      case FileType.video:
        return Image.file(media, fit: BoxFit.cover);
      case FileType.music:
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Icon(FontAwesomeIcons.music, size: 20),
        );
    }
  }

  Widget _buildMediaCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    double? iconSize,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(37),
          color: const Color.fromARGB(255, 243, 219, 219),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryColor, size: iconSize),
            SizedBox(width: 5),
            Text(
              title,
              style: Get.textTheme.bodyMedium!.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildPostFeatureCard({
    required String title,
    required RxBool value,
    required Function onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 0),
            color: const Color.fromARGB(12, 0, 0, 0),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        leading: Text(title, style: Get.textTheme.bodyMedium),
        trailing: Transform.scale(
          scale: 0.65,
          child: Obx(
            () => Switch(
              activeColor: AppColors.primaryColor,
              value: value.value,
              onChanged: (value) => onChanged(value),
            ),
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
        title ?? "create_post".tr,
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
      leadingWidth: 40,
    );
  }
}
