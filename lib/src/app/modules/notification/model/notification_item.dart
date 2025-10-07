import 'package:intl/intl.dart';

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
