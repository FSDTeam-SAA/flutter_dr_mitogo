import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LevelDetailsScreen extends StatelessWidget {
  const LevelDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        width: Get.width,
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              _buildLevelDetails(),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelDetails() {
    final height = Get.height;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            color: const Color.fromARGB(43, 0, 0, 0),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Writing posts only",
                      style: Get.textTheme.bodyMedium!.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text("✅ You can:"),
                    Text("• Write anonymous posts (text only)"),
                    Text("• Share secrets, thoughts, and emotions"),
                    SizedBox(height: 15),
                    Text("🚫 You can’t add photos, videos, or music yet"),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 32,
            left: 13.5,
            child: _buildLine(height: height * 0.202, color: Colors.red.shade200),
          ),

          //stepper-22222222222222222222222222222222222222222222222222
          Container(
            margin: EdgeInsets.only(top: height * 0.2425),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Writing and Photos",
                        style: Get.textTheme.bodyMedium!.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("✅ You can:"),
                      Text("• Post text + add photos"),
                      Text("• Express yourself visually"),
                      Text("📝 How to unlock:"),
                      Text("• Be active for 7 days"),
                      Text("• OR make 90 posts"),
                      Text("• OR invite 60 friends"),
                      SizedBox(height: 15),
                      Text("🚫 You can’t add videos, or music yet"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: height * 0.2838,
            left: 13.5,
            child: _buildLine(height: 210, color: Colors.red.shade200),
          ),

          //stepper-333333333333333333333333333333333333333333333333333
          Container(
            margin: EdgeInsets.only(top: height * 0.549),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Writing, Photos, and Videos",
                        style: Get.textTheme.bodyMedium!.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("✅ You can:"),
                      Text("• Share confessions with videos"),
                      Text("• Add photos and write text too"),
                      Text("📝 How to unlock:"),
                      Text("• Invite 150 friends"),
                      Text("• OR make 440 posts"),
                      SizedBox(height: 15),
                      Text("🚫 You can’t add music yet"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 461,
            left: 13.5,
            child: _buildLine(height: height * 0.256, color: Colors.red.shade200),
          ),

          //stepper-44444444444444444444444444444444444444444444444444
          Container(
            margin: EdgeInsets.only(top: height * 0.804),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Writing, Photos, Videos & Music",
                        style: Get.textTheme.bodyMedium!.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("✅ You can:"),
                      Text("• Add music to your posts"),
                      Text(
                        "• Create full emotional storytelling with audio + visuals",
                      ),
                      Text("📝 How to unlock:"),
                      Text("• Invite 550 friends"),
                      Text("• OR make 2,300 posts"),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine({required double height, required Color color}) {
    return Container(width: 5, height: height, color: color);
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "Levels Details",
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
