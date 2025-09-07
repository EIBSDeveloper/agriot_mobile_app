import 'dart:convert';
import 'dart:io';

import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/modules/registration/model/dropdown_item.dart';
import 'package:argiot/src/app/modules/task/view/screens/screen.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class NewDocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddDocumentRepository>(() => AddDocumentRepository());
    Get.lazyPut<AddDocumentController>(() => AddDocumentController());
  }
}

class AddDocumentRepository {
  final HttpService _httpService = Get.find<HttpService>();

  Future<List<AppDropdownItem>> getDocumentTypes() async {
    final response = await _httpService.get('/document_categories');
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => AppDropdownItem.fromJson(item))
        .toList();
  }
}

// add mime package in pubspec.yaml

class AddDocumentController extends GetxController {
  final AddDocumentRepository _documentRepository =
      Get.find<AddDocumentRepository>();

  Rx<AddDocumentModel?> documents = Rx<AddDocumentModel?>(null);
  RxBool isNewDocument = false.obs;
  var docTypeList = <AppDropdownItem>[].obs;
  final Rx<AppDropdownItem> selectedDocument = AppDropdownItem(
    id: 0,
    name: '',
  ).obs;

  /// Store as base64 instead of files
  RxList<String> uploadedDocs = <String>[].obs;

  Future<void> fetchDocument(typeId) async {
    try {
      final response = await _documentRepository.getDocumentTypes();
      docTypeList.assignAll(response.where((doc) => typeId == doc.doctype));
      if (docTypeList.isNotEmpty) {
        selectedDocument.value = docTypeList.first;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to fetch reasons: $e');
    }
  }

  void changeDocument(AppDropdownItem type) {
    selectedDocument.value = type;
  }

  /// Convert File → Base64 string with MIME
  Future<String> _fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);

    final mimeType = lookupMimeType(file.path) ?? "application/octet-stream";
    return "data:$mimeType;base64,$base64Str";
  }

  /// Pick from gallery
  Future<void> pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    for (final f in pickedFiles) {
      uploadedDocs.add(await _fileToBase64(File(f.path)));
    }
  }

  /// Pick from camera
  Future<void> pickFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      uploadedDocs.add(await _fileToBase64(File(photo.path)));
    }
  }

  void removeDocument(int index) {
    uploadedDocs.removeAt(index);
  }
}

class AddDocumentView extends StatefulWidget {
  const AddDocumentView({super.key});

  @override
  State<AddDocumentView> createState() => _AddDocumentViewState();
}

class _AddDocumentViewState extends State<AddDocumentView> {
  final AddDocumentController controller = Get.find<AddDocumentController>();
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
                height: 92,width: 92,
                margin: const EdgeInsets.symmetric(vertical: 8,horizontal: 4),
                child: const Icon(Icons.camera_alt, color: Colors.green,size: 50,)),
            ),
            InkWell(
              onTap:  controller.pickFromGallery,
              child: Container(
                decoration: AppStyle.decoration,
                height: 92,width: 92,
             margin: const EdgeInsets.symmetric(vertical: 8,horizontal: 4),
               
                child: const Icon(Icons.photo_library, color: Colors.blue,size: 50,)),
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
          ]
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
              controller.isNewDocument.value ? Icons.close: Icons.add ,
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

class AddDocumentModel {
  AddDocumentModel({
    this.fileType,
    this.isNew = false,
    this.newFileType,
    this.documents,
  });
  final int? fileType;
  final bool isNew;
  final String? newFileType;
  final List? documents;

  Map<String, dynamic> toJson() => {
    if (!isNew) "file_type": fileType,
    if (isNew) "new_file_type": newFileType,
    "documents": documents ?? [],
  };
}
