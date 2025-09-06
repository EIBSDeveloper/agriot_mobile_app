import 'package:intl/intl.dart';

class NotificationModel {
  final String timeStamp;
  final List<NotificationItem> notifications;

  NotificationModel({required this.timeStamp, required this.notifications});

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
      timeStamp: json['timeStamp'],
      notifications: List<NotificationItem>.from(
        json['notification'].map((x) => NotificationItem.fromJson(x)),
      ),
    );

  String get formattedDate {
    try {
      final dateTime = DateTime.parse(timeStamp);
      return DateFormat('dd MMMM yyyy').format(dateTime);
    } catch (e) {
      return timeStamp;
    }
  }
}

class NotificationItem {
  final int id;
  final String name; // notification title
  final String type; // e.g. Land, Fuel, Vendor
  final String message; // description
  final String createdAt; // ISO timestamp from API
  bool isRead;

  NotificationItem({
    required this.id,
    required this.name,
    required this.type,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
      id: json['notification_id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
      isRead: json['is_read'] ?? false,
    );

  String get formattedTime {
    try {
      final dateTime = DateTime.parse(createdAt);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return createdAt;
    }
  }
}

class NotificationCount {
  final int total;
  final int read;
  final int unread;

  NotificationCount({
    required this.total,
    required this.read,
    required this.unread,
  });

  factory NotificationCount.fromJson(Map<String, dynamic> json) => NotificationCount(
      total: json['total_notifications'] ?? 0,
      read: json['read_notifications'] ?? 0,
      unread: json['unread_notifications'] ?? 0,
    );
}
