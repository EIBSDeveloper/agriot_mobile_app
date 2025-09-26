import 'package:argiot/src/app/modules/employee/controller/employee_controller.dart';
import 'package:get/get.dart';

class EmployeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmployeeController());
  }
}
