import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/notification/view/widget/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: CustomAppBar(
        title: "notifications".tr, // Localized
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notificationGroup = controller.notifications[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      DateFormat(
                        'dd MMMM yyyy',
                      ).format(DateTime.parse(notificationGroup.timeStamp)),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ...notificationGroup.notifications.map((notification) => _buildNotificationCard(notification)),
                ],
              );
            },
          ),
        );
      }),
    );



  Widget _buildNotificationCard(NotificationItem notification) => Card(
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
