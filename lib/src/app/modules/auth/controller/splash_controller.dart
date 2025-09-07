import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../../controller/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initSplash();
  }

  Future<void> _initSplash() async {
    final StorageService storageService = Get.put(StorageService());
    storageService.getLoginState();
    if (storageService.isLoggedIn) {
      storageService.updateUser();
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.home);
    } else {
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.login);
    }
  }
}
