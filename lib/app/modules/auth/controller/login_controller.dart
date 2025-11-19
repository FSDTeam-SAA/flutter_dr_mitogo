import 'package:casarancha/app/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final authController = Get.find<AuthController>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordVisible = false.obs;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser({
    required TextEditingController email,
    required TextEditingController password,
  }) async {
    await authController.loginUser(email: email, password: password);
  }

  void clean() {
    emailController.clear();
    passwordController.clear();
  }
}
