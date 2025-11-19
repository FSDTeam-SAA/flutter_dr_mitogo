import 'package:casarancha/app/controller/auth_controller.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/modules/auth/controller/signup_controller.dart';
import 'package:casarancha/app/modules/auth/widgets/auth_widget.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/utils/validator.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupFormFields extends StatelessWidget {
  SignupFormFields({super.key});

  final controller = Get.put(SignUpController());
  final formKey = GlobalKey<FormState>();
  final authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: StaggeredColumnAnimation(
        duration: Duration(milliseconds: 200),
        children: [
          Text("Name", style: Get.textTheme.bodyMedium),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: "Enter Name",
            controller: controller.nameController,
          ),
          const SizedBox(height: 15),
          Text("Email", style: Get.textTheme.bodyMedium),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: "Enter Email",
            controller: controller.emailController,
            validator: validateEmail,
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
          const SizedBox(height: 15),
          Row(
            children: [
              Obx(
                () => Checkbox(
                  value: controller.isCheckValue.value,
                  visualDensity: VisualDensity.compact,
                  activeColor: AppColors.primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) {
                    controller.isCheckValue.value = value!;
                  },
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Get.theme.primaryColor),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "Or sign up with",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 15),
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
                  await authController.googleAuthSignUp();
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
          const SizedBox(height: 20),
          CustomButton(
            ontap: () async {
              HapticFeedback.lightImpact();
              if (!formKey.currentState!.validate()) return;
              if (!controller.isCheckValue.value) {
                CustomSnackbar.showErrorToast(
                  "Please accept the terms and conditions",
                );
                return;
              }
              final userModel = UserModel(
                displayName: controller.nameController.text,
                email: controller.emailController.text.trim(),
                password: controller.passwordController.text,
              );
              await authController.register(userModel: userModel);
            },
            isLoading: authController.isLoading,
            child: Text(
              "Create Account",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: Get.textTheme.bodyMedium,
              ),
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.login);
                  controller.clean();
                },
                child: Text(
                  "Login",
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
