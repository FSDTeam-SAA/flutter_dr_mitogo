import 'dart:io';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CompleteProfileFormFields extends StatelessWidget {
  final Rxn<File> selectedPicture;
  CompleteProfileFormFields({super.key, required this.selectedPicture});

  final formKey = GlobalKey<FormState>();
  final _userNameValidator = GlobalKey<FormState>();
  final _userController = Get.find<UserController>();

  final _selectedDate = Rxn<DateTime>();
  final usernameController = TextEditingController();
  final educationController = TextEditingController();
  final workController = TextEditingController();
  final bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: StaggeredColumnAnimation(
        children: [
          Row(
            children: [
              Text("Date of Birth", style: Get.textTheme.bodyMedium),
              Text(
                '*',
                style: Get.textTheme.bodyMedium?.copyWith(color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Obx(
            () => CustomTextField(
              hintText:
                  _selectedDate.value != null
                      ? DateFormat("MMM dd, yyyy").format(_selectedDate.value!)
                      : "dd/mm/yyyy",
              readOnly: true,
              validator: (_) => null,
              suffixIcon: FontAwesomeIcons.solidCalendar,
              onTap: () async {
                final DateTime? picked = await displayCalender();
                if (picked != null) {
                  _selectedDate.value = picked;
                }
              },
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text("Username", style: Get.textTheme.bodyMedium),
              Text(
                '*',
                style: Get.textTheme.bodyMedium?.copyWith(color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 5),
          buildUserNameTextFieldAutoValidate(),
          const SizedBox(height: 15),
          Text("education".tr, style: Get.textTheme.bodyMedium),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: "ABC School",
            controller: educationController,
            validator: (_) => null,
          ),
          const SizedBox(height: 15),
          Text("work".tr, style: Get.textTheme.bodyMedium),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: "XYZ Company",
            controller: workController,
            validator: (_) => null,
          ),
          const SizedBox(height: 15),
          Text("biography".tr, style: Get.textTheme.bodyMedium),
          const SizedBox(height: 5),
          CustomTextField(
            hintText: "Write here",
            controller: bioController,
            validator: (_) => null,
          ),
          const SizedBox(height: 30),
          CustomButton(
            ontap: () async {
              HapticFeedback.lightImpact();
              if (!_userNameValidator.currentState!.validate()) return;
              if (!formKey.currentState!.validate()) return;
              if (selectedPicture.value == null) {
                CustomSnackbar.showErrorToast(
                  "Please select a profile picture",
                );
                return;
              }
              if (_selectedDate.value == null) {
                CustomSnackbar.showErrorToast("Please select a date");
                return;
              }
              if (_userController.isloading.value) return;
              final userModel = UserModel(
                username: usernameController.text,
                education: educationController.text,
                work: workController.text,
                bio: bioController.text,
                dateOfBirth: _selectedDate.value!,
              );
              await _userController.completeProfileScreen(
                userModel: userModel,
                imageFile: selectedPicture.value!,
                nextScreen: () {
                  Get.offAllNamed(AppRoutes.bottomNavigation);
                },
              );
            },
            isLoading: _userController.isloading,
            child: Text(
              "Continue",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Form buildUserNameTextFieldAutoValidate() {
    return Form(
      key: _userNameValidator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: TextFormField(
        controller: usernameController,
        cursorColor: AppColors.primaryColor,
        style: Get.textTheme.bodyMedium,
        validator: (value) {
          if (value!.isEmpty) {
            return "Username is required";
          }
          if (value.length < 6) {
            return "Username must be at least 6 characters long";
          }
          if (value.length > 20) {
            return "Username must be at most 20 characters long";
          }
          if (!value.contains(RegExp(r"^[a-zA-Z0-9_]*$"))) {
            return "Username must contain only letters, numbers, and underscores ";
          }
          if (value.contains(RegExp(r"^[0-9]*$"))) {
            return "Username must contain at least one letter";
          }
          if (value.contains(RegExp(r"^[a-zA-Z]*$"))) {
            return "Username must contain at least one number";
          }
          return null;
        },
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(width: 1, color: AppColors.fieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(width: 1, color: AppColors.primaryColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(width: 1, color: Colors.red),
          ),
          errorStyle: GoogleFonts.fredoka(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Colors.red,
          ),
          errorMaxLines: 2,
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(width: 2, color: Colors.red),
          ),
        ),
      ),
    );
  }

  Future<DateTime?> displayCalender() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }
}
