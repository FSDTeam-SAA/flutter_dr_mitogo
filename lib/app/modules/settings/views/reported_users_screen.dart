import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportedUsersScreen extends StatelessWidget {
  const ReportedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        width: Get.width,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          child: StaggeredColumnAnimation(
            children: [
              SizedBox(height: Get.height * 0.02),
              ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildReportedTile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportedTile() {
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
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage("assets/images/jao.jpg"),
        ),
        title: Text(
          "John Doe",
          style: Get.textTheme.bodyMedium!.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
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
        "Reported Users",
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
