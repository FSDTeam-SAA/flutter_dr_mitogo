import 'package:get/get.dart';
import 'package:casarancha/app/controller/storage_controller.dart';
import 'package:flutter/material.dart';

class LocalizationController extends GetxController {
  final StorageController _storageController = Get.find();

  final Rx<String> currentLanguage = 'en'.obs;
  final Rx<Locale> locale = const Locale('en').obs;

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'ar': 'العربية',
    'pt': 'Português',
  };

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final savedLanguage = await _storageController.getAppLanguage();
      if (savedLanguage != null &&
          supportedLanguages.containsKey(savedLanguage)) {
        currentLanguage.value = savedLanguage;
        locale.value = Locale(savedLanguage);
        Get.updateLocale(Locale(savedLanguage));
      }
    } catch (e) {
      print('Error loading language: $e');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) return;

    try {
      await _storageController.saveAppLanguage(languageCode);

      currentLanguage.value = languageCode;
      locale.value = Locale(languageCode);
      Get.updateLocale(Locale(languageCode));
    } catch (e) {
      print('Error changing language: $e');
    }
  }

  String get getCurrentLanguageCode => currentLanguage.value;
  String get getCurrentLanguageName =>
      supportedLanguages[currentLanguage.value] ?? 'English';
  Map<String, String> get getSupportedLanguages => supportedLanguages;
}
