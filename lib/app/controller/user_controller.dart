import 'dart:convert';
import 'dart:io';

import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/controller/storage_controller.dart';
import 'package:casarancha/app/data/models/notification_model.dart';
import 'package:casarancha/app/data/models/notification_setting_model.dart';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/data/services/user_service.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final UserService _userService = UserService();

  Rxn<UserModel> userModel = Rxn<UserModel>();
  RxList<UserModel> blockedUsers = RxList<UserModel>();
  RxBool isloading = false.obs;
  RxBool isUserDetailsFetched = false.obs;

  RxList<NotificationModel> notificationList = <NotificationModel>[].obs;

  @override
  void onInit() async {
    super.onInit();
    getUserDetails();
  }

  Future<void> getUserStatus() async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      String? token = await storageController.getToken();
      if (token == null || token.isEmpty) return;

      final response = await _userService.getUserStatus(token: token);
      if (response == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      final decoded = json.decode(response.body);
      String message = decoded["message"];

      if (message == "Token has expired.") {
        Get.offAllNamed(AppRoutes.signup);
        return;
      }

      if (response.statusCode != 200) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      var userData = decoded["data"];

      if (userData == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      bool isEverified = userData["accountStatus"]?["isEmailVerified"] ?? false;
      if (!isEverified) {
        Get.offAllNamed(
          AppRoutes.otp,
          arguments: {
            "email": userData["email"],
            "onTap": () async {
              await getUserStatus();
            },
          },
        );
        return;
      }

      bool isProfileCompleted =
          userData["accountStatus"]?["isProfileCompleted"] ?? false;
      if (!isProfileCompleted) {
        Get.offAllNamed(AppRoutes.completeProfile);
        return;
      }

      Get.offAllNamed(AppRoutes.bottomNavigation);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> getUserDetails() async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      String? token = await storageController.getToken();
      if (token == null || token.isEmpty) return;

      final response = await _userService.getUserDetails(token: token);
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"];

      if (message == "Token has expired.") {
        Get.offAllNamed(AppRoutes.signup);
        return;
      }

      if (response.statusCode != 200) {
        debugPrint("Error-from-get-user-details: $message");
        return;
      }

      var userData = decoded["data"];
      UserModel mapped = UserModel.fromJson(userData);
      userModel.value = mapped;
      userModel.refresh();
      if (response.statusCode == 200) isUserDetailsFetched.value = true;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<UserModel?> getUserById({required String userId}) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      String? token = await storageController.getToken();
      if (token == null || token.isEmpty) return null;

      final response = await _userService.getUserById(
        token: token,
        userId: userId,
      );
      if (response == null) return null;
      final decoded = json.decode(response.body);
      String message = decoded["message"];

      if (message == "Token has expired.") {
        Get.offAllNamed(AppRoutes.signup);
        return null;
      }

      if (response.statusCode != 200) {
        debugPrint("Error-from-get-user-details: $message");
        return null;
      }

      var userData = decoded["data"];
      UserModel mapped = UserModel.fromJson(userData);
      return mapped;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
    return null;
  }

  Future<void> completeProfileScreen({
    required UserModel userModel,
    required File imageFile,
    Function()? nextScreen,
  }) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return;
      final response = await _userService.completeProfile(
        userModel: userModel,
        token: token,
        imageFile: imageFile,
      );
      if (response == null) return;
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      final userController = Get.find<UserController>();
      await userController.getUserDetails();
      Get.find<PostController>().getFeed();
      if (nextScreen != null) {
        await nextScreen();
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> toggleBlock({required String blockId}) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return;
      final response = await _userService.toggleBlock(
        token: token,
        blockId: blockId,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      CustomSnackbar.showSuccessToast(message);
      await getBlockedUsers(showLoader: false);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> toggleFollow({
    required String followId,
    bool showLoader = true,
  }) async {
    isloading.value = showLoader;
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return;
      final response = await _userService.toggleFollow(
        token: token,
        followId: followId,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> getBlockedUsers({bool showLoader = false}) async {
    isloading.value = showLoader;
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return;
      final response = await _userService.getBlockedUsers(token: token);
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      final List data = decoded["data"] ?? [];
      blockedUsers.clear();
      if (data.isEmpty) return;
      final List<UserModel> mappedBlocked =
          data.map((e) => UserModel.fromJson(e)).toList();
      blockedUsers.value = mappedBlocked;
      blockedUsers.refresh();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> reportUser({
    required String type,
    required String reason,
    required String reportedUser,
    required String referenceId,
  }) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      String? token = await storageController.getToken();
      if (token == null) return;
      final response = await _userService.reportUser(
        token: token,
        type: type,
        reason: reason,
        reportedUser: reportedUser,
        referenceId: referenceId,
      );
      if (response == null) return;
      var responseBody = json.decode(response.body);
      String message = responseBody["message"] ?? "";
      if (response.statusCode != 201) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      Navigator.pop(Get.context!);
      CustomSnackbar.showSuccessToast("Report submitted successfully");
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<List<PostModel>?> getAllUserPost({
    required String userId,
    bool showLoader = false,
  }) async {
    isloading.value = showLoader;
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return null;
      final response = await _userService.getAllUserPost(
        token: token,
        userId: userId,
        currentPage: 1,
      );
      if (response == null) return null;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return null;
      }
      final List data = decoded["data"]?["posts"] ?? [];
      if (data.isEmpty) return null;
      final List<PostModel> mapped =
          data.map((e) => PostModel.fromJson(e)).toList();
      return mapped;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
    return null;
  }

  Future<List<String>?> getAllUserMedia({
    required String userId,
    required String type,
  }) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return null;
      final response = await _userService.getAllUserMedia(
        token: token,
        userId: userId,
        type: type,
      );
      if (response == null) return null;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return null;
      }
      final List data = decoded["data"] ?? [];
      if (data.isEmpty) return null;
      final List<String> mapped = data.map((e) => e.toString()).toList();
      return mapped;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
    return null;
  }

  Future<String?> uploadCoverPhoto({required File imageFile}) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return null;
      final response = await _userService.uploadCoverPhoto(
        token: token,
        imageFile: imageFile,
      );
      if (response == null) return null;
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return null;
      }
      String coverPhotoUrl = decoded["data"] ?? "";
      CustomSnackbar.showSuccessToast(message);
      return coverPhotoUrl;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
    return null;
  }

  Future<void> saveUserOneSignalId({required String oneSignalId}) async {
    try {
      final storageController = Get.find<StorageController>();
      String? token = await storageController.getToken();
      if (token == null || token.isEmpty) return;
      final response = await _userService.saveUserOneSignalId(
        token: token,
        id: oneSignalId,
      );
      if (response == null) return;
      print(response.body);
      final userId = userModel.value?.id;

      await storageController.saveLastPushId(
        userId: userId ?? "",
        oneSignalId: oneSignalId,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getNotifications({bool showLoader = true}) async {
    isloading.value = showLoader;
    try {
      final storageController = Get.find<StorageController>();
      String? token = await storageController.getToken();
      if (token == null || token.isEmpty) return;
      final response = await _userService.getNotifications(token: token);
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      List data = decoded["data"] ?? [];
      if (data.isEmpty) return;
      final List<NotificationModel> mapped =
          data.map((e) => NotificationModel.fromJson(e)).toList();
      notificationList.value = mapped;
      notificationList.refresh();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> markNotificationAsRead({required String id}) async {
    try {
      final storageController = Get.find<StorageController>();
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await _userService.markNotificationAsRead(
        token: token,
        id: id,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<UserModel>?> getAllAccounts() async {
    try {
      final storageController = Get.find<StorageController>();
      final token = await storageController.getToken();
      if (token == null) return null;

      final response = await _userService.getAllAccounts(token: token);
      if (response == null) return null;
      final decoded = json.decode(response.body);

      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return null;
      }
      final List data = decoded["data"] ?? [];
      if (data.isEmpty) return null;
      final List<UserModel> mapped =
          data.map((e) => UserModel.fromJson(e)).toList();
      return mapped;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<List<UserModel>?> getTopAccounts() async {
    try {
      final storageController = Get.find<StorageController>();
      final token = await storageController.getToken();
      if (token == null) return null;

      final response = await _userService.getTopAccounts(token: token);
      if (response == null) return null;
      final decoded = json.decode(response.body);

      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return null;
      }
      final List data = decoded["data"] ?? [];
      if (data.isEmpty) return null;
      final List<UserModel> mapped =
          data.map((e) => UserModel.fromJson(e)).toList();
      return mapped;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> notificationSettings({
    required bool pushNotification,
    required bool realTimeUpdate,
    required bool inboxNotification,
    required bool vibrate,
    required bool sound,
  }) async {
    try {
      final storageController = Get.find<StorageController>();
      final token = await storageController.getToken();
      if (token == null) return;

      final response = await _userService.notificationSettings(
        token: token,
        pushNotification: pushNotification,
        realTimeUpdate: realTimeUpdate,
        inboxNotification: inboxNotification,
        vibrate: vibrate,
        sound: sound,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      CustomSnackbar.showSuccessToast(message);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<NotificationSettingsModel?> getNotificationsSettings() async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      final token = await storageController.getToken();
      if (token == null) return null;

      final response = await _userService.getNotificationSettings(token: token);
      if (response == null) return null;
      final decoded = await json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return null;
      }
      final data = decoded["data"] ?? {};
      if (data.isEmpty) return null;
      final NotificationSettingsModel mapped =
          NotificationSettingsModel.fromJson(data);
      return mapped;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
    return null;
  }

  Future<List<UserModel>?> searchUser({required String search}) async {
    try {
      final storageController = Get.find<StorageController>();
      final token = await storageController.getToken();
      if (token == null) return null;

      final response = await _userService.searchUser(
        token: token,
        search: search,
      );

      if (response == null) return null;
      final decoded = await json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return null;
      }
      final List data = decoded["data"] ?? [];
      if (data.isEmpty) return null;
      final List<UserModel> mapped =
          data.map((e) => UserModel.fromJson(e)).toList();
      return mapped;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> editProfile({required UserModel userModel, File? avater}) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      final token = await storageController.getToken();
      if (token == null) return;

      final response = await _userService.editProfile(
        token: token,
        userModel: userModel,
        avatar: avater,
      );

      if (response == null) return;
      final decoded = await json.decode(response.body);

      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      await getUserDetails();
      CustomSnackbar.showSuccessToast(message);
      Get.offAllNamed(AppRoutes.bottomNavigation);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> verificationRequest({
    required File frontId,
    required File backId,
    required File selfieId,
    String verificationType = "profile",
    String? idType,
  }) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      final token = await storageController.getToken();
      if (token == null) return;

      final response = await _userService.verificationRequest(
        token: token,
        frontId: frontId,
        backId: backId,
        selfieId: selfieId,
        verificationType: verificationType,
        idType: idType,
      );

      if (response == null) return;
      final decoded = await json.decode(response.body);

      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }

      CustomSnackbar.showSuccessToast(message);
      Get.offAllNamed(AppRoutes.bottomNavigation);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> createTicket({
    required List<File> attachments,
    required String subject,
    required String description,
  }) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      final token = await storageController.getToken();
      if (token == null) return;

      final response = await _userService.createTicket(
        token: token,
        attachments: attachments,
        subject: subject,
        description: description,
      );

      if (response == null) return;
      final decoded = await json.decode(response.body);

      String message = decoded["message"] ?? "";
      if (response.statusCode != 201) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      CustomSnackbar.showSuccessToast(message);
      Get.offAllNamed(AppRoutes.bottomNavigation);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<List<UserModel>?> viewAllFollowing({required String userId}) async {
    try {
      final storageController = Get.find<StorageController>();
      final token = await storageController.getToken();
      if (token == null) return null;

      final response = await _userService.viewAllFollowing(
        token: token,
        userId: userId,
      );
      if (response == null) return null;
      final decoded = await json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return null;
      }
      List userData = decoded["data"] ?? [];
      if (userData.isEmpty) return null;
      final List<UserModel> users =
          userData.map((e) => UserModel.fromJson(e)).toList();
      return users;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<List<UserModel>?> viewAllFollowers({required String userId}) async {
    try {
      final storageController = Get.find<StorageController>();
      final token = await storageController.getToken();
      if (token == null) return null;

      final response = await _userService.viewAllFollowers(
        token: token,
        userId: userId,
      );
      if (response == null) return null;
      final decoded = await json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return null;
      }
      List userData = decoded["data"] ?? [];
      if (userData.isEmpty) return null;
      final List<UserModel> users =
          userData.map((e) => UserModel.fromJson(e)).toList();
      return users;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> toggleGhostMode() async {
    try {
      userModel.value!.ghostMode!.value = !userModel.value!.ghostMode!.value;
      final storageController = Get.find<StorageController>();
      final token = await storageController.getToken();
      if (token == null) return;

      final response = await _userService.toggleGhostMode(token: token);
      if (response == null) return;
      final decoded = await json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void clean() {
    userModel.value = null;
    isUserDetailsFetched.value = false;
    isloading.value = false;
    blockedUsers.clear();
  }
}
