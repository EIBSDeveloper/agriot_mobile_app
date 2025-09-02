
import 'package:get/get.dart';

import 'purchases_add_controller.dart';

class FuelEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PurchasesAddController>(() => PurchasesAddController());
  }
}
