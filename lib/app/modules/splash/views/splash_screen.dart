import 'package:casarancha/app/controller/socket_controller.dart';
import 'package:casarancha/app/controller/storage_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> fadeAnimation;

  final userController = Get.find<UserController>();
  final socketController = Get.find<SocketController>();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.bounceOut),
      ),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Navigation logic after splash
    Future.delayed(const Duration(seconds: 3), () async {
      final storageController = Get.find<StorageController>();
      bool newUser = await storageController.getUserStatus();

      if (newUser) {
        Get.offAllNamed(AppRoutes.onboarding);
        await storageController.saveStatus("notNewAgain");
        return;
      }

      String? token = await storageController.getToken();
      if (token == null || token.isEmpty) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      await userController.getUserDetails();
      await userController.getUserStatus();
      await socketController.initializeSocket();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            // Logo with bounce + fade animation (center)
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bounceAnimation.value),
                    child: Opacity(
                      opacity: fadeAnimation.value,
                      child: Image.asset(
                        'assets/images/loogo.png',
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.45,
                      ),
                    ),
                  );
                },
              ),
            ),

            // "Rex & Mitogo family" text at bottom center
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 40,
                ), // adjust spacing as needed
                child: Text(
                  "Rex & Mitogo family",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                    letterSpacing: 0.8,
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
