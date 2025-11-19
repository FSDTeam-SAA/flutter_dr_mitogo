import 'package:casarancha/app/controller/auth_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends StatelessWidget {
  final VoidCallback? onTap;
  final String email;
  OTPScreen({super.key, this.onTap, required this.email});

  final authController = Get.find<AuthController>();
  final pinController = TextEditingController();

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
              Center(child: Text("Enter OTP", style: Get.textTheme.labelLarge)),
              Center(
                child: Text(
                  "We’ve sent a verification code to\n$email",
                  textAlign: TextAlign.center,
                  style: Get.textTheme.bodySmall,
                ),
              ),
              SizedBox(height: Get.height * 0.06),
              Center(
                child: Pinput(
                  controller: pinController,
                  onCompleted: (value) async {
                    await authController.verifyOtp(
                      otpCode: value,
                      email: email,
                      whatNext: () {
                        if (onTap != null) {
                          onTap!();
                        } else {
                          Get.toNamed(AppRoutes.completeProfile);
                        }
                      },
                    );
                  },
                  defaultPinTheme: PinTheme(
                    width: 65,
                    height: 65,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color.fromRGBO(54, 69, 79, 0.26),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Didn’t receive code? ", style: Get.textTheme.bodySmall),
                  TextButton(
                    onPressed: () async {
                      await authController.sendOtp(email: email);
                    },
                    child: Text("Resend", style: Get.textTheme.labelSmall),
                  ),
                ],
              ),
              SizedBox(height: Get.height * 0.35),
              CustomButton(
                ontap: () async {
                  await authController.verifyOtp(
                    otpCode: pinController.text,
                    email: email,
                    whatNext: () {
                      if (onTap != null) {
                        onTap!();
                      } else {
                        Get.toNamed(AppRoutes.completeProfile);
                      }
                    },
                  );
                },
                isLoading: authController.isOtpVerifyLoading,
                child: Text(
                  "Verify OTP",
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
