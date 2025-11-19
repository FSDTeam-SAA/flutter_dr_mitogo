import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LanguageSettingScreen extends StatelessWidget {
  LanguageSettingScreen({super.key});

  final List<LanguageOption> languages = [
    LanguageOption('English', 'en', 'assets/flags/usa.png'),
    LanguageOption('Español', 'es', 'assets/flags/GQ.png'),
    LanguageOption('Français', 'fr', 'assets/flags/GA.png'),
    LanguageOption('Arabic', 'ar', 'assets/flags/arabic.png'),
    LanguageOption('Português', 'pt', 'assets/flags/portuguese.png'),
  ];

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
              SizedBox(height: Get.height * 0.03),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  return _buildLanguageTile(
                    language: language,
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      // await _languageController.saveLanguage(language.code);
                      // Get.back();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required LanguageOption language,
    required VoidCallback onTap,
  }) {
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
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage(language.flag),
              fit: BoxFit.cover,
            ),
          ),
          // child: Center(
          //   child: Text(language.flag, style: const TextStyle(fontSize: 24)),
          // ),
        ),
        title: Text(
          language.name,
          style: Get.textTheme.bodyMedium!.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: Text(language.code),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "Language Settings",
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

class LanguageOption {
  final String name;
  final String code;
  final String flag;

  LanguageOption(this.name, this.code, this.flag);
}
