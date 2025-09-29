import 'package:argiot/src/app/bindings/app_binding.dart';
import 'package:argiot/src/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'app/controller/localization/app_translations.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    title: 'ARGIOT App',
    theme: AppTheme.lightTheme,
    // darkTheme: AppTheme.darkTheme,
    translations: AppTranslations(),
    locale: Get.deviceLocale,
    fallbackLocale: const Locale('en', 'US'),
    initialBinding: AppBinding(),
    // home: ChatPage(),
    initialRoute: Routes.home,
    getPages: AppPages.routes,
    debugShowCheckedModeBanner: false,
  );
}
