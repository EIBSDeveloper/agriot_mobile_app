import 'package:argiot/src/app/modules/guideline/controller/guideline_controller.dart';
import 'package:get/get.dart';

class GuidelineBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GuidelineController>(GuidelineController.new, fenix: true);
  }
}
