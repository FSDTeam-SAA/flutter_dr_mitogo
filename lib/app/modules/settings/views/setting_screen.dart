import 'dart:ui';
import 'package:casarancha/app/controller/auth_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final RxBool showAllContent = false.obs;
  final _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dateOfBirth = _userController.userModel.value?.dateOfBirth;
      final isAdult =
          dateOfBirth != null &&
          DateTime.now().difference(dateOfBirth).inDays >= 18 * 365;
      if (isAdult) {
        showAllContent.value = true;
      } else {
        showAllContent.value = false;
      }
    });
  }

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
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 0),
                      color: const Color.fromARGB(19, 0, 0, 0),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 15, right: 5),
                  title: Text(
                    "see_mature_content".tr,
                    style: Get.textTheme.bodyMedium!.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Transform.scale(
                    scale: 0.65,
                    child: Obx(
                      () => Switch(
                        activeColor: AppColors.primaryColor,
                        value: showAllContent.value,
                        onChanged: (value) => toggleAdultView(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 0),
                      color: const Color.fromARGB(19, 0, 0, 0),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 15, right: 5),
                  title: Text(
                    "ghost_mode".tr,
                    style: Get.textTheme.bodyMedium!.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Transform.scale(
                    scale: 0.65,
                    child: Obx(
                      () => Switch(
                        activeColor: AppColors.primaryColor,
                        value:
                            _userController.userModel.value!.ghostMode!.value,
                        onChanged: (value) async {
                          await _userController.toggleGhostMode();
                          // _createPostController.ghostMode.toggle();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              _buildSettingTile(
                title: "profile".tr,
                icon: FontAwesomeIcons.user,
                onTap: () => Get.toNamed(AppRoutes.profile),
              ),
              const SizedBox(height: 10),
              _buildSettingTile(
                title: "notification".tr,
                icon: FontAwesomeIcons.bell,
                onTap: () => Get.toNamed(AppRoutes.notificationSetting),
              ),
              const SizedBox(height: 10),
              _buildSettingTile(
                title: "language".tr,
                icon: FontAwesomeIcons.language,
                onTap: () => Get.toNamed(AppRoutes.languageSetting),
              ),
              const SizedBox(height: 10),
              _buildSettingTile(
                title: "invite".tr,
                icon: FontAwesomeIcons.shareNodes,
              ),
              const SizedBox(height: 10),
              _buildSettingTile(
                title: "get_verified".tr,
                icon: FontAwesomeIcons.shield,
                onTap: () {
                  // Get.toNamed(AppRoutes.altVerification);
                  Get.toNamed(AppRoutes.usernameVerification);
                },
              ),
              const SizedBox(height: 10),
              _buildSettingTile(
                title: "blocked".tr,
                icon: FontAwesomeIcons.ban,
                onTap: () {
                  Get.toNamed(AppRoutes.blockedUsers);
                },
              ),
              // const SizedBox(height: 10),
              // _buildSettingTile(
              //   title: "Reported",
              //   icon: FontAwesomeIcons.flag,
              //   onTap: () {
              //     Get.toNamed(AppRoutes.reportedUsers);
              //   },
              // ),
              const SizedBox(height: 10),
              _buildSettingTile(
                title: "help".tr,
                icon: FontAwesomeIcons.question,
                onTap: () {
                  Get.toNamed(AppRoutes.support);
                },
              ),
              const SizedBox(height: 10),
              _buildSettingTile(
                title: "logout".tr,
                icon: FontAwesomeIcons.arrowRightFromBracket,
                iconColor: Colors.red,
                onTap: () {
                  _displayBlurredBgDialogBox(context);
                },
              ),
              const SizedBox(height: 10),
              _buildSettingTile(
                title: "delete_account".tr,
                icon: FontAwesomeIcons.trash,
                iconColor: Colors.red,
                onTap: () {
                  _displayDeleteDialog(context);
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  void toggleAdultView() {
    final dateOfBirth = Get.find<UserController>().userModel.value?.dateOfBirth;
    final isAdult =
        dateOfBirth != null &&
        DateTime.now().difference(dateOfBirth).inDays >= 18 * 365;
    if (isAdult) {
      showAllContent.toggle();
    } else {
      CustomSnackbar.showErrorToast(
        "you_must_be_18".tr,
      );
    }
  }

  Container _buildSettingTile({
    required String title,
    required IconData icon,
    Color? iconColor,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 0),
            color: const Color.fromARGB(19, 0, 0, 0),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: Get.textTheme.bodyMedium!.copyWith(
            color: titleColor ?? Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 18),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "settings".tr,
        style: Get.textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
      ),
      // leading: Padding(
      //   padding: const EdgeInsets.only(left: 5),
      //   child: InkWell(
      //     onTap: () => Get.back(),
      //     child: CircleAvatar(
      //       backgroundColor: AppColors.primaryColor,
      //       child: const Icon(
      //         Icons.arrow_back_ios_new,
      //         size: 12,
      //         color: Colors.white,
      //       ),
      //     ),
      //   ),
      // ),
      // leadingWidth: 45,
    );
  }

  Future<dynamic> _displayBlurredBgDialogBox(BuildContext context) {
    final controller = Get.find<AuthController>();
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.primaryColor.withOpacity(0.2),
      builder: (context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.arrowRightFromBracket,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "logout".tr,
                          style: Get.textTheme.bodyMedium!.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    const SizedBox(height: 15),
                    Text(
                      "are_you_sure_logout".tr,
                      style: Get.textTheme.bodyMedium!.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: CustomButton(
                              ontap: () => Get.back(),
                              isLoading: false.obs,
                              bgColor: Colors.transparent,
                              border: Border.all(color: AppColors.primaryColor),
                              child: Text(
                                "cancel".tr,
                                style: Get.textTheme.bodyMedium!.copyWith(
                                  color: AppColors.primaryColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: CustomButton(
                              ontap: () async {
                                await controller.logout();
                              },
                              isLoading: false.obs,
                              child: Text(
                                "logout".tr,
                                style: Get.textTheme.bodyMedium!.copyWith(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> _displayDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.primaryColor.withOpacity(0.2),
      builder: (context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FaIcon(FontAwesomeIcons.trash, color: Colors.red),
                        const SizedBox(width: 10),
                        Text(
                          "delete_account".tr,
                          style: Get.textTheme.bodyMedium!.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    const SizedBox(height: 15),
                    Text(
                      "are_you_sure_delete".tr,
                      style: Get.textTheme.bodyMedium!.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: CustomButton(
                              ontap: () => Get.back(),
                              isLoading: false.obs,
                              bgColor: Colors.transparent,
                              border: Border.all(color: AppColors.primaryColor),
                              child: Text(
                                "cancel".tr,
                                style: Get.textTheme.bodyMedium!.copyWith(
                                  color: AppColors.primaryColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: CustomButton(
                              ontap:
                                  () =>
                                      Get.find<AuthController>()
                                          .deleteAccount(),
                              isLoading: false.obs,
                              child: Text(
                                "delete".tr,
                                style: Get.textTheme.bodyMedium!.copyWith(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
