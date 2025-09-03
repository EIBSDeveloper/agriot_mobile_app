import 'package:get/get.dart';

import '../Repository/notification_repository.dart';
import '../notification_model.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    fetchNotifications();
    fetchTotalCount();
    super.onInit();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      error('');
      final result = await _repository.getNotifications();
      notifications.assignAll(result);
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }

  // For single notification
  final Rx<NotificationItem?> selectedNotification = Rx<NotificationItem?>(
    null,
  );

  /// Fetch single notification by ID
  Future<void> fetchNotificationById(int notificationId) async {
    try {
      isLoading(true);
      error('');
      final notif = await _repository.getNotificationById(notificationId);
      if (notif != null) {
        selectedNotification.value = notif;
        print('Fetched notification: ${notif.name}');
      } else {
        print('No notification found with ID $notificationId');
      }
    } catch (e) {
      error('Failed to fetch notification: $e');
      print(e);
    } finally {
      isLoading(false);
    }
  }

  final RxInt unread_notifications = 0.obs;

  Future<void> fetchTotalCount() async {
    try {
      final count = await _repository.getNotificationCount();
      unread_notifications.value = count.unread; // only total_notifications
    } catch (e) {
      unread_notifications.value = 0;
    }
  }

  // Mark single notification as read and update UI
  Future<void> markNotificationAsRead(NotificationItem notification) async {
    final success = await _repository.markAsRead(notification.id);
    if (success) {
      // Find index in the list
      final index = notifications.indexWhere(
        (model) =>
            model.notifications.any((item) => item.id == notification.id),
      );

      if (index != -1) {
        // Find the notification inside grouped notifications
        final notifIndex = notifications[index].notifications.indexWhere(
          (item) => item.id == notification.id,
        );

        if (notifIndex != -1) {
          notifications[index].notifications[notifIndex].isRead = true;
          notifications.refresh(); // trigger UI update
        }
      }

      fetchTotalCount(); // update unread count
    }
  }
}
