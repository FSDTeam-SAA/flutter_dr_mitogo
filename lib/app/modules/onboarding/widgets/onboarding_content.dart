import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/onboarding_data.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingData onboardingData;
  const OnboardingContent({super.key, required this.onboardingData});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // Image section
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                width: Get.width * 1,
                height: Get.height * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(onboardingData.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Content container
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  onboardingData.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  onboardingData.description,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
