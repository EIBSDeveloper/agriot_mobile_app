import 'package:argiot/src/app/modules/employee/controller/employee_advance_controller.dart';
import 'package:get/get.dart';

class EmployeeAdvanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeAdvanceController>(
      () => EmployeeAdvanceController(),
    );
  }
}