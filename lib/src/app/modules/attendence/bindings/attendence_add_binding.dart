import 'package:argiot/src/app/modules/attendence/controller/attendence_add_controller.dart';
import 'package:argiot/src/app/modules/attendence/repository/attendence_repository.dart';
import 'package:get/get.dart';

class AttendenceAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AttendanceRepository());
    Get.lazyPut(() => AttendenceAddController());
  }
}
