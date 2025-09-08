import 'package:argiot/src/app/modules/forming/controller/document_viewer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';

import '../../../../service/utils/enums.dart';
import '../../../../service/utils/utils.dart';
import '../../../near_me/views/widget/widgets.dart';

class DocumentViewerView extends GetView<DocumentViewerController> {
  const DocumentViewerView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Document Viewer'),
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

      switch (controller.fileType.value) {
        case FileType.pdf:
          return PDFView(
            filePath: controller.documentUrl.value,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            onError: (error) {
              showError('Failed to load PDF document');
            },
          );
        case FileType.image:
          return Center(
            child: InteractiveViewer(
              child: Image.network(
                controller.documentUrl.value,
                errorBuilder: (_, __, ___) =>
                    const Text('Failed to load image'),
              ),
            ),
          );
        case FileType.unsupported:
          return const Center(child: Text('Unsupported file format'));
      }
    }),
  );
}
