import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/notification/view/widgets/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/loading.dart';
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
        return const Loading();
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
                ...notificationGroup.notifications.map(
                  (notification) => NotificationCard(notification:notification),
                ),
              ],
            );
          },
        ),
      );
    }),
  );


}
