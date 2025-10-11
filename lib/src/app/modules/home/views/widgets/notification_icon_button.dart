import 'package:argiot/src/app/modules/home/contoller/user_profile_controller.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationIconButton extends StatelessWidget {
  final UserProfileController controller = Get.put(UserProfileController());

  NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
      stream: controller.unreadStream,
      initialData: 0,
      builder: (context, snapshot) {
        final unread = snapshot.data ?? 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                Get.toNamed(Routes.notification)?.then((_) {
                  controller.resetCount(); // reset after viewing
                });
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
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
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
      },
    );
}
