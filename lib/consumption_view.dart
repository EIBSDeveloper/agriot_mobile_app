import 'dart:convert';
import 'package:argiot/consumption_controller.dart';
import 'package:argiot/consumption_model.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/modules/task/view/screens/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'src/app/widgets/input_card_style.dart';

class ConsumptionView extends StatelessWidget {
  final ConsumptionController _controller = Get.put(ConsumptionController());

  ConsumptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Consumption'.tr),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInventoryTypeDropdown(),
              SizedBox(height: 16),
              _buildInventoryCategoryDropdown(),
              SizedBox(height: 16),
              _buildInventoryItemDropdown(),
              SizedBox(height: 16),
              _buildDatePicker(),
              SizedBox(height: 16),
              _buildCropDropdown(),
              SizedBox(height: 16),
              _buildQuantityField(),
              SizedBox(height: 16),
              // _buildDocumentsSection(),
              // SizedBox(height: 16),
              _buildDescriptionField(),
              SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Obx(
      () => InputCardStyle(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: 'Date'.tr,
            border: InputBorder.none,
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          controller: TextEditingController(
            text: _controller.selectedDate.value.toLocal().toString().split(
              ' ',
            )[0],
          ),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: Get.context!,
              initialDate: _controller.selectedDate.value,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null && picked != _controller.selectedDate.value) {
              _controller.setSelectedDate(picked);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCropDropdown() {
    return Obx(() {
      return MyDropdown(
        items: _controller.crop,
        selectedItem: _controller.selectedCropType.value,
        onChanged: (land) => _controller.changeCrop(land!),
        label: 'crop'.tr,
        // disable: isEditing,
      );
    });
  }

  Widget _buildInventoryTypeDropdown() {
    return Obx(
      () => InputCardStyle(
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            hintText: 'Inventory Type'.tr,
            border: InputBorder.none,
          ),
          value: _controller.selectedInventoryType.value,
          items: _controller.inventoryTypes
              .map(
                (type) => DropdownMenuItem<int>(
                  value: type.id,
                  child: Text(type.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            _controller.setInventoryType(value!);
            _controller.fetchInventoryCategories(value);
          },
        ),
      ),
    );
  }

  Widget _buildInventoryCategoryDropdown() {
    return Obx(
      () => InputCardStyle(
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            hintText: 'Inventory Category'.tr,
            border: InputBorder.none,
          ),
          value: _controller.selectedInventoryCategory.value,
          items: _controller.inventoryCategories
              .map(
                (category) => DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                ),
              )
              .toList(),
          onChanged: _controller.selectedInventoryType.value != null
              ? (value) {
                  _controller.setInventoryCategory(value!);
                  _controller.fetchInventoryItems(value);
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildInventoryItemDropdown() {
    return Obx(
      () => InputCardStyle(
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            hintText: 'Inventory Item'.tr,
            border: InputBorder.none,
          ),
          value: _controller.selectedInventoryItem.value,
          items: _controller.inventoryItems
              .map(
                (item) => DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(item.name),
                ),
              )
              .toList(),
          onChanged: (value) =>
              _controller.selectedInventoryCategory.value != null
              ? _controller.setInventoryItem(value!)
              : null,
        ),
      ),
    );
  }

  Widget _buildQuantityField() {
    return InputCardStyle(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Quantity (Liter)'.tr,
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
        onChanged: _controller.setQuantity,
      ),
    );
  }

  // Widget _buildDocumentsSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Documents'.tr, style: Get.textTheme.titleLarge),
  //       SizedBox(height: 8),
  //       DocumentPickerWidget(
  //         onDocumentAdded: _controller.addDocument,
  //         onDocumentRemoved: _controller.removeDocument,
  //       ),
  //       SizedBox(height: 8),
  //       Obx(
  //         () => Column(
  //           children: _controller.documents.asMap().entries.map((entry) {
  //             final index = entry.key;
  //             final document = entry.value;
  //             return ListTile(
  //               title: Text('Document ${index + 1}'),
  //               subtitle: Text('Files: ${document.documents.length}'),
  //               trailing: IconButton(
  //                 icon: Icon(Icons.delete),
  //                 onPressed: () => _controller.removeDocument(index),
  //               ),
  //             );
  //           }).toList(),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDescriptionField() {
    return InputCardStyle(
      noHeight: true,

      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Description'.tr,
          border: InputBorder.none,
        ),
        maxLines: 3,
        onChanged: _controller.setDescription,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(
      () => ElevatedButton(
        onPressed: _controller.isLoading.value
            ? null
            : () async {
                final success = await _controller.submitConsumption();
                if (success) {
                  Get.back();
                }
              },
        style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
        child: _controller.isLoading.value
            ? CircularProgressIndicator()
            : Text('Save'.tr),
      ),
    );
  }
}

