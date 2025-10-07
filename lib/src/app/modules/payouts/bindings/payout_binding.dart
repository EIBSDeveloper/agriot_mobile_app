import 'package:argiot/src/app/modules/payouts/controller/payout_controller.dart';
import 'package:argiot/src/app/modules/payouts/repository/payout_repository.dart';
import 'package:get/get.dart';

class PayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PayoutRepository());
    Get.lazyPut(() => PayoutController());
  }
}
