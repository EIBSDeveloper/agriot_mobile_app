import 'package:intl/intl.dart';

class NotificationModel {
  final String timeStamp;
  final List<NotificationItem> notifications;

  NotificationModel({
    required this.timeStamp,
    required this.notifications,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      timeStamp: json['timeStamp'],
      notifications: List<NotificationItem>.from(
        json['notification'].map((x) => NotificationItem.fromJson(x)),
      ),
    );
  }

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
  final String title;
  final String description;
  final String timeStamp;

  NotificationItem({
    required this.title,
    required this.description,
    required this.timeStamp,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      title: json['title'],
      description: json['description'],
      timeStamp: json['timeStamp'],
    );
  }

  String get formattedTime {
    try {
      final dateTime = DateTime.parse(timeStamp);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return timeStamp;
    }
  }
}