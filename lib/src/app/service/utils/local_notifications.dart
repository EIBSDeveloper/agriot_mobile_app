import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../app.dart';

Future<void> showNotification({
  required String title,
  required String body,
  required dynamic payload,
}) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        ticker: 'ticker',
      );
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );
  var jsonEncode2 = jsonEncode(payload);
  await flutterLocalNotificationsPlugin.show(
    1,
    title,
    body,
    notificationDetails,
    payload: jsonEncode2,
  );
}
