import 'package:argiot/src/app/modules/notification/model/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  const NotificationCard({super.key, required this.notification});

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
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          color: Get.theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          notification.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(notification.type, style: const TextStyle(fontSize: 12)),
                    if (!notification.isRead)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Get.theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
