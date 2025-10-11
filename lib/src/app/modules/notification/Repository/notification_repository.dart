import 'dart:convert';

import 'package:argiot/src/app/modules/notification/model/notification_count.dart';
import 'package:argiot/src/app/modules/notification/model/notification_item.dart';
import 'package:get/get.dart';

import '../../../controller/app_controller.dart';
import '../../../service/http/http_service.dart';
import '../model/notification_model.dart';

class NotificationRepository {
  final HttpService _httpService = Get.find();
  final AppDataController _appDataController = Get.find();

  Future<List<NotificationModel>> getNotifications() async {
    final userId = _appDataController.farmerId;
    try {
      final response = await _httpService.get(
        '/farmer_notifications_all/$userId',
      );

      final Map<String, dynamic> jsonMap = json.decode(response.body);
      final List<dynamic> notificationsJson = jsonMap['notifications'] ?? [];

      // Convert to NotificationItem
      final List<NotificationItem> allNotifications = notificationsJson
          .map((item) => NotificationItem.fromJson(item))
          .toList();

      // Group by date
      Map<String, List<NotificationItem>> grouped = {};
      for (var notif in allNotifications) {
        final dateKey = notif.createdAt.split('T')[0]; // YYYY-MM-DD
        if (!grouped.containsKey(dateKey)) grouped[dateKey] = [];
        grouped[dateKey]!.add(notif);
      }

      // Convert to NotificationModel list
      final List<NotificationModel> notificationModels = grouped.entries
          .map(
            (entry) => NotificationModel(
              timeStamp: entry.key,
              notifications: entry.value,
            ),
          )
          .toList();

      // Sort by date descending
      notificationModels.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

      return notificationModels;
    } catch (e) {
      print('Error loading notifications: $e');
      throw Exception('Failed to load notifications: ${e.toString()}');
    }
  }

  Future<NotificationCount> getNotificationCount() async {
    final userId = _appDataController.farmerId;
    try {
      final response = await _httpService.get(
        '/farmer_notifications_count/$userId',
      );

      final Map<String, dynamic> jsonMap = json.decode(response.body);

      return NotificationCount.fromJson(jsonMap);
    } catch (e) {
      print('Error fetching notification count: $e');
      return NotificationCount(total: 0, read: 0, unread: 0);
    }
  }

  // Mark notification as read
  Future readll() async {
    final userId = _appDataController.farmerId;

    try {
      await _httpService.post(
        '/notification_read_all/$userId',
        {}, // empty body if API doesn't require
      );
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
}
