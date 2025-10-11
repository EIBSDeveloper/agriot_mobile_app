import 'package:get/get.dart';

import '../Repository/notification_repository.dart';
import '../model/notification_model.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    fetchNotifications();
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

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _repository.readll();
  }
}
