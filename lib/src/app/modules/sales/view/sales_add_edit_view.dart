// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../utils.dart';
// import '../controller/controller.dart' show SalesController;
// import '../model/model.dart';

// class SalesAddEditView extends GetView<SalesController> {
//   final bool isEdit;

//   SalesAddEditView({super.key, required this.isEdit});

//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(isEdit ? 'Edit Sale' : 'Add Sale')),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Date Picker
//               OutlinedButton(
//                 onPressed: () => controller.pickDate(context),
//                 child: Obx(
//                   () => Text(
//                     controller.selectedDate.value.isNotEmpty
//                         ? controller.selectedDate.value
//                         : 'Select Date',
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Crop Dropdown
//               DropdownButtonFormField<DropdownItem>(
//                 decoration: const InputDecoration(labelText: 'Crop'),
//                 items: controller.crops.map((crop) {
//                   return DropdownMenuItem<DropdownItem>(
//                     value: crop,
//                     child: Text(crop.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     controller.selectedCropId.value = value.id;
//                     controller.selectedCropName.value = value.name;
//                   }
//                 },
//                 validator: (value) =>
//                     value == null ? 'Please select a crop' : null,
//               ),
//               const SizedBox(height: 16),

//               // Customer Dropdown
//               DropdownButtonFormField<DropdownItem>(
//                 decoration: const InputDecoration(labelText: 'Customer'),
//                 items: controller.customers.map((customer) {
//                   return DropdownMenuItem<DropdownItem>(
//                     value: customer,
//                     child: Text(customer.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     controller.selectedCustomerId.value = value.id;
//                     controller.selectedCustomerName.value = value.name;
//                   }
//                 },
//                 validator: (value) =>
//                     value == null ? 'Please select a customer' : null,
//               ),
//               const SizedBox(height: 16),

//               // Quantity
//               TextFormField(
//                 controller: controller.quantityController,
//                 decoration: const InputDecoration(labelText: 'Quantity'),
//                 keyboardType: TextInputType.number,
//                 onChanged: (_) => controller.calculateTotalAmount(),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Please enter quantity' : null,
//               ),
//               const SizedBox(height: 16),

//               // Unit Dropdown
//               DropdownButtonFormField<DropdownItem>(
//                 decoration: const InputDecoration(labelText: 'Unit'),
//                 items: controller.units.map((unit) {
//                   return DropdownMenuItem<DropdownItem>(
//                     value: unit,
//                     child: Text(unit.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     controller.selectedUnitId.value = value.id;
//                     controller.selectedUnitName.value = value.name;
//                   }
//                 },
//                 validator: (value) =>
//                     value == null ? 'Please select a unit' : null,
//               ),
//               const SizedBox(height: 16),

//               // Amount per unit
//               TextFormField(
//                 controller: controller.amountPerUnitController,
//                 decoration: const InputDecoration(labelText: 'Amount per unit'),
//                 keyboardType: TextInputType.number,
//                 onChanged: (_) => controller.calculateTotalAmount(),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Please enter amount' : null,
//               ),
//               const SizedBox(height: 16),

//               // Total amount (readonly)
//               TextFormField(
//                 controller: controller.totalAmountController,
//                 decoration: const InputDecoration(labelText: 'Total amount'),
//                 readOnly: true,
//               ),
//               const SizedBox(height: 16),

//               // Deductions section
//               const Text(
//                 'Deductions',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Obx(
//                 () => Column(
//                   children: [
//                     ...controller.newDeductions.asMap().entries.map((entry) {
//                       final index = entry.key;
//                       final deduction = entry.value;
//                       return ListTile(
//                         title: Text(
//                           deduction['new_reason'] ??
//                               controller.reasons
//                                   .firstWhere(
//                                     (r) => r.id == deduction['reason'],
//                                     orElse: () =>
//                                         DropdownItem(id: 0, name: 'Unknown'),
//                                   )
//                                   .name,
//                         ),
//                         subtitle: Text(
//                           'Amount: ${deduction['charges']} ${deduction['rupee'] == 1 ? '₹' : '%'}',
//                         ),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () => controller.removeDeduction(index),
//                         ),
//                       );
//                     }),
//                     OutlinedButton(
//                       onPressed: () => _showAddDeductionDialog(context),
//                       child: const Text('Add Deduction'),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: controller.deductionAmountController,
//                 decoration: const InputDecoration(
//                   labelText: 'Total Deductions',
//                 ),
//                 readOnly: true,
//               ),
//               const SizedBox(height: 16),

