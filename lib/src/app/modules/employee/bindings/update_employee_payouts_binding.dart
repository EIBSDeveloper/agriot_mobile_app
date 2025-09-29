import 'package:argiot/src/app/modules/employee/controller/update_employee_payouts_controller.dart';
import 'package:get/get.dart';

class UpdateEmployeePayoutsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateEmployeePayoutsController>(
      () => UpdateEmployeePayoutsController(),
    );
  }
}