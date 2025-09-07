import 'package:argiot/src/app/modules/sales/repostory/new_sales_repository.dart';
import 'package:argiot/src/app/modules/sales/controller/new_sales_controller.dart';
import 'package:get/get.dart';

class NewSalesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewSalesRepository>(() => NewSalesRepository());
    Get.lazyPut<NewSalesController>(() => NewSalesController());
  }
}
