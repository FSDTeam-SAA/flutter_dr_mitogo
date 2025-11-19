import 'dart:convert';

import 'package:casarancha/app/controller/message_controller.dart';
import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/controller/socket_controller.dart';
import 'package:casarancha/app/controller/storage_controller.dart';
import 'package:casarancha/app/controller/story_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/data/services/auth_service.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isOtpVerifyLoading = false.obs;
  final _authService = AuthService();
  final _storageController = Get.find<StorageController>();

  Future<void> googleAuthSignUp() async {
    isLoading.value = true;
    try {
      final idToken = await _authService.signInWithGoogle();
      if (idToken == null) {
        return;
      }
      final response = await _authService.sendGoogleToken(
        token: idToken,
        isRegister: true,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 201) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      final userController = Get.find<UserController>();
      String token = decoded["token"];
      await _storageController.storeToken(token);
      final socketController = Get.find<SocketController>();
      socketController.initializeSocket();
      await userController.getUserDetails();
      Get.toNamed(AppRoutes.completeProfile);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> googleAuthSignIn() async {
    isLoading.value = true;
    try {
      final idToken = await _authService.signInWithGoogle();
      if (idToken == null) {
        CustomSnackbar.showErrorToast("Failed to sign in with Google");
        return;
      }
      final response = await _authService.sendGoogleToken(
        token: idToken,
        isRegister: false,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      String token = decoded["token"] ?? "";
      String email = decoded["email"] ?? "";
      final storageController = Get.find<StorageController>();
      await storageController.storeToken(token);
      if (response.statusCode == 404) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      if (response.statusCode == 402) {
        CustomSnackbar.showErrorToast(message);
        Get.offAllNamed(AppRoutes.signup);
        return;
      }
      final socketController = Get.find<SocketController>();
      await socketController.initializeSocket();
      if (response.statusCode == 401) {
        CustomSnackbar.showErrorToast(message);
        Get.offAllNamed(
          AppRoutes.otp,
          arguments: {
            "email": email,
            "onTap": () {
              Get.offAllNamed(AppRoutes.bottomNavigation);
            },
          },
        );
        return;
      }
      if (response.statusCode == 400) {
        CustomSnackbar.showErrorToast(message);
        Get.offAllNamed(AppRoutes.completeProfile);
        return;
      }
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      final userController = Get.find<UserController>();
      await userController.getUserDetails();
      Get.offAllNamed(AppRoutes.bottomNavigation);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({required UserModel userModel}) async {
    isLoading.value = true;
    try {
      final response = await _authService.register(userModel: userModel);
      if (response == null) return;
      final decoded = json.decode(response.body);
      var message = decoded["message"] ?? "";
      if (response.statusCode != 201) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      final userController = Get.find<UserController>();
      String token = decoded["token"];
      await _storageController.storeToken(token);
      final socketController = Get.find<SocketController>();
      socketController.initializeSocket();
      await userController.getUserDetails();
      Get.toNamed(AppRoutes.otp, arguments: {"email": userModel.email});
    } catch (e) {
      debugPrint("Error From Auth Controller: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp({required String email}) async {
    isLoading.value = true;
    try {
      final response = await _authService.sendOtp(email: email);
      if (response == null) return;
      final decoded = json.decode(response.body);
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(
          "Failed to get OTP, ${decoded["message"]}",
        );
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp({
    required String otpCode,
    String? email,
    String? phoneNumber,
    VoidCallback? whatNext,
  }) async {
    isOtpVerifyLoading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      String? token = await storageController.getToken();
      if (token == null || token.isEmpty) return;
      final response = await _authService.verifyOtp(
        otpCode: otpCode,
        email: email,
        phoneNumber: phoneNumber,
        token: token,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }

      if (whatNext != null) {
        whatNext();
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isOtpVerifyLoading.value = false;
    }
  }

  Future<void> sendOtpForgotPassword({required String email}) async {
    isLoading.value = true;
    try {
      final response = await _authService.sendOtpForgotPassword(email: email);
      if (response == null) return;
      final decoded = json.decode(response.body);
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(
          "Failed to get OTP, ${decoded["message"]}",
        );
        return;
      }
      final token = decoded["token"];
      await _storageController.storeToken(token);
      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          "email": email,
          "onTap": () {
            Get.offAllNamed(AppRoutes.resetPassword);
          },
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword({required String password}) async {
    isLoading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      String? token = await storageController.getToken();
      if (token == null || token.isEmpty) return;
      final response = await _authService.resetPassword(
        token: token,
        password: password,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      await storageController.deleteToken();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginUser({
    required TextEditingController email,
    required TextEditingController password,
  }) async {
    isLoading.value = true;
    try {
      final response = await _authService.loginUser(
        email: email.text,
        password: password.text,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      String token = decoded["token"] ?? "";
      final storageController = Get.find<StorageController>();
      await storageController.storeToken(token);
      if (response.statusCode == 404) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      if (response.statusCode == 402) {
        CustomSnackbar.showErrorToast(message);
        Get.offAllNamed(AppRoutes.signup);
        return;
      }
      final socketController = Get.find<SocketController>();
      await socketController.initializeSocket();
      if (response.statusCode == 401) {
        CustomSnackbar.showErrorToast(message);
        Get.offAllNamed(
          AppRoutes.otp,
          arguments: {
            "email": email.text,
            "onTap": () {
              Get.offAllNamed(AppRoutes.bottomNavigation);
            },
          },
        );
        return;
      }
      if (response.statusCode == 405) {
        CustomSnackbar.showErrorToast(message);
        Get.offAllNamed(AppRoutes.completeProfile);
        return;
      }
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      final userController = Get.find<UserController>();
      await userController.getUserDetails();
      Get.offAllNamed(AppRoutes.bottomNavigation);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      email.clear();
      password.clear();
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      Get.offAllNamed(AppRoutes.login);
      Get.find<UserController>().clean();
      Get.find<StoryController>().clearUserData();
      Get.find<MessageController>().clearChatHistory();
      Get.find<SocketController>().disconnectSocket();

      final token = await Get.find<StorageController>().getToken();
      if (token == null) return;

      final response = await _authService.deleteAccount(token: token);
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";

      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      
      Get.find<StorageController>().deleteToken();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      Get.offAllNamed(AppRoutes.login);
      Get.find<UserController>().clean();
      Get.find<PostController>().clean();
      Get.find<StoryController>().clearUserData();
      Get.find<MessageController>().clearChatHistory();
      Get.find<SocketController>().disconnectSocket();
      Get.find<StorageController>().deleteToken();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
