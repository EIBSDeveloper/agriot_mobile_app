import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../utils.dart';

class DocumentViewerController extends GetxController {
  final RxString documentUrl = ''.obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

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
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  Future<void> downloadDocument() async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) return;

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      final response = await http.get(Uri.parse(documentUrl.value));
      await file.writeAsBytes(response.bodyBytes);

      showSuccess('Document downloaded ');
    } catch (e) {
      showError('Failed to download document');
    }
  }
}
