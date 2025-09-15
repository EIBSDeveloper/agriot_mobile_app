
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../../../service/utils/enums.dart';
import '../../model/add_document_model.dart';
import 'document_item_widget.dart';
class DocumentsSection extends StatelessWidget {
  const 
  DocumentsSection({super.key, required this.documentItems,required this.type});

  final RxList<AddDocumentModel> documentItems;
  final DocTypes type;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildHeader(),
      Obx(() {
        if (documentItems.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'no_documents_added'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: documentItems
              .asMap()
              .entries
              .map(
                (entry) => DocumentItemWidget(
                  key: ValueKey(entry.key),
                  index: entry.key,
                  document: entry.value,
                  onDelete: () => documentItems.removeAt(entry.key),
                ),
              )
              .toList(),
        );
      }),
    ],
  );

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'documents'.tr,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Card(
        color: Get.theme.primaryColor,
        child: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.add),
          onPressed: () {
            Get.toNamed(
              Routes.addDocument,
              arguments: {"type": type},
            )?.then((result) {
              if (result != null && result is AddDocumentModel) {
                documentItems.add(result);
              }
              print(documentItems.toString());
            });
          },
          tooltip: 'add_document'.tr,
        ),
      ),
    ],
  );
}