import 'package:argiot/src/app/modules/auth/model/walkthrough_model.dart';
import 'package:get/get.dart';

class WalkthroughRepository {
  // Local data for now since it's static content
  List<WalkthroughModel> getLocalWalkthroughData() => [
      WalkthroughModel(
        title: 'landManagement'.tr,
        description: 'landManagementDescription'.tr,
        imagePath: 'assets/image/land_management.png',
      ),
      WalkthroughModel(
        title: 'schedule'.tr,
        description: 'scheduleDescription'.tr,
        imagePath: 'assets/image/schedule.png',
      ),
      WalkthroughModel(
        title: 'costManagement'.tr,
        description: 'costManagementDescription'.tr,
        imagePath: 'assets/image/man_power.png',
      ),
    ];
}
