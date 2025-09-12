import 'package:argiot/src/app/modules/document/controller/document_viewer_controller.dart' as forming;
import 'package:get/get.dart';

class DocumentViewerBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<forming.DocumentViewerController>(
      () => forming.DocumentViewerController(),
    );
  }
}