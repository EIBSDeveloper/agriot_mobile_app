import 'package:argiot/src/app/modules/document/controller/document_controller.dart';
import 'package:argiot/src/app/modules/document/repository/document_repository.dart';
import 'package:get/get.dart';

class DocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentRepository>(() => DocumentRepository());
    Get.lazyPut<DocumentController>(() => DocumentController());
  }
}
