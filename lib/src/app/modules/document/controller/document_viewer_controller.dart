import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../service/utils/enums.dart';

class DocumentViewerController extends GetxController {
  final RxList<String> documentUrls = <String>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxList<FileTypes> fileTypes = <FileTypes>[].obs;
  final RxList<FileSourceTypes> sourceTypes = <FileSourceTypes>[].obs;
  int initialIndex = 0;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      if (args["files"] is List<String>) {
        documentUrls.assignAll(args["files"]);
      }
      if (args["index"] is int) {
        initialIndex = args["index"];
      }
    } else if (args is List<String>) {
      documentUrls.assignAll(args);
    } else if (args is String) {
      documentUrls.assignAll([args]);
    } else {
      error.value = "Invalid arguments";
      isLoading(false);
      return;
    }

    _checkDocuments();
  }

  Future<void> _checkDocuments() async {
    try {
      fileTypes.clear();
      sourceTypes.clear();

      for (final doc in documentUrls) {
        if (doc.isEmpty) {
          fileTypes.add(FileTypes.unsupported);
          sourceTypes.add(FileSourceTypes.unsupported);
          continue;
        }

        // Detect base64
        if (doc.startsWith("data:") ||
            RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(doc)) {
          sourceTypes.add(FileSourceTypes.base64);

          if (doc.contains("pdf") || doc.toLowerCase().endsWith(".pdf")) {
            fileTypes.add(FileTypes.pdf);
          } else {
            fileTypes.add(FileTypes.image);
          }
          continue;
        }

        //  Detect local file
        if (File(doc).existsSync()) {
          sourceTypes.add(FileSourceTypes.local);

          if (doc.toLowerCase().endsWith('.pdf')) {
            fileTypes.add(FileTypes.pdf);
          } else {
            fileTypes.add(FileTypes.image);
          }
          continue;
        }

        //  Otherwise treat as network
        final response = await http.head(Uri.parse(doc));
        if (response.statusCode == 200) {
          sourceTypes.add(FileSourceTypes.network);

          if (doc.toLowerCase().endsWith('.pdf')) {
            fileTypes.add(FileTypes.pdf);
          } else if (doc.toLowerCase().endsWith('.png') ||
              doc.toLowerCase().endsWith('.jpg') ||
              doc.toLowerCase().endsWith('.jpeg') ||
              doc.toLowerCase().endsWith('.gif')) {
            fileTypes.add(FileTypes.image);
          } else {
            fileTypes.add(FileTypes.unsupported);
          }
        } else {
          fileTypes.add(FileTypes.unsupported);
          sourceTypes.add(FileSourceTypes.unsupported);
        }
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading(false);
    }
  }
}
