import 'package:casarancha/app/controller/group_controller.dart';
import 'package:casarancha/app/controller/message_controller.dart';
import 'package:casarancha/app/controller/one_signal_controller.dart';
import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/controller/socket_controller.dart';
import 'package:casarancha/app/controller/story_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/modules/home/controller/home_scroll_controller.dart';
import 'package:get/get.dart';
import 'package:casarancha/app/controller/auth_controller.dart';
import 'package:casarancha/app/controller/storage_controller.dart';

import '../controller/localization_controller.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(StorageController());
    Get.put(LocalizationController());
    Get.put(AuthController());
    Get.put(HomeScrollController());
    Get.put(UserController());
    Get.put(PostController());
    Get.put(GroupController());
    Get.put(StoryController());
    Get.put(OneSignalController());
    Get.put(SocketController());
    Get.put(MessageController());
  }
}
