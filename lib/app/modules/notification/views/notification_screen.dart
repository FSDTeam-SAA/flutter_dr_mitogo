import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final userController = Get.find<UserController>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userController.notificationList.isEmpty) {
        userController.getNotifications();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: Get.width,
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () => userController.getNotifications(showLoader: false),
          child: ListView(
            children: [
              SizedBox(height: 15),
              Obx(() {
                if (userController.isloading.value) {
                  return SizedBox(
                    height: Get.height * 0.65,
                    width: Get.width,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  );
                }
                if (userController.notificationList.isEmpty) {
                  return SizedBox(
                    height: Get.height * 0.65,
                    width: Get.width,
                    child: Center(child: Text("no_notifications".tr)),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userController.notificationList.length,
                  itemBuilder: (context, index) {
                    final notification = userController.notificationList[index];
                    return InkWell(
                      onTap: () async {
                        notification.isRead.value = true;
                        await userController.markNotificationAsRead(
                          id: notification.id,
                        );
                      },
                      child: Obx(
                        () => Container(
                          width: Get.width,
                          height: Get.height * 0.12,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                notification.isRead.value
                                    ? const Color.fromARGB(255, 247, 247, 247)
                                    : const Color.fromARGB(255, 255, 205, 204),
                            boxShadow:
                                notification.isRead.value
                                    ? [
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                          29,
                                          0,
                                          0,
                                          0,
                                        ),
                                        blurRadius: 2,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    notification.isRead.value
                                        ? const Color.fromARGB(
                                          255,
                                          255,
                                          205,
                                          204,
                                        )
                                        : Colors.white,
                                child: Icon(
                                  FontAwesomeIcons.solidBell,
                                  size: 20,
                                  color:
                                      notification.isRead.value
                                          ? Colors.black
                                          : AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      notification.message,
                                      style: Get.textTheme.bodyMedium!.copyWith(
                                        color:
                                            notification.isRead.value
                                                ? Colors.black
                                                : Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      DateFormat(
                                        'dd MMM yyyy',
                                      ).format(notification.createdAt),
                                      style: Get.textTheme.bodySmall!.copyWith(
                                        color:
                                            notification.isRead.value
                                                ? Colors.black
                                                : Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "notifications".tr,
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
