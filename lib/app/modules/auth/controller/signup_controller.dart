
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  var isPasswordVisible = false.obs;
  var isCheckValue = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void clean() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }
}