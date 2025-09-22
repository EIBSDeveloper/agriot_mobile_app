import 'package:argiot/src/app/modules/expense/controller/cunsumption_details_controller.dart';
import 'package:argiot/src/app/modules/expense/repostroy/cunsumption_details_repository.dart';
import 'package:get/get.dart';

class CunsumptionDetailBinding extends Bindings {
  CunsumptionDetailBinding();

  @override
  void dependencies() {
    Get.lazyPut(() => CunsumptionDetailsRepository());
    Get.lazyPut(() => CunsumptionDetailsController());
  }
}
