import 'package:argiot/src/app/modules/document/model/add_document_model.dart';
import 'package:argiot/src/app/modules/document/view/screen/document_thumbnail.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentItemWidget extends StatelessWidget {
  const DocumentItemWidget({
    super.key,
    required this.index,
    required this.document,
    required this.onDelete,
  });

  final int index;
  final AddDocumentModel document;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text("${index + 1}, ${document.newFileType ?? ''}"),
      Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                Get.toNamed(Routes.docViewer, arguments: document.documents);
              },
              child: DocumentThumbnail(document.documents!.first),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(
              child: IconButton(
                onPressed: onDelete,
                color: Get.theme.primaryColor,
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
