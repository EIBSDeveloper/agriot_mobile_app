// notification_controller.dart
import 'package:get/get.dart';

import '../notification_model.dart';
import '../repository/notification_repository.dart';

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
}
