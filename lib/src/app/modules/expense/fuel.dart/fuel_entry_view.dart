import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'purchases_add_controller.dart';

class FuelEntryView extends GetView<PurchasesAddController> {
  const FuelEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('fuel_entry'.tr),
        backgroundColor: Get.theme.appBarTheme.backgroundColor,
        elevation: Get.theme.appBarTheme.elevation,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FuelEntryForm(),
      ),
    );
  }
}

class FuelEntryForm extends GetView<PurchasesAddController> {
  FuelEntryForm({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date Picker
          controller.buildDateField(),
          SizedBox(height: 16),
          controller.buildInventoryCategoryDropdown(),
          SizedBox(height: 16),
          controller.buildInventoryItemDropdown(),
          const SizedBox(height: 16),

          // Vendor Dropdown
          controller.buildVendorDropdown(),
          const SizedBox(height: 16),
// Litre Field
          controller.buildLitreField(),
          const SizedBox(height: 16),
          // Purchase Amount Field
          controller.buildPurchaseAmountField(),
          const SizedBox(height: 16),
          controller.buildPaidAmountField(),
          const SizedBox(height: 16),

          

          // Document Upload (simplified)
          // _buildDocumentUpload(),
          // const SizedBox(height: 16),

          // Description Field
          controller.buildDescriptionField(),
          const SizedBox(height: 24),

          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.submitForm,
        child: controller.isLoading.value
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Get.theme.colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text('add'.tr),
      ),
    );
  }
}


// Add to your existing AppPages class


