
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

BoxDecoration chatInputFieldDecoration({bool? showBorderRadius = true}) {
  if (Get.isDarkMode) {
    return BoxDecoration(
      color: Colors.black,
      borderRadius:
          showBorderRadius == false ? null : BorderRadius.circular(30),
      border: Border.all(
        color: const Color(0xFFE0E0E0),
        width: 1,
      ),
    );
  }
  return BoxDecoration(
    color: AppColors.lightGrey,
    borderRadius: showBorderRadius == false ? null : BorderRadius.circular(30),
    border: Border.all(
      color: const Color(0xFFE0E0E0),
    ),
    boxShadow: [
      const BoxShadow(
        color: Colors.white, // Light shadow (top-left)
        offset: Offset(-3, -3),
        blurRadius: 6,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.15), // Dark shadow (bottom-right)
        offset: const Offset(3, 3),
        blurRadius: 6,
        spreadRadius: 1,
      ),
    ],
  );
}
