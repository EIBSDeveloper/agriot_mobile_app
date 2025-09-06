import 'package:get/get.dart';

import '../controller/crop_controller.dart';
import '../controller/kyc_controller.dart';
import '../controller/land_controller.dart';
import '../controller/location_picker_controller.dart';
import '../controller/resgister_controller.dart';
import '../repostrory/crop_service.dart';
import '../repostrory/land_service.dart';

class RegistrationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationPickerController>(() => LocationPickerController());
    Get.lazyPut<ResgisterController>(() => ResgisterController());
   
    Get.lazyPut<KycController>(() => KycController());
    Get.lazyPut<LandService>(() => LandService());
    Get.lazyPut<RegLandController>(() => RegLandController());
    Get.lazyPut<CropService>(() => CropService());
    Get.lazyPut<RegCropController>(() => RegCropController());
  }
}
