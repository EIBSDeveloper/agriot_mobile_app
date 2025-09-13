
import 'package:get/get.dart';

import '../controller/document_controller.dart';
import '../repository/document_repository.dart';

class DocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentRepository>(() => DocumentRepository());
    Get.lazyPut<DocumentController>(() => DocumentController());
  }
}
