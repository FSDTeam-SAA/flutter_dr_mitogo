import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  static const Color primaryColor = Color(0xFFA90503);
  static const Color lightGrey = Color.fromRGBO(160, 160, 160, 1);
  static Color fieldBackground = const Color(0xFF262626);
  static LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE7E6), Color(0xFFFFFFFF)],
    stops: [0.0, 0.3],
  );

  static Color get fieldBorder =>
      Get.isDarkMode ? const Color(0xFF404040) : Colors.grey.shade300;
  static Color fieldFocus = const Color(0xFFFF8C42);



  static const Color senderStart = Color(0xFFFF6B35);
  static const Color senderEnd = Color(0xFFF7931E);
  static const Color senderText = Colors.white;

  // Receiver (other person's messages)
  static const Color receiverBackground = Color(0xFFF1F3F4);
  static const Color receiverBorder = Color(0xFFE1E5E9);
  static const Color receiverText = Color(0xFF2C3E50);

  // Chat background
  static const Color chatBackground = Color(0xFFF8F9FA);

  // 🎯 NEW: Highlight colors for reply feature
  static const Color senderHighlightStart = Color(0xFFFF8A65);
  static const Color senderHighlightEnd = Color(0xFFFFB74D);
  static const Color senderHighlightShadow = Color(0x66FF8A65);

  static const Color receiverHighlightBackground = Color(0xFFFFF8E1);
  static const Color receiverHighlightBorder = Color(0xFFFFD54F);
  static const Color receiverHighlightShadow = Color(0x4DFFD54F);
}
