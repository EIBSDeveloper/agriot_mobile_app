// import 'dart:convert';
// import 'package:argiot/consumption_controller.dart';
// import 'package:argiot/consumption_model.dart';
// import 'package:argiot/src/app/widgets/input_card_style.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// class DocumentPickerWidget extends StatefulWidget {
//   final Function(Document) onDocumentAdded;
//   final Function(int) onDocumentRemoved;

//   const DocumentPickerWidget({
//     super.key,
//     required this.onDocumentAdded,
//     required this.onDocumentRemoved,
//   });

//   @override
//   _DocumentPickerWidgetState createState() => _DocumentPickerWidgetState();
// }

// class _DocumentPickerWidgetState extends State<DocumentPickerWidget> {
//   final ConsumptionController _controller = Get.find();
//   final Rx<int?> _selectedDocType = Rx<int?>(null);

//   final RxString _newDocType = RxString('');
//   final RxList<String> _selectedFiles = RxList<String>();

//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> _pickImage() async {
//     try {
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//       if (image != null) {
//         final bytes = await image.readAsBytes();
//         final base64Image =
//             'data:image/${image.path.split('.').last};base64,${base64Encode(bytes)}';
//         _selectedFiles.add(base64Image);
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to pick image');
//     }
//   }

//   void _addDocument() {
//     if (_selectedFiles.isEmpty) {
//       Get.snackbar('Error', 'Please select at least one file');
//       return;
//     }

//     Document document;
//     if (_selectedDocType.value != null) {
//       document = Document(
//         fileType: _selectedDocType.value,
//         documents: _selectedFiles.toList(),
//       );
//     } else if (_newDocType.value.isNotEmpty) {
//       document = Document(
//         newFileType: _newDocType.value,
//         documents: _selectedFiles.toList(),
//       );
//     } else {
//       Get.snackbar('Error', 'Please select or enter a document type');
//       return;
//     }

//     widget.onDocumentAdded(document);
//     _resetFields();
//   }

//   void _resetFields() {
//     _selectedDocType.value = null;
//     _newDocType.value = '';
//     _selectedFiles.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Obx(
//           () => InputCardStyle(
//             child: DropdownButtonFormField<int>(
//               decoration: InputDecoration(
//                 hintText: 'Document Category',
//                 border: InputBorder.none,
//               ),
//               value: _selectedDocType.value,
//               items: _controller.documentTypes
//                   .map(
//                     (type) => DropdownMenuItem<int>(
//                       value: type.id,
//                       child: Text(type.name),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 _selectedDocType.value = value!;
//                 _newDocType.value = '';
//               },
//             ),
//           ),
//         ),

//         Obx(() {
//           if (_selectedDocType.value != null) {
//             return SizedBox(height: 10);
//           }
//           return Column(
//             children: [
//               SizedBox(height: 10),

//               InputCardStyle(
//                 child: TextFormField(
//                   decoration: InputDecoration(
//                     hintText: 'New Document Category',
//                     border: InputBorder.none,
//                   ),
//                   onChanged: (value) => _newDocType.value = value,
//                 ),
//               ),
//             ],
//           );
//         }),
//         SizedBox(height: 10),

//         Obx(
//           () => _selectedDocType.value != null
//               ? Wrap(
//                   children: [
//                     // Upload button
//                     Container(
//                       margin: EdgeInsets.all(4),
//                       height: 60,
//                       width: 60,
//                       color: Colors.grey.withAlpha(100),
//                       child: IconButton(
//                         onPressed: _pickImage,
//                         icon: Icon(Icons.upload),
//                       ),
//                     ),

//                     // Preview of selected images
//                     ..._selectedFiles.map((file) {
//                       try {
//                         // remove base64 header part
//                         final base64Str = file.split(',').last;
//                         final bytes = base64Decode(base64Str);

//                         return Container(
//                           margin: EdgeInsets.all(4),
//                           height: 60,
//                           width: 60,
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.black26),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Image.memory(bytes, fit: BoxFit.cover),
//                         );
//                       } catch (e) {
//                         // if decoding fails, show fallback text
//                         return Container(
//                           margin: EdgeInsets.all(4),
//                           height: 60,
//                           width: 60,
//                           color: Colors.grey.withAlpha(100),
//                           child: Icon(Icons.insert_drive_file, size: 30),
//                         );
//                       }
//                     }),
//                   ],
//                 )
//               : SizedBox(),
//         ),

//         SizedBox(height: 10),
//         ElevatedButton(onPressed: _addDocument, child: Text('Document Save')),
//       ],
//     );
//   }
// }
