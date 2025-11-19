import 'package:casarancha/app/controller/auth_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});

  final formKey = GlobalKey<FormState>();
  final controller = Get.put(AuthController());
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isPasswordVisible = true.obs;
  final isConfirmPasswordVisible = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: StaggeredColumnAnimation(
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
                child: Text("Reset Password", style: Get.textTheme.labelLarge),
              ),
              Center(
                child: Text(
                  "Please enter your new password",
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
                    Text("Password", style: Get.textTheme.bodyMedium),
                    const SizedBox(height: 5),
                    Obx(
                      () => CustomTextField(
                        controller: passwordController,
                        hintText: "Enter Password ",
                        isObscure: isPasswordVisible.value,
                        suffixIcon:
                            isPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                        onSuffixTap: () {
                          isPasswordVisible.value = !isPasswordVisible.value;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Confirm Password", style: Get.textTheme.bodyMedium),
                    const SizedBox(height: 5),
                    Obx(
                      () => CustomTextField(
                        controller: confirmPasswordController,
                        hintText: "Enter Confirm Password",
                        isObscure: isConfirmPasswordVisible.value,
                        suffixIcon:
                            isConfirmPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                        onSuffixTap: () {
                          isConfirmPasswordVisible.value =
                              !isConfirmPasswordVisible.value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "";
                          }
                          if (value != passwordController.text) {
                            return "Password does not match";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              SizedBox(height: Get.height * 0.2),
              CustomButton(
                ontap: () async {
                  if (!formKey.currentState!.validate()) return;
                  await controller.resetPassword(
                    password: passwordController.text,
                  );
                },
                isLoading: controller.isLoading,
                child: Text(
                  "Continue",
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
