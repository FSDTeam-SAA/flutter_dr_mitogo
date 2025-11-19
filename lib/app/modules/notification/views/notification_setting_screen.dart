import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/modules/notification/controller/notification_setting_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  final controller = Get.put(NotificationSettingController());
  final userController = Get.find<UserController>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final res = await userController.getNotificationsSettings();
      if (res != null) {
        controller.isPushNotification.value = res.pushNotificationSettings;
        controller.isRealTimeUpdates.value = res.realTimeUpdates;
        controller.isInboxNotification.value = res.inboxNotifications;
        controller.isVibrate.value = res.vibrate;
        controller.isSound.value = res.sound;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.notificationSettings();
    super.dispose();
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
          child: Obx(() {
            if (userController.isloading.value) {
              return SizedBox(
                height: Get.height * 0.6,
                width: Get.width,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              );
            }
            return StaggeredColumnAnimation(
              children: [
                SizedBox(height: Get.height * 0.03),
                _buildSettingTile(
                  title: "Push Notifications",
                  value: controller.isPushNotification,
                ),
                _buildSettingTile(
                  title: "Real time Updates",
                  value: controller.isRealTimeUpdates,
                ),
                _buildSettingTile(
                  title: "Inbox Notification",
                  value: controller.isInboxNotification,
                ),
                _buildSettingTile(
                  title: "Vibrate",
                  value: controller.isVibrate,
                ),
                _buildSettingTile(title: "Sound ", value: controller.isSound),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSettingTile({required String title, required RxBool value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      margin: const EdgeInsets.only(bottom: 10),
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
        title: Text(
          title,
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
              value: value.value,
              onChanged: (v) {
                value.value = v;
              },
              activeColor: AppColors.primaryColor,
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
        "Notification Settings",
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
