import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AltVerificationScreen extends StatelessWidget {
  const AltVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(gradient: AppColors.bgGradient),
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.03),
              _buildSettingTile(
                title: "Name Verification",
                onTap:
                    () => Get.toNamed(
                      AppRoutes.verification,
                      arguments: {"verificationType": "profile"},
                    ),
              ),
              _buildSettingTile(
                title: "Education Verification",
                onTap:
                    () => Get.toNamed(
                      AppRoutes.verification,
                      arguments: {"verificationType": "school"},
                    ),
              ),
              _buildSettingTile(
                title: "Work Verification",
                onTap:
                    () => Get.toNamed(
                      AppRoutes.verification,
                      arguments: {"verificationType": "work"},
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({required String title, VoidCallback? onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 0),
            color: const Color.fromARGB(19, 0, 0, 0),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: Get.textTheme.bodyMedium!.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        trailing: CircleAvatar(
          radius: 13,
          backgroundColor: AppColors.primaryColor,
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "Verification",
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
      leadingWidth: 45,
    );
  }
}
