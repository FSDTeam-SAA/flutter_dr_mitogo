import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkVerificationScreen extends StatelessWidget {
  const WorkVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height * 0.03),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "First name",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Color(0xFF312A2A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        CustomTextField(
                          hintText: "Enter school name",
                          bgColor: Color(0xFFF7F7F9),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "School Name",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Color(0xFF312A2A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        CustomTextField(
                          hintText: "Enter school name",
                          bgColor: Color(0xFFF7F7F9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: Get.height * 0.02),
              Text(
                "Company Name",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Color(0xFF312A2A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              CustomTextField(
                hintText: "ABC Company",
                bgColor: Color(0xFFF7F7F9),
              ),
              SizedBox(height: Get.height * 0.02),
              Text(
                "Position",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Color(0xFF312A2A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              CustomTextField(
                hintText: "Manager",
                bgColor: Color(0xFFF7F7F9),
              ),
              SizedBox(height: Get.height * 0.02),
              Text(
                "Government ID",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Color(0xFF312A2A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              CustomTextField(
                hintText: "e.g; 00000-00000000-00",
                bgColor: Color(0xFFF7F7F9),
              ),
              SizedBox(height: Get.height * 0.02),
              Text(
                "Password",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Color(0xFF312A2A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              CustomTextField(
                hintText: "Enter Password",
                bgColor: Color(0xFFF7F7F9),
              ),

              SizedBox(height: Get.height * 0.02),
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
              SizedBox(height: Get.height * 0.02),
              CustomButton(
                ontap: () {},
                isLoading: false.obs,
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
        "Work Verification",
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
