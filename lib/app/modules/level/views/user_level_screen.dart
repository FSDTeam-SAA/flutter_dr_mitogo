
import 'package:casarancha/app/modules/level/widgets/build_level_info_card.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserLevelScreen extends StatelessWidget {
  UserLevelScreen({super.key});


  final dailyList = [
    {
      "title": "Get 30% more engagement",
      "value": "7 Posts Daily",
      "progress": 0.6,
      "buttonText": "Claim Reward",
    },
    {
      "title": "Get 50% more engagement",
      "value": "10 Friends Daily",
      "progress": 0.4,
      "buttonText": "Invite Friends",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height * 0.03),
              BuildLevelInformaion(),
              SizedBox(height: Get.height * 0.03),
              // Text(
              //   "Daily Challenges",
              //   style: Get.textTheme.bodyLarge!.copyWith(
              //     fontSize: 18,
              //     fontWeight: FontWeight.w800,
              //     color: Colors.black87,
              //   ),
              // ),
              // const SizedBox(height: 16),
              // GridView.builder(
              //   itemCount: dailyList.length,
              //   shrinkWrap: true,
              //   physics: NeverScrollableScrollPhysics(),
              //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //     crossAxisCount: 2,
              //     crossAxisSpacing: 2,
              //     mainAxisSpacing: 5,
              //     childAspectRatio: 1,
              //   ),
              //   itemBuilder: (context, index) {
              //     final item = dailyList[index];
              //     final title = item["title"].toString();
              //     final value = item["value"].toString();
              //     final progress = item["progress"] as double;
              //     final buttonText = item["buttonText"].toString();
              //     return buildEachDailyChallengeCard(
              //       title: title,
              //       value: value,
              //       progress: progress,
              //       buttonText: buttonText,
              //     );
              //   },
              // ),

              SizedBox(height: Get.height * 0.03),
              CustomButton(
                ontap: () => Get.toNamed(AppRoutes.levelDetails),
                isLoading: false.obs,
                borderRadius: BorderRadius.circular(8),
                child: Text(
                  "View Details",
                  style: Get.textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEachDailyChallengeCard({
    required String title,
    required String value,
    required double progress,
    required String buttonText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 0),
            color: const Color.fromARGB(12, 0, 0, 0),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.orange.withOpacity(0.2),
            ),
            child: Text(
              title,
              style: Get.textTheme.bodyMedium!.copyWith(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Get.textTheme.bodyMedium!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  color: AppColors.primaryColor,
                  minHeight: 13,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "3/7",
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 30,
            child: CustomButton(
              ontap: () {},
              isLoading: false.obs,
              borderRadius: BorderRadius.circular(8),
              bgColor: Colors.transparent,
              border: Border.all(width: 1, color: AppColors.primaryColor),
              child: Text(
                buttonText,
                style: Get.textTheme.bodyMedium!.copyWith(
                  color: AppColors.primaryColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "Your Level",
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
