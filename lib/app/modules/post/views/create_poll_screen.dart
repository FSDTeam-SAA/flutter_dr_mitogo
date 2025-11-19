import 'package:casarancha/app/modules/post/controller/create_poll_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePollScreen extends StatelessWidget {
  final String? groupId;
  final String? groupName;
  CreatePollScreen({super.key, this.groupId, this.groupName});

  final controller = Get.put(CreatePollController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height * 0.15),
              Text(
                "Ask a Question",
                style: Get.textTheme.labelLarge!.copyWith(fontSize: 15),
              ),
              SizedBox(height: Get.height * 0.02),
              CustomTextField(
                controller: controller.questionController,
                label: "Write something...",
                floatingLabelBehavior: FloatingLabelBehavior.never,
                bgColor: const Color.fromRGBO(244, 244, 247, 1),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                minLines: 5,
                maxLines: 6,
              ),
              SizedBox(height: Get.height * 0.02),
              Text(
                "Options",
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),

              // Dynamic Options List
              Obx(
                () => Column(
                  children: List.generate(
                    controller.optionControllers.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: CustomTextField(
                        controller: controller.optionControllers[index],
                        hintText: "Option ${index + 1}",
                        bgColor: const Color(0xFFF7F7F9),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        suffixIcon: FontAwesomeIcons.xmark,
                        suffixIconcolor:
                            controller.optionControllers.length > 2
                                ? Colors.red
                                : Colors.grey.shade400,
                        onSuffixTap: () => controller.removeOption(index),
                      ),
                    ),
                  ),
                ),
              ),

              // Add Option Button
              Row(
                children: [
                  InkWell(
                    onTap: () => controller.addOption(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.plus,
                            size: 14,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Add Option",
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Obx(
                    () => Text(
                      "${controller.optionControllers.length} options",
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: Get.height * 0.1),

              // Create Button
              CustomButton(
                ontap: () async {
                  await controller.createPoll(
                    groupId: groupId,
                    groupName: groupName,
                  );
                },
                isLoading: controller.isLoading,
                borderRadius: BorderRadius.circular(15),
                child: Text(
                  "Create Poll",
                  style: Get.textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "Create Poll",
        style: Get.textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: InkWell(
          onTap: () => Get.back(),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ),
      leadingWidth: 40,
    );
  }
}
