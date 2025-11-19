import 'package:casarancha/app/modules/onboarding/controller/onboarding_controller.dart';
import 'package:casarancha/app/modules/onboarding/widgets/wave_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildOnboardingBgScreen extends StatelessWidget {
  final Widget child;
  BuildOnboardingBgScreen({super.key, required this.child});

  final controller = Get.find<OnboardingController>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(169, 5, 3, 0.86),
                          Color.fromRGBO(196, 30, 58, 0.47),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(60),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFE7E6), Color(0xFFFFFFFF)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: Container(color: Colors.white)),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(169, 5, 3, 0.86),
                          Color.fromRGBO(196, 30, 58, 0.47),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    child: WaveformWidget(
                      width: Get.width,
                      height: 125.0,
                      color: Colors.white.withOpacity(0.25),
                      strokeWidth: 0.5,
                      middleAmplitude: 0.65,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}
