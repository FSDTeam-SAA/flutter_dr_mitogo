import 'package:casarancha/app/controller/auth_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final formKey = GlobalKey<FormState>();
  final authController = Get.find<AuthController>();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height * 0.1),
              Center(
                child: Image.asset(
                  "assets/images/loogo.png",
                  fit: BoxFit.contain,
                  width: Get.width * 0.24,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Forgot ID/Password",
                  style: Get.textTheme.labelLarge,
                ),
              ),
              Center(
                child: Text(
                  "Please enter your email address to request\na password reset",
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodySmall,
                ),
              ),
              SizedBox(height: Get.height * 0.06),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email", style: Get.textTheme.bodyMedium),
                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: emailController,
                      hintText: "Enter your email",
                    ),
                    SizedBox(height: Get.height * 0.3),
                  ],
                ),
              ),
              CustomButton(
                ontap: () async {
                  HapticFeedback.lightImpact();
                  if (!formKey.currentState!.validate()) return;
                  await authController.sendOtpForgotPassword(
                    email: emailController.text,
                  );
                },
                isLoading: authController.isLoading,
                child: Text(
                  "Send OTP",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
