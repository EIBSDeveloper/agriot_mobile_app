import 'dart:convert';
import 'dart:io';
import 'package:argiot/src/app/modules/document/model/add_document_model.dart';
import 'package:argiot/src/app/modules/document/repository/document_repository.dart';
import 'package:argiot/src/app/modules/registration/model/dropdown_item.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../../service/utils/enums.dart';

class DocumentController extends GetxController {
  final DocumentRepository repository = Get.find<DocumentRepository>();

  Rx<AddDocumentModel?> documents = Rx<AddDocumentModel?>(null);
  RxBool isNewDocument = false.obs;
  var docTypeList = <AppDropdownItem>[].obs;

  RxList<String> uploadedDocs = <String>[].obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();
  final Rx<AppDropdownItem> selectedDocument = AppDropdownItem(
    id: 0,
    name: '',
  ).obs;


  Future<void> fetchDocument(DocTypes typeId) async {
    try {
      final response = await repository.getDocumentTypes();
      docTypeList.assignAll(response.where((doc) => typeId == doc.doctype));
      if (docTypeList.isNotEmpty) {
        selectedDocument.value = docTypeList.first;
      }
    } catch (e) {
      showError('Failed to fetch reasons: $e');
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
