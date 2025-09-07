import 'package:argiot/src/app/modules/map_view/controller/land_map_view_controller.dart';
import 'package:argiot/src/app/modules/map_view/repository/land_map_view_repository.dart';
import 'package:get/get.dart';

class LandMapViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LandMapViewRepository());
    Get.lazyPut(() => LandMapViewController());
  }
}
