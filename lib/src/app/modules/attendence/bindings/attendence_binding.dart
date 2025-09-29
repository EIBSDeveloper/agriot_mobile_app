import 'package:argiot/src/app/modules/attendence/controller/attendence_controller.dart';
import 'package:get/get.dart';

class AttendenceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AttendenceController());
  }
}
