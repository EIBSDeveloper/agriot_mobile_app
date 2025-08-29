import 'dart:io';

import 'package:argiot/src/app/bindings/app_binding.dart';
import 'package:argiot/src/core/theme.dart';
import 'package:argiot/src/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app/controller/localization/crop_en_us.dart';
import 'routes/app_routes.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final InitializationSettings initializationSettings = InitializationSettings(
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

    await _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
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
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ARGIOT App',
      theme: FashionStoreTheme.lightTheme,
      darkTheme: FashionStoreTheme.darkTheme,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      initialBinding: AppBinding(),
      // home: SignInDemo(),
      initialRoute: Routes.home,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
