import 'package:argiot/src/app/modules/expense/fuel.dart/consumption_purchase_controller.dart';
import 'package:argiot/src/app/modules/expense/fuel.dart/consumption_purchase_repository.dart';
import 'package:argiot/src/app/modules/expense/fuel.dart/purchases_add_repository.dart';
import 'package:get/get.dart';

class ConsumptionPurchaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsumptionPurchaseRepository>(
      () => ConsumptionPurchaseRepository(),
    );
    Get.lazyPut<PurchasesAddRepository>(() => PurchasesAddRepository());
    Get.lazyPut<ConsumptionPurchaseController>(
      () => ConsumptionPurchaseController(),
    );
  }
}