class DocumentPickerWidget extends StatefulWidget {
  final Function(Document) onDocumentAdded;
  final Function(int) onDocumentRemoved;

  const DocumentPickerWidget({
    super.key,
    required this.onDocumentAdded,
    required this.onDocumentRemoved,
  });

  @override
  _DocumentPickerWidgetState createState() => _DocumentPickerWidgetState();
}

class _DocumentPickerWidgetState extends State<DocumentPickerWidget> {
  final ConsumptionController _controller = Get.find();
  final Rx<int?> _selectedDocType = Rx<int?>(null);

  final RxString _newDocType = RxString('');
  final RxList<String> _selectedFiles = RxList<String>();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image =
            'data:image/${image.path.split('.').last};base64,${base64Encode(bytes)}';
        _selectedFiles.add(base64Image);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  void _addDocument() {
    if (_selectedFiles.isEmpty) {
      Get.snackbar('Error', 'Please select at least one file');
      return;
    }

    Document document;
    if (_selectedDocType.value != null) {
      document = Document(
        fileType: _selectedDocType.value,
        documents: _selectedFiles.toList(),
      );
    } else if (_newDocType.value.isNotEmpty) {
      document = Document(
        newFileType: _newDocType.value,
        documents: _selectedFiles.toList(),
      );
    } else {
      Get.snackbar('Error', 'Please select or enter a document type');
      return;
    }

    widget.onDocumentAdded(document);
    _resetFields();
  }

  void _resetFields() {
    _selectedDocType.value = null;
    _newDocType.value = '';
    _selectedFiles.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => InputCardStyle(
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                hintText: 'Document Category',
                border: InputBorder.none,
              ),
              value: _selectedDocType.value,
              items: _controller.documentTypes
                  .map(
                    (type) => DropdownMenuItem<int>(
                      value: type.id,
                      child: Text(type.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                _selectedDocType.value = value!;
                _newDocType.value = '';
              },
            ),
          ),
        ),

        Obx(() {
          if (_selectedDocType.value != null) {
            return SizedBox(height: 10);
          }
          return Column(
            children: [
              SizedBox(height: 10),

              InputCardStyle(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'New Document Category',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) => _newDocType.value = value,
                ),
              ),
            ],
          );
        }),
        SizedBox(height: 10),

        Obx(
          () => _selectedDocType.value != null
              ? Wrap(
                  children: [
                    // Upload button
                    Container(
                      margin: EdgeInsets.all(4),
                      height: 60,
                      width: 60,
                      color: Colors.grey.withAlpha(100),
                      child: IconButton(
                        onPressed: _pickImage,
                        icon: Icon(Icons.upload),
                      ),
                    ),

                    // Preview of selected images
                    ..._selectedFiles.map((file) {
                      try {
                        // remove base64 header part
                        final base64Str = file.split(',').last;
                        final bytes = base64Decode(base64Str);

                        return Container(
                          margin: EdgeInsets.all(4),
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.memory(bytes, fit: BoxFit.cover),
                        );
                      } catch (e) {
                        // if decoding fails, show fallback text
                        return Container(
                          margin: EdgeInsets.all(4),
                          height: 60,
                          width: 60,
                          color: Colors.grey.withAlpha(100),
                          child: Icon(Icons.insert_drive_file, size: 30),
                        );
                      }
                    }),
                  ],
                )
              : SizedBox(),
        ),

        SizedBox(height: 10),
        ElevatedButton(onPressed: _addDocument, child: Text('Document Save')),
      ],
    );
  }
}
