import 'package:argiot/src/app/modules/expense/controller/fuel_inventory_controller.dart';
import 'package:argiot/src/app/modules/expense/repostroy/fuel_inventory_repository.dart';
import 'package:get/get.dart';

class FuelInventoryBinding extends Bindings {
  FuelInventoryBinding();

  @override
  void dependencies() {
    Get.lazyPut(() => FuelInventoryRepository());
    Get.lazyPut(() => FuelInventoryController());
  }
}
