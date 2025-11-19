import 'package:casarancha/app/modules/auth/widgets/login_form_fields.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: StaggeredColumnAnimation(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: Get.height * 0.1),
              Image.asset(
                "assets/images/loogo.png",
                fit: BoxFit.contain,
                width: Get.width * 0.24,
              ),
              const SizedBox(height: 20),
              Text("Hey! Welcome Back", style: Get.textTheme.bodyLarge),
              Text(
                "Welcome! Please enter your information below and get started.",
                textAlign: TextAlign.center,
                style: Get.textTheme.labelMedium,
              ),
              SizedBox(height: Get.height * 0.03),
              LoginFormFields(),
            ],
          ),
        ),
      ),
    );
  }
}
