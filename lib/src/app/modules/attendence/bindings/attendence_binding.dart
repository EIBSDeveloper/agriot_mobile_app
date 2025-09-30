import 'package:argiot/src/app/modules/attendence/controller/attendence_controller.dart';
import 'package:argiot/src/app/modules/attendence/repository/attendence_repository.dart';
import 'package:get/get.dart';

class AttendenceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AttendanceRepository());
    Get.lazyPut(() => AttendenceController());
  }
}
