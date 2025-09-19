import 'package:argiot/src/app/modules/expense/controller/purchase_details_controller.dart';
import 'package:argiot/src/app/modules/expense/repostroy/purchase_details_repository.dart';
import 'package:get/get.dart';

class FuelInventoryBinding extends Bindings {
  FuelInventoryBinding();

  @override
  void dependencies() {
    Get.lazyPut(() => InventoryDetailsRepository());
    Get.lazyPut(() => InventoryDetailsController());
  }
}
