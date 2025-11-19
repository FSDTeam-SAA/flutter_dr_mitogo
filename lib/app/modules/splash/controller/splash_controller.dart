import 'package:casarancha/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdvancedSplashController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> bounceAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> combinedAnimation;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Scale animation with bounce effect
    scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    // Bounce animation (vertical movement)
    bounceAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.bounceOut),
    ));

    // Fade animation
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));

    combinedAnimation = animationController;
  }

  void _startAnimationSequence() async {
    animationController.forward();
    await Future.delayed(const Duration(seconds: 3));
    Get.toNamed(AppRoutes.onboarding);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}