import 'package:casarancha/app/modules/verification/controller/verification_controller.dart';
import 'package:casarancha/app/modules/verification/widgets/verification_widgets.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late final VerificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(VerificationController());
    final args = Get.arguments;
    if (args is Map && args["verificationType"] is String) {
      final verificationType = (args["verificationType"] as String).trim();
      if (verificationType.isNotEmpty) {
        controller.setVerificationType(verificationType);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: _buildAppBar(),
      body: SafeArea(
        child: Container(
          width: Get.width,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(gradient: AppColors.bgGradient),
          child: Obx(() => _buildCurrentStep()),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    final currentStep = controller.currentStep.value;
    switch (currentStep) {
      case 0:
        return BuildIdSelectionStep();
      case 1:
        return BuildFrontIdUploadStep();
      case 2:
        return BuildBackIdUploadStep();
      case 3:
        return BuildSelfieStep();
      case 4:
        return BuildReviewStep();
      default:
        return BuildIdSelectionStep();
    }
  }

  @override
  void dispose() {
    Get.delete<VerificationController>();
    super.dispose();
  }

  // AppBar _buildAppBar() {
  //   return AppBar(
  //     backgroundColor: Color(0xFFFFE7E6),
  //     centerTitle: true,
  //     elevation: 0,
  //     title: Text(
  //       "Verification",
  //       style: Get.textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
  //     ),
  //     leading: Padding(
  //       padding: const EdgeInsets.only(left: 5),
  //       child: InkWell(
  //         onTap: () => Get.back(),
  //         child: CircleAvatar(
  //           backgroundColor: AppColors.primaryColor,
  //           child: const Icon(
  //             Icons.arrow_back_ios_new,
  //             size: 12,
  //             color: Colors.white,
  //           ),
  //         ),
  //       ),
  //     ),
  //     leadingWidth: 45,
  //   );
  // }
}
