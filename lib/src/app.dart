import 'package:argiot/src/app/bindings/app_binding.dart';
import 'package:argiot/src/core/app_theme.dart';
import 'package:argiot/src/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

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
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (canPop, result) async {
      if (Get.currentRoute == Routes.home) {
        final shouldExit =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Exit App"),
                content: const Text("Do you really want to exit?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("No"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Yes"),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldExit) {
          // Exit the app
          return;
        } else {
          // Cancel pop
          // You can use 'Get' to re-navigate or just do nothing
          return;
        }
      }
    },
    child: GetMaterialApp(
      title: 'ARGIOT App',
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      initialBinding: AppBinding(),
      initialRoute: Routes.splash,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}
