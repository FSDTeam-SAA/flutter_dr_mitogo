import 'package:casarancha/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSettingBottomSheet extends StatelessWidget {
  ProfileSettingBottomSheet({super.key});

  final List<String> _reportReasons = [
    "Edit Profile",
    "Saved Posts",
    "About",
    "Terms & Conditions",
    "Privacy Policy",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.38,
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: _reportReasons.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              _reportReasons[index],
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              if (index == 0) {
                Get.toNamed(AppRoutes.editProfile);
              } else {
                Get.snackbar(
                  "Feature",
                  "${_reportReasons[index]} is not available yet",
                );
              }
            },
            contentPadding: EdgeInsets.zero,
          );
        },
      ),
    );
  }
}
