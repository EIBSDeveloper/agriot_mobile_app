import 'package:argiot/src/app/bindings/app_binding.dart';
import 'package:argiot/src/core/app_theme.dart';
import 'package:argiot/src/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'app/controller/app_permission.dart';
import 'app/controller/localization/app_translations.dart';
import 'app/routes/app_routes.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final InitializationSettings initializationSettings =
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          // Handle navigation if needed
        }
      },
    );

    await AppPermission.requestNotificationPermission();
  }

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    title: 'ARGIOT App',
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    translations: AppTranslations(),
    locale: Get.deviceLocale,
    fallbackLocale: const Locale('en', 'US'),
    initialBinding: AppBinding(),

    initialRoute: Routes.splash,
    getPages: AppPages.routes,
    debugShowCheckedModeBanner: false,
  );
}
