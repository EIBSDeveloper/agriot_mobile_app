import 'dart:convert';

import 'package:argiot/src/app/modules/notification/view/widget/notification_count.dart';
import 'package:argiot/src/app/modules/notification/view/widget/notification_item.dart';
import 'package:get/get.dart';

import '../../../controller/app_controller.dart';
import '../../../service/http/http_service.dart';
import '../notification_model.dart';

class NotificationRepository {
  final HttpService _httpService = Get.find();
  final AppDataController _appDataController = Get.find();

  Future<List<NotificationModel>> getNotifications() async {
    final userId = _appDataController.userId;
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

  Future<NotificationItem?> getNotificationById(int notificationId) async {
    final userId = _appDataController.userId;

    try {
      final response = await _httpService.get(
        '/farmer_notifications_get/$userId/$notificationId',
      );

      print('Notification response: ${response.body}');

      final Map<String, dynamic> jsonMap = json.decode(response.body);

      // If API returns a single notification object
      if (jsonMap.isNotEmpty) {
        return NotificationItem.fromJson(jsonMap);
      }

      return null;
    } catch (e) {
      print('Error fetching notification: $e');
      throw Exception('Failed to load notification: ${e.toString()}');
    }
  }

  Future<NotificationCount> getNotificationCount() async {
    final userId = _appDataController.userId;
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
  Future<bool> markAsRead(int notificationId) async {
    final userId = _appDataController.userId;

    try {
      final response = await _httpService.post(
        '/farmer_notification_update/$userId/$notificationId',
        {}, // empty body if API doesn't require
      );

      final Map<String, dynamic> jsonMap = json.decode(response.body);

      // Assuming API returns {"success": true} or similar
      return jsonMap['success'] ?? true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
}
