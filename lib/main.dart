import 'package:casarancha/app/bindings/app_bindings.dart';
import 'package:casarancha/app/resources/app_text_theme.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/resources/app_translations.dart';
import 'app/routes/app_pages.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Casa Rancha',
      theme: appTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      navigatorObservers: [routeObserver],

      translations: AppTranslations(),
      locale: const Locale('en'),
      fallbackLocale: const Locale('en'),
    );
  }
}
