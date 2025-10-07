import 'package:argiot/src/app/modules/manager/controller/manager_controller.dart';
import 'package:get/get.dart';

import '../../employee/repository/employee_details_repository.dart';
import '../repository/manager_repository.dart';
class ManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ManagerRepository());
    Get.lazyPut(() => ManagerController());
    Get.lazyPut(() => EmployeeDetailsRepository());
  }
}
