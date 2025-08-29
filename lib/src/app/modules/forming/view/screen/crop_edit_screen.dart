
///
// // lib/modules/crop/views/crop_edit_screen.dart
// class CropEditScreen extends StatefulWidget {
// const  CropEditScreen({super.key});

//   @override
//   State<CropEditScreen> createState() => _CropEditScreenState();
// }

// class _CropEditScreenState extends State<CropEditScreen> {
//   final CropDetailsController controller = Get.find();

//   final _formKey = GlobalKey<FormState>();

//   final _plantationDateController = TextEditingController();


//   final int landId = Get.arguments['landId'];

//   final int cropId = Get.arguments['cropId'];

//   @override
//   void initState() {
//     super.initState();
//     if (controller.details.value == null) {
//       controller.fetchCropDetails(landId, cropId);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: 'Edit Crop Details',showBackButton: true,),
//       body: Obx(() {
//         if (controller.isDetailsLoading.value &&
//             controller.details.value == null) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (controller.details.value == null ||
//             controller.details.value!.crops.isEmpty) {
//           return Center(child: Text('No crop data available'));
//         }

//         final crop = controller.details.value!.crops.firstWhere(
//           (c) => c.id == cropId,
//           orElse: () => controller.details.value!.crops.first,
//         );

//         _plantationDateController.text = crop.plantationDate;

//         return SingleChildScrollView(
//           padding: EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 // Crop Name Dropdown
//                 // _buildDropdownFormField(
//                 //   label: 'Crop Name',
//                 //   value: crop.crop.id,
//                 //   items: ['Coffee', 'Tea', 'Tomato', 'Potato'],
//                 // ),
//                 // SizedBox(height: 16),
//                 // Crop Type Dropdown
//                 // _buildDropdownFormField(
//                 //   label: 'Crop Type',
//                 //   value: crop.cropType.name,
//                 //   items: ['Commercial Crops', 'Vegetables', 'Fruits'],
//                 // ),
//                 // SizedBox(height: 16),
//                 // // Harvest Frequency Dropdown
//                 // _buildDropdownFormField(
//                 //   label: 'Harvest Frequency',
//                 //   value: crop.harvestingType.name,
//                 //   items: ['Daily', 'Weekly', 'Monthly', 'Yearly'],
//                 // ),
//                 SizedBox(height: 16),
//                 // Plantation Date
//                 TextFormField(
//                   controller: _plantationDateController,
//                   decoration: InputDecoration(
//                     labelText: 'Plantation Date',
//                     suffixIcon: Icon(Icons.calendar_today),
//                     border: OutlineInputBorder(),
//                   ),
//                   readOnly: true,
//                   onTap: () async {
//                     final date = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.parse(crop.plantationDate),
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                     );
//                     if (date != null) {
//                       _plantationDateController.text = date
//                           .toLocal()
//                           .toString()
//                           .split(' ')[0];
//                     }
//                   },
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select plantation date';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 // Measurement
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 3,
//                       child: TextFormField(
//                         initialValue: crop.measurementValue.toString(),
//                         decoration: InputDecoration(
//                           labelText: 'Measurement',
//                           border: OutlineInputBorder(),
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter measurement';
//                           }
//                           if (double.tryParse(value) == null) {
//                             return 'Please enter a valid number';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     Expanded(
//                       flex: 2,
//                       child: _buildDropdownFormField(
//                         label: 'Unit',
//                         value: crop.measurementUnit.name,
//                         items: ['Hectare', 'Acre', 'Sqft'],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 // Survey Details
//                 ExpansionTile(
//                   title: Text('Survey Details'),
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Column(
//                         children: controller.details.value!.land.surveyDetails
//                             .map(
//                               (survey) => CheckboxListTile(
//                                 title: Text(
//                                   '${survey.surveyNo} - ${survey.measurementValue} ${survey.measurementUnit}',
//                                 ),
//                                 value: true,
//                                 onChanged: (bool? value) {},
//                               ),
//                             )
//                             .toList(),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 // Description
//                 TextFormField(
//                   initialValue: crop.description,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(),
//                   ),
//                   maxLines: 3,
//                 ),
//                 SizedBox(height: 20),
//                 // Update Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         controller.updateCrop({
//                           'crop_id': crop.id,
//                           'crop_type': crop.cropType.id,
//                           'crop': crop.crop.id,
//                           'harvesting_type': crop.harvestingType.id,
//                           'plantation_date': _plantationDateController.text,
//                           'land': landId,
//                           'measurement_value': crop.measurementValue,
//                           'measurement_unit': crop.measurementUnit.id,
//                           'survey_details': controller
//                               .details
//                               .value!
//                               .land
//                               .surveyDetails
//                               .map((s) => s.id)
//                               .toList(),
//                           'status': 0,
//                           'description': crop.description,
//                           'geo_marks': crop.geoMarks,
//                         });
//                       }
//                     },
//                     child: Text('Update'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildDropdownFormField({
//     required String label,
//     required String value,
//     required List<String> items,
//   }) {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(),
//       ),
//       value: value,
//       items: items.map((String item) {
//         return DropdownMenuItem<String>(value: item, child: Text(item));
//       }).toList(),
//       onChanged: (String? newValue) {
//         // Handle dropdown change
//       },
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please select $label';
//         }
//         return null;
//       },
//     );
//   }
// }

