import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../service/utils/enums.dart';

class DocumentViewerController extends GetxController {
  final RxString documentUrl = ''.obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final Rx<FileType> fileType = FileType.unsupported.obs;

  @override
  void onInit() {
    super.onInit();
    documentUrl.value = Get.arguments as String;
    _checkDocument();
  }

  Future<void> _checkDocument() async {
    try {
      if (documentUrl.value.isEmpty) {
        throw Exception('Document URL is empty');
      }

      final response = await http.head(Uri.parse(documentUrl.value));
      if (response.statusCode != 200) {
        throw Exception('Document not available');
      }

      // Determine file type by URL extension
      final lowerUrl = documentUrl.value.toLowerCase();
      if (lowerUrl.endsWith('.pdf')) {
        fileType.value = FileType.pdf;
      } else if (lowerUrl.endsWith('.png') ||
          lowerUrl.endsWith('.jpg') ||
          lowerUrl.endsWith('.jpeg') ||
          lowerUrl.endsWith('.gif')) {
        fileType.value = FileType.image;
      } else {
        fileType.value = FileType.unsupported;
        throw Exception('Unsupported file format');
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  // (Keep downloadDocument as is or enhance for other formats if needed)
}
