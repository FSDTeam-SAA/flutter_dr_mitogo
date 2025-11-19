
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalController extends GetxController {

  @override
  void onInit() {
    initOneSignal();
    super.onInit();
  }

  void initOneSignal() async {
    OneSignal.initialize("2fa250e8-3569-45a5-9c27-db2be9b84c36");
    OneSignal.Notifications.requestPermission(true);
  }
}