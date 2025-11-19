import 'package:casarancha/app/modules/onboarding/controller/onboarding_controller.dart';
import 'package:casarancha/app/modules/onboarding/models/onboarding_data.dart';
import 'package:casarancha/app/modules/onboarding/widgets/onboarding_background.dart';
import 'package:casarancha/app/modules/onboarding/widgets/onboarding_content.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BuildOnboardingBgScreen(
        child: Stack(
          children: [
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: OnboardingData.getOnboardingData().length,
              itemBuilder: (context, index) {
                final data = OnboardingData.getOnboardingData()[index];
                return AnimatedBuilder(
                  animation: controller.pageController,
                  builder: (context, child) {
                    double value = 0.0;
                    if (controller.pageController.position.haveDimensions) {
                      value = (controller.pageController.page ?? 0) - index;
                    }

                    double offset = value.clamp(-1.0, 1.0);
                    double opacity = 1.0 - offset.abs();

                    return Transform.translate(
                      offset: Offset(offset * 50, 0),
                      child: Opacity(opacity: opacity, child: child),
                    );
                  },
                  child: OnboardingContent(onboardingData: data),
                );
              },
            ),
            Positioned(
              bottom: Get.height * 0.2,
              left: Get.width * 0.433,
              child: Obx(
                () => AnimatedSmoothIndicator(
                  activeIndex: controller.currentPage.value,
                  count: OnboardingData.getOnboardingData().length,
                  effect: WormEffect(
                    dotWidth: 8,
                    dotHeight: 8,
                    dotColor: Colors.white.withValues(alpha: 0.7),
                    activeDotColor: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () {
                  controller.nextPage();
                },
                child: Container(
                  height: 60,
                  width: 60,
                  padding: const EdgeInsets.all(2),
                  margin: EdgeInsets.only(bottom: Get.height * 0.08),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(color: AppColors.primaryColor, width: 1),
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.primaryColor,
                    child: Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: Get.height * 0.08,
              right: Get.width * 0.05,
              child: InkWell(
                onTap: () {
                  controller.skipToEnd();
                },
                child: Text(
                  "Skip",
                  style: GoogleFonts.montserrat(
                    color: AppColors.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
