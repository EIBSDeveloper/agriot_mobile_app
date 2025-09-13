import 'package:argiot/src/app/modules/document/model/add_document_model.dart';
import 'package:argiot/src/app/modules/document/controller/document_controller.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'document_thumbnail.dart';

class AddDocumentView extends GetView<DocumentController> {
  const AddDocumentView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Add Document'),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reason Input
            _buildReasonInput(),
            _buildDocumentUploadSection(),
            const SizedBox(height: 16),

            _buildAddButton(),
          ],
        ),
      ),
    ),
  );

  Widget _buildDocumentUploadSection() => Obx(
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InkWell(
              onTap: controller.pickFromCamera,
              child: Container(
                decoration: AppStyle.decoration,
                height: 92,
                width: 92,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Icon(
                  Icons.camera_alt,
                  color: Get.theme.primaryColor,
                  size: 50,
                ),
              ),
            ),
            InkWell(
              onTap: controller.pickFromGallery,
              child: Container(
                decoration: AppStyle.decoration,
                height: 92,
                width: 92,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),

                child: Icon(
                  Icons.photo_library,
                  color: Get.theme.primaryColor,
                  size: 50,
                ),
              ),
            ),
            ...List.generate(controller.uploadedDocs.length, (index) {
              final base64Str = controller.uploadedDocs[index];

              return InkWell(
                onTap: () {
                  Get.toNamed(
                    Routes.docViewer,
                    arguments: {
                      "files": controller.uploadedDocs,
                      "index": index,
                    },
                  );
                },
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: DocumentThumbnail(base64Str),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.removeDocument(index),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    ),
  );

  Widget _buildReasonInput() => Obx(
    () => Row(
      children: [
        if (!controller.isNewDocument.value)
          Expanded(
            child: MyDropdown(
              items: controller.docTypeList,
              selectedItem: controller.selectedDocument.value,
              onChanged: (land) {
                controller.textController.text = land!.name;
                controller.changeDocument(land);
              },
              label: 'Select Document type',
              // disable: isEditing,
            ),
          ),
        if (controller.isNewDocument.value)
          Expanded(
            child: InputCardStyle(
              child: TextFormField(
                controller: controller.textController,
                decoration: const InputDecoration(
                  labelText: 'Enter Document type',
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a document'
                    : null,
              ),
            ),
          ),
        Card(
          color: Get.theme.primaryColor,
          child: IconButton(
            color: Colors.white,
            onPressed: () {
              controller.textController.clear();
              controller.isNewDocument.value = !controller.isNewDocument.value;
            },
            icon: Icon(
              controller.isNewDocument.value ? Icons.close : Icons.add,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildAddButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        if (controller.formKey.currentState!.validate()) {
          final documents = AddDocumentModel(
            documents: controller.uploadedDocs.toList(),
            fileType: controller.selectedDocument.value.id,
            isNew: controller.isNewDocument.value,
            newFileType: controller.textController.text.isEmpty
                ? controller.selectedDocument.value.name
                : controller.textController.text,
          );

          Get.back(result: documents);
        }
      },
      child: const Text('Add Document'),
    ),
  );
}
