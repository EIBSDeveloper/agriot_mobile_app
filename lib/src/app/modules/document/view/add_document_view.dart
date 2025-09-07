import 'dart:convert';

import 'package:argiot/src/app/modules/document/model/add_document_model.dart';
import 'package:argiot/src/app/modules/document/controller/document_controller.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddDocumentView extends StatefulWidget {
  const AddDocumentView({super.key});

  @override
  State<AddDocumentView> createState() => _AddDocumentViewState();
}

class _AddDocumentViewState extends State<AddDocumentView> {
  final DocumentController controller = Get.find<DocumentController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  @override
  void initState() {
    final int typeId = Get.arguments['id'];

    controller.fetchDocument(typeId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Add Document'),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reason Input
            _buildReasonInput(),
            _buildDocumentUploadSection(),
            const SizedBox(height: 16),
            // Add Button
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
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.green,
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

                child: const Icon(
                  Icons.photo_library,
                  color: Colors.blue,
                  size: 50,
                ),
              ),
            ),
            ...List.generate(controller.uploadedDocs.length, (index) {
              final base64Str = controller.uploadedDocs[index];

              final isImage = base64Str.startsWith("data:image");
              final bytes = isImage
                  ? base64Decode(base64Str.split(",").last)
                  : null;

              return Stack(
                alignment: Alignment.topRight,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isImage
                          ? Image.memory(
                              bytes!,
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 92,
                              height: 92,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.picture_as_pdf,
                                size: 40,
                                color: Colors.red,
                              ),
                            ),
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
                _textController.text = land!.name;
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
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Enter Document type',
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
              _textController.clear();
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
        if (_formKey.currentState!.validate()) {
          final documents = AddDocumentModel(
            documents: controller.uploadedDocs.toList(),
            fileType: controller.selectedDocument.value.id,
            isNew: controller.isNewDocument.value,
            newFileType: _textController.text.isEmpty
                ? controller.selectedDocument.value.name
                : _textController.text,
          );

          Get.back(result: documents);
        }
      },
      child: const Text('Add Document'),
    ),
  );
}