//               // Net amount (readonly)
//               TextFormField(
//                 controller: controller.netAmountController,
//                 decoration: const InputDecoration(labelText: 'Net Amount'),
//                 readOnly: true,
//               ),
//               const SizedBox(height: 16),

//               // Paid amount
//               TextFormField(
//                 controller: controller.paidAmountController,
//                 decoration: const InputDecoration(labelText: 'Paid Amount'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Please enter paid amount' : null,
//               ),
//               const SizedBox(height: 16),

//               // Documents section
//               const Text(
//                 'Documents',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Obx(
//                 () => Column(
//                   children: [
//                     ...controller.documentFiles.map(
//                       (file) => ListTile(
//                         title: Text(file.path.split('/').last),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () =>
//                               controller.documentFiles.remove(file),
//                         ),
//                       ),
//                     ),
//                     OutlinedButton(
//                       onPressed: controller.pickDocument,
//                       child: const Text('Add Document'),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Description
//               TextFormField(
//                 controller: controller.descriptionController,
//                 decoration: const InputDecoration(labelText: 'Description'),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 24),

//               // Submit button
//               Obx(
//                 () => ElevatedButton(
//                   onPressed:
//                       controller.isAdding.value || controller.isUpdating.value
//                       ? null
//                       : () {
//                           if (_formKey.currentState?.validate() ?? false) {
//                             if (isEdit) {
//                               final salesId = Get.arguments['sales_id'];
//                               controller.updateSales(salesId);
//                             } else {
//                               controller.addSales();
//                             }
//                           }
//                         },
//                   child: Text(isEdit ? 'Update Sale' : 'Add Sale'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showAddDeductionDialog(BuildContext context) {
//     final reasonController = TextEditingController();
//     final amountController = TextEditingController();
//     final newReasonController = TextEditingController();
//     final isCustomReason = false.obs;
//     final selectedRupeeId = 1.obs;

//     Get.defaultDialog(
//       title: 'Add Deduction',
//       content: Obx(
//         () => Column(
//           children: [
//             if (!isCustomReason.value)
//               DropdownButtonFormField<DropdownItem>(
//                 decoration: const InputDecoration(labelText: 'Reason'),
//                 items: controller.reasons.map((reason) {
//                   return DropdownMenuItem<DropdownItem>(
//                     value: reason,
//                     child: Text(reason.name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     reasonController.text = value.id.toString();
//                   }
//                 },
//                 validator: (value) => value == null && !isCustomReason.value
//                     ? 'Please select a reason'
//                     : null,
//               ),
//             if (isCustomReason.value)
//               TextFormField(
//                 controller: newReasonController,
//                 decoration: const InputDecoration(labelText: 'Custom Reason'),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Please enter reason' : null,
//               ),
//             CheckboxListTile(
//               title: const Text('Custom Reason'),
//               value: isCustomReason.value,
//               onChanged: (value) => isCustomReason.value = value ?? false,
//             ),
//             TextFormField(
//               controller: amountController,
//               decoration: const InputDecoration(labelText: 'Amount'),
//               keyboardType: TextInputType.number,
//               validator: (value) =>
//                   value?.isEmpty ?? true ? 'Please enter amount' : null,
//             ),
//             DropdownButtonFormField<int>(
//               decoration: const InputDecoration(labelText: 'Type'),
//               value: selectedRupeeId.value,
//               items: controller.rupees.map((rupee) {
//                 return DropdownMenuItem<int>(
//                   value: rupee.id,
//                   child: Text(rupee.name),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   selectedRupeeId.value = value;
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//       confirm: TextButton(
//         onPressed: () {
//           if (isCustomReason.value && newReasonController.text.isEmpty) {
//             showError('Please enter custom reason');
//             return;
//           }
//           if (amountController.text.isEmpty) {
//             showError('Please enter amount');
//             return;
//           }

//           if (isCustomReason.value) {
//             controller.addDeduction(
//               newReason: newReasonController.text,
//               charges: amountController.text,
//               rupeeId: selectedRupeeId.value,
//             );
//           } else {
//             if (reasonController.text.isEmpty) {
//               showError('Please select a reason');
//               return;
//             }
//             controller.addDeduction(
//               reasonId: int.parse(reasonController.text),
//               charges: amountController.text,
//               rupeeId: selectedRupeeId.value,
//             );
//           }
//           Get.back();
//         },
//         child: const Text('Add'),
//       ),
//       cancel: TextButton(onPressed: Get.back, child: const Text('Cancel')),
//     );
//   }
// }
