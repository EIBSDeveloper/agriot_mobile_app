import 'dart:io';

import 'package:argiot/src/app/bindings/app_binding.dart';
import 'package:argiot/src/core/app_theme.dart';
import 'package:argiot/src/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

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

    await requestNotificationPermission();
  }

  Future<void> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
      await Permission.storage.request();
      var status = await Permission.location.request();
      if (status.isGranted) {
        print("Location permission granted");
      } else if (status.isDenied) {
        print("Location permission denied");
      } else if (status.isPermanentlyDenied) {
        openAppSettings(); // take user to settings
      }
    } else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
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
