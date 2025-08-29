// widgets/notification_item.dart
import 'package:flutter/material.dart';

import '../../../../../constants/theme.dart';
import '../../notification_model.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationItem notification;

  const NotificationItemWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  notification.title,
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  notification.formattedTime,
                  // style: AppTextStyles.,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(notification.description, style: AppTextStyles.bodyText1),
          ],
        ),
      ),
    );
  }
}
