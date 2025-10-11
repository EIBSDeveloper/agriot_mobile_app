import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/notification/view/widgets/notification_card.dart';
import 'package:argiot/src/app/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/notification_controller.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final NotificationController controller = Get.find();

  @override
  void dispose() {
    // Mark all notifications as read when user leaves the page
    controller.markAllAsRead();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: "notifications".tr, showBackButton: true),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Loading();
      }

      if (controller.error.isNotEmpty) {
        return Center(child: Text(controller.error.value));
      }

      if (controller.notifications.isEmpty) {
        return const Center(child: Text("No notifications"));
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
                                    padding: const EdgeInsets.symmetric(
                                      // horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                  DateFormat(
                      'dd-MM-yyyy',
                    ).format(DateTime.parse(notificationGroup.timeStamp)),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                ...notificationGroup.notifications.map(
                  (notification) =>
                      NotificationCard(notification: notification),
                ),
                const Divider(),
              ],
            );
          },
        ),
      );
    }),
  );
}
