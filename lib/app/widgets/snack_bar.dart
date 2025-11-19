import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSnackbar {
  static void showErrorToast(String message) {
    CherryToast.error(
      title: Text(
        "Error",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: GoogleFonts.poppins(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(216, 244, 67, 54),
      animationDuration: const Duration(milliseconds: 300),
      autoDismiss: true,
      borderRadius: 14,
      iconWidget: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.error, size: 23, color: Colors.red),
        ),
      ),
      enableIconAnimation: true,
    ).show(Get.context!);
  }

  static void showSuccessToast(String message) {
    CherryToast.success(
      title: Text(
        "Success",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: GoogleFonts.poppins(color: Colors.white),
      ),
      backgroundColor: Colors.green,
      animationDuration: const Duration(milliseconds: 300),
      autoDismiss: true,
      borderRadius: 14,
      iconWidget: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.check_circle, size: 23, color: Colors.green),
        ),
      ),
      enableIconAnimation: true,
    ).show(Get.context!);
  }
}
