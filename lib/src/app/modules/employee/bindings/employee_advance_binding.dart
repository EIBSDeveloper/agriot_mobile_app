import 'package:argiot/src/app/modules/employee/controller/employee_advance_controller.dart';
import 'package:get/get.dart';

import '../../manager/controller/manager_controller.dart';

class EmployeeAdvanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeAdvanceController>(
      () => EmployeeAdvanceController(),
    );
  }
}
class EmployeeAdd extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagerController>(
      () => ManagerController(),
    );
  }
}