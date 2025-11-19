import 'package:casarancha/app/modules/auth/widgets/signup_form_fields.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.08),
              Image.asset(
                "assets/images/loogo.png",
                fit: BoxFit.contain,
                width: Get.width * 0.24,
              ),
              const SizedBox(height: 5),
              Text("Sign Up", style: Get.textTheme.bodyLarge),
              Text(
                "Welcome! Please enter  information below to Sign up",
                textAlign: TextAlign.center,
                style: Get.textTheme.labelMedium,
              ),
              SizedBox(height: Get.height * 0.03),
              SignupFormFields(),
            ],
          ),
        ),
      ),
    );
  }
}
