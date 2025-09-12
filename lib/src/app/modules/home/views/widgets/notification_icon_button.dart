import 'package:argiot/src/app/modules/notification/controller/notification_controller.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationIconButton extends StatelessWidget {
  final NotificationController controller = Get.put(NotificationController());

  NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    final unread = controller.unreadNotifications.value;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () {
            Get.toNamed(Routes.notification);
          },
          icon: Icon(
            Icons.notifications_none,
            color: Get.theme.colorScheme.primary,
          ),
        ),
        if (unread > 0)
          Positioned(
            right: 7,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  });
}
