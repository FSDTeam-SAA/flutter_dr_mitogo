import 'package:casarancha/app/controller/user_controller.dart';
import 'package:get/get.dart';

class NotificationSettingController extends GetxController {
  RxBool isPushNotification = true.obs;
  RxBool isRealTimeUpdates = true.obs;
  RxBool isInboxNotification = true.obs;
  RxBool isVibrate = true.obs;
  RxBool isSound = true.obs;
  final userController = Get.find<UserController>();


  void notificationSettings() async {
    await userController.notificationSettings(
      pushNotification: isPushNotification.value,
      realTimeUpdate: isRealTimeUpdates.value,
      inboxNotification: isInboxNotification.value,
      vibrate: isVibrate.value,
      sound: isSound.value,
    );
    await userController.getNotificationsSettings();
  }

}
