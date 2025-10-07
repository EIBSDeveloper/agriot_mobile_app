import 'package:argiot/src/app/modules/notification/model/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationCard extends StatelessWidget {
 final NotificationItem notification;
  const NotificationCard({
    super.key, required this.notification
  });

  @override
  Widget build(BuildContext context) => Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: notification.isRead ? Colors.grey : null,
                        ),
                      ),
                      Text(
                        notification.formattedTime,
                        style: TextStyle(
                          color: Get.theme.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.type,
                    style: TextStyle(
                      fontSize: 12,
                      color: notification.isRead ? Colors.grey : null,
                    ),
                  ),
    
                  // Text(
                  //   notification.message,
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     color: notification.isRead ? Colors.grey : null,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}
