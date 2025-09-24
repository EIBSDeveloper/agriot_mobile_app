import 'package:argiot/src/app/modules/employee/controller/employee_manager_list_controller.dart';
import 'package:argiot/src/app/modules/employee/repository/employee_manager_repository.dart';

import 'package:get/get.dart';

import '../controller/employee_details_controller.dart';
import '../repository/employee_details_repository.dart';

class EmployeeManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeManagerRepository>(() => EmployeeManagerRepository());
    Get.lazyPut<EmployeeManagerListController>(
      () => EmployeeManagerListController(),
    );
  }
}
class EmployeeDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeDetailsRepository>(() => EmployeeDetailsRepository());
    Get.lazyPut<EmployeeDetailsController>(() => EmployeeDetailsController());
  }
}