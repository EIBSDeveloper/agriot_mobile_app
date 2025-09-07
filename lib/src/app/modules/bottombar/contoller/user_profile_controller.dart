// controllers/user_profile_controller.dart
import 'package:get/get.dart';

import '../../../service/utils/utils.dart';
import '../../bottombar/model/user_profile_model.dart';

class UserProfileController extends GetxController {
  // final UserProfileRepository _repository = Get.put(UserProfileRepository());
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final RxBool isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
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
