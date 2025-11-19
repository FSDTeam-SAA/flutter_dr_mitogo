
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganizationVerificationScreen extends StatelessWidget {
  const OrganizationVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height * 0.03),
              Text(
                "Organization",
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Color(0xFF312A2A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: Get.height * 0.01),
              CustomTextField(
                bgColor: Color(0xffF7F7F9),
                hintText: "Organization name",
              ),
              SizedBox(height: Get.height * 0.03),

              InkWell(
                onTap: () {
                  // Get.toNamed(AppRoutes.createPoll);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.image,
                        size: 45,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Text(
                            "Browse images or drop here",
                            style: Get.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "JPG, PNG , file size no more than 25MB",
                            style: Get.textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "NOTE: Selfie picture is not required, but it's exponentially increases your changes to get verified quickly",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.normal,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(
                ontap: () {},
                isLoading: false.obs,
                borderRadius: BorderRadius.circular(15),
                child: Text(
                  "Submit",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
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
        "Organization verification",
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
