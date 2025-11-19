import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/modules/level/widgets/level_stepper.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildLevelInformaion extends StatelessWidget {
  BuildLevelInformaion({super.key});

  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.userLevel);
      },
      child: Container(
        width: Get.width,
        height: Get.height * 0.13,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xffFFB4B3),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: Get.height * 0.015,
              left: 0,
              child: Image.asset(
                "assets/images/cup.png",
                width: 90,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                "assets/images/hand.png",
                width: 50,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: Get.height * 0.02,
              left: Get.width * 0.17,
              child: SizedBox(
                width: Get.width * 0.65,
                child: Column(
                  children: [
                    Obx(() {
                      final ghostProgression =
                          userController.userModel.value?.ghostProgression;

                      int postLeft =
                          ghostProgression!.nextLevelRequirements.postsNeeded -
                          ghostProgression.postsMade;

                      return Text(
                        "$postLeft Posts are left to reach level ${getLevel(ghostProgression.nextLevelRequirements.level)}",
                        style: Get.textTheme.bodyMedium!.copyWith(fontSize: 12),
                      );
                    }),
                    SizedBox(height: 10),
                    Obx(() {
                      final ghostProgression =
                          userController.userModel.value?.ghostProgression;
                      final level = ghostProgression?.level;
                      return LevelStepper(
                        progress: getProgress(currentLevel: level ?? "A"),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getProgress({required String currentLevel}) {
    currentLevel = currentLevel.toUpperCase();
    if (currentLevel == "A") {
      return 0.0;
    }
    if (currentLevel == "B") {
      return 1.0;
    }
    if (currentLevel == "C") {
      return 2.0;
    }
    if (currentLevel == "D") {
      return 3.0;
    }
    return 0.0;
  }

  getLevel(String level) {
    switch (level.toLowerCase()) {
      case "a":
        return "1";
      case "b":
        return "2";
      case "c":
        return "3";
      case "d":
        return "4";
      default:
    }
  }
}
