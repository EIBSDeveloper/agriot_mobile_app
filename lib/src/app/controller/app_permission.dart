import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app.dart';

class AppPermission extends GetxController {
 
static  Future<void> requestNotificationPermission() async {
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

}
