import 'package:argiot/src/app/modules/forming/view/screen/document_viewer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';

import '../../../../../utils.dart';

class DocumentViewerView extends GetView<DocumentViewerController> {
  const DocumentViewerView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Document Viewer'),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.download),
          //   onPressed: controller.downloadDocument,
          // ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.error.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }
        
        return PDFView(
          filePath: controller.documentUrl.value,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          onError: (error) {
           showError(
              'Failed to load document',
            );
          },
        );
      }),
    );
}