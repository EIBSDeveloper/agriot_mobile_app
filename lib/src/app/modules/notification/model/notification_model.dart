import 'package:argiot/src/app/modules/notification/model/notification_item.dart';
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
