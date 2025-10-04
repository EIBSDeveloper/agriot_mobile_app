// controllers/user_profile_controller.dart
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:get/get.dart';

import '../../../controller/app_controller.dart';
import '../model/user_profile_model.dart';

class UserProfileController extends GetxController {
  // final UserProfileRepository _repository = Get.put(UserProfileRepository());
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isshowProfile = false.obs;
  
final AppDataController appData = AppDataController();
  @override
  void onInit() {
    super.onInit();
    isshowProfile.value = !appData.isManager.value;
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      // final response = await _repository.getUserProfile();
      // userProfile.value = response.userProfile;
    } catch (e) {
    showError( 'Failed to load user profile');
    } finally {
      isLoading.value = false;
    }
  }
}
