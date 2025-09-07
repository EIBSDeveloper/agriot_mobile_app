
import 'package:get/get.dart';

import '../controller/purchases_add_controller.dart';

class FuelEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PurchasesAddController>(() => PurchasesAddController());
  }
}
