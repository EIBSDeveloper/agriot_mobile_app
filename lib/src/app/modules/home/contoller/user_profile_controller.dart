// controllers/user_profile_controller.dart
import 'dart:async';

import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:get/get.dart';

import '../../../controller/app_controller.dart';
import '../../notification/Repository/notification_repository.dart';
import '../model/user_profile_model.dart';

class UserProfileController extends GetxController {
  final NotificationRepository _repository = Get.put(NotificationRepository());
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isShowProfile = false.obs;

  final AppDataController appData = Get.find();

  // StreamController for unread count
  final StreamController<int> _unreadController =
      StreamController<int>.broadcast();
  Stream<int> get unreadStream => _unreadController.stream;

  Timer? _pollingTimer;
  int _unreadCount = 0;

  @override
  void onInit() {
    super.onInit();
    isShowProfile.value = !appData.isManager.value;
    fetchUserProfile();
    startUnreadCountStream();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    _unreadController.close();
    super.onClose();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      // final response = await _repository.getUserProfile();
      // userProfile.value = response.userProfile;
    } catch (e) {
      showError('Failed to load user profile');
    } finally {
      isLoading.value = false;
    }
  }

  // Continuously fetch unread count and push to stream
  void startUnreadCountStream() {
    // Cancel any existing timer before starting
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _fetchUnreadCountFromApi();
    });

    // Also do one immediate fetch
    _fetchUnreadCountFromApi();
  }

  Future<void> _fetchUnreadCountFromApi() async {
    try {
      final count = await _repository.getNotificationCount();
      final newCount = count.unread;

      // Only push to stream if changed (avoid unnecessary rebuilds)
      if (newCount != _unreadCount) {
        _unreadCount = newCount;
        _unreadController.add(_unreadCount);
      }
    } catch (e) {
      _unreadController.add(0);
    }
  }


  void incrementCount() {
    _unreadCount++;
    _unreadController.add(_unreadCount);
  }


  void resetCount() {
    _unreadCount = 0;
    _unreadController.add(_unreadCount);
  }
}
