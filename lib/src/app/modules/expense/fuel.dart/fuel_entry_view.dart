import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'purchases_add_controller.dart';

class FuelEntryView extends GetView<PurchasesAddController> {
  const FuelEntryView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'fuel_entry'.tr),
    body: const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: FuelEntryForm(),
    ),
  );
}

class FuelEntryForm extends GetView<PurchasesAddController> {
  const FuelEntryForm({super.key});

  @override
  Widget build(BuildContext context) => Form(
    key: controller.formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date Picker
        controller.buildDateField(),
        const SizedBox(height: 16),
        controller.buildInventoryCategoryDropdown(),
        const SizedBox(height: 16),
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

        controller.buildDocumentsSection(),
        const SizedBox(height: 24),

        controller.buildDescriptionField(),
        const SizedBox(height: 24),

        // Submit Button
        _buildSubmitButton(),
      ],
    ),
  );

  Widget _buildSubmitButton() => Obx(
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


// Add to your existing AppPages class


