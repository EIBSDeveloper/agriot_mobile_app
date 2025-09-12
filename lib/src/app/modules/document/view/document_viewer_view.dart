import 'dart:convert';
import 'dart:io';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/my_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import '../../../service/utils/enums.dart';
import '../controller/document_viewer_controller.dart' as forming;

class DocumentViewerView extends GetView<forming.DocumentViewerController> {
  const DocumentViewerView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Viewer'),
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

      // Single file
      if (controller.documentUrls.length == 1) {
        return _buildFileView(
          controller.documentUrls.first,
          controller.fileTypes.first,
          controller.sourceTypes.first,
        );
      }

      // Multiple files with initial index
      return PageView.builder(
        controller: PageController(initialPage: controller.initialIndex),
        itemCount: controller.documentUrls.length,
        itemBuilder: (context, index) => _buildFileView(
          controller.documentUrls[index],
          controller.fileTypes[index],
          controller.sourceTypes[index],
        ),
      );
    }),
  );

  Widget _buildFileView(String path, FileTypes type, FileSourceTypes source) {
    switch (type) {
      case FileTypes.pdf:
        if (source == FileSourceTypes.local) {
          return PDFView(filePath: path);
        } else if (source == FileSourceTypes.base64) {
          final bytes = base64Decode(
            path.replaceAll(RegExp(r'data:.*;base64,'), ''),
          );
          final file = File(
            "${Directory.systemTemp.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf",
          );
          file.writeAsBytesSync(bytes);
          return PDFView(filePath: file.path);
        } else {
          return PDFView(filePath: path);
        }

      case FileTypes.image:
        if (source == FileSourceTypes.local) {
          return Center(
            child: InteractiveViewer(child: Image.file(File(path))),
          );
        } else if (source == FileSourceTypes.base64) {
          final bytes = base64Decode(
            path.replaceAll(RegExp(r'data:.*;base64,'), ''),
          );
          return Center(child: InteractiveViewer(child: Image.memory(bytes)));
        } else {
          return Center(child: InteractiveViewer(child: MyNetworkImage(path)));
        }

      case FileTypes.unsupported:
        return const Center(child: Text('Unsupported file format'));
    }
  }
}
