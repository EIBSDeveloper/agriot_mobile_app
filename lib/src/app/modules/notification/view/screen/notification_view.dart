import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/notification/view/widget/notification_item.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
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
          return const CircularProgressIndicator();
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



  Widget _buildNotificationCard(NotificationItem notification) => InkWell(
      onTap: () {
        if (notification.isRead) {
          showSuccess( "this_notification_is_already_read".tr,
          
          );
          return;
        }

        controller.fetchNotificationById(notification.id).then((_) {
          final notif = controller.selectedNotification.value;
          if (notif != null) {
            Get.dialog(
              Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: Get.theme.primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              notif.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.mark_as_unread),
                            onPressed: () async {
                              await controller.markNotificationAsRead(notif);
                              Get.back(); // Close dialog immediately
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${"type".tr}: ${notif.type}', // Localized
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 12),
                      Text(notif.message, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          notif.formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
      },
      child: Card(
        // margin: const EdgeInsets.only(bottom: 10),
        color: notification.isRead ? Colors.grey.withAlpha(50) : Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      notification.isRead
                          ? Colors.grey.withAlpha(50)
                          : Get.theme.primaryColor.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications,
                  color:
                      notification.isRead
                          ? Colors.grey
                          : Get.theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
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
      ),
    );
}
