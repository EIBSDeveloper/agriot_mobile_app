import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../controller/notification_controller.dart';
import '../../notification_model.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Notifications",showBackButton:true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }
        
        if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        }
        
        return RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notificationGroup = controller.notifications[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      DateFormat('dd MMMM yyyy').format(
                        DateTime.parse(notificationGroup.timeStamp)),
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ...notificationGroup.notifications.map((notification) {
                    return _buildNotificationCard(notification);
                  }),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(12),
      // ),
       color: Colors.grey.withAlpha(30), //rgb(226,237,201)
              elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
            SizedBox(height: 8),
            Text(
              notification.description,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}