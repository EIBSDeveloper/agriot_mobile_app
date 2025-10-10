import 'package:argiot/src/app/modules/payouts/controller/payout_add_controller.dart';
import 'package:argiot/src/app/modules/payouts/repository/payout_repository.dart';
import 'package:get/get.dart';

class PayoutAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PayoutRepository());
    Get.lazyPut(() => PayoutAddController());
  }
}
