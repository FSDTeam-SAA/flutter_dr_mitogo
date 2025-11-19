import 'package:casarancha/app/modules/auth/widgets/auth_widget.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:casarancha/app/modules/auth/controller/login_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginFormFields extends StatelessWidget {
  LoginFormFields({super.key});

  final controller = Get.put(LoginController());
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          Text("Email", style: Get.textTheme.bodyMedium),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: "Enter Email",
            controller: controller.emailController,
          ),
          const SizedBox(height: 15),
          Text("Password", style: Get.textTheme.bodyMedium),
          const SizedBox(height: 5),
          Obx(
            () => CustomTextField(
              hintText: "Enter Password",
              isObscure: controller.isPasswordVisible.value,
              controller: controller.passwordController,
              suffixIcon:
                  controller.isPasswordVisible.value
                      ? Icons.visibility
                      : Icons.visibility_off,
              onSuffixTap: () {
                controller.isPasswordVisible.value =
                    !controller.isPasswordVisible.value;
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                Get.toNamed(AppRoutes.forgotPassword);
                controller.clean();
              },
              child: Text(
                "Forgot Password?",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: Get.height * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildSocialMediaLoginButtton(
                icon: Icons.facebook,
                color: Colors.blue,
                onTap: () {},
              ),
              buildSocialMediaLoginButtton(
                icon: FontAwesomeIcons.google,
                color: Colors.red,
                onTap: () async {
                  await controller.authController.googleAuthSignIn();
                },
              ),
              buildSocialMediaLoginButtton(
                icon: Icons.apple,
                color: Colors.black,
                onTap: () {},
              ),
              buildSocialMediaLoginButtton(
                icon: Icons.phone,
                color: Colors.blue,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: Get.height * 0.05),
          CustomButton(
            ontap: () async {
              HapticFeedback.lightImpact();
              if (!formKey.currentState!.validate()) return;
              await controller.loginUser(
                email: controller.emailController,
                password: controller.passwordController,
              );
            },
            isLoading: controller.authController.isLoading,
            child: Text(
              "Login",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: Get.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? ", style: Get.textTheme.bodyMedium),
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.signup);
                  controller.clean();
                },
                child: Text(
                  "Sign Up",
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
