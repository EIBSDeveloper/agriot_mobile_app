import 'package:argiot/src/app/modules/expense/view/widgets/date_picker_field.dart';
import 'package:argiot/src/app/modules/expense/controller/purchases_add_controller.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/input_card_style.dart';

class MachineryEntryScreen extends GetView<PurchasesAddController> {
  const MachineryEntryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'title'.tr),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.buildDateField(),
            const SizedBox(height: 16),
            controller.buildInventoryCategoryDropdown(),
            const SizedBox(height: 16),
            controller.buildInventoryItemDropdown(),
            const SizedBox(height: 16),

            // Vendor Dropdown
            controller.buildVendorDropdown(),
            const SizedBox(height: 16),

            _buildMachineryTypeRadio(),
            const SizedBox(height: 16),
            Obx(
              () => controller.machineryType.value == "Fuel"
                  ? _buildFuelCapacityField()
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16), controller.buildPaidAmountField(),
            const SizedBox(height: 16),
            controller.buildPurchaseAmountField(),
            const SizedBox(height: 16),
            _buildWarrantyStartDateField(),
            const SizedBox(height: 16),
            _buildWarrantyEndDateField(),
            const SizedBox(height: 16),

            controller.buildDocumentsSection(),
            const SizedBox(height: 24),
            // Description Field
            controller.buildDescriptionField(),

            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    ),
  );

  Widget _buildMachineryTypeRadio() => Obx(
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('type'.tr, style: Get.textTheme.bodyLarge),
        Row(
          children: [
            Radio<String>(
              value: 'Fuel',
              groupValue: controller.machineryType.value,
              onChanged: (value) => controller.machineryType.value = value!,
            ),
            Text('fuel'.tr),
            Radio<String>(
              value: 'Manual',
              groupValue: controller.machineryType.value,
              onChanged: (value) => controller.machineryType.value = value!,
            ),
            Text('manual'.tr),
          ],
        ),
      ],
    ),
  );

  Widget _buildFuelCapacityField() => InputCardStyle(
    child: TextFormField(
      controller: controller.fuelCapacityController,
      decoration: InputDecoration(
        hintText: "${'fuel_capacity'.tr} *",
        border: InputBorder.none,
      ),
      validator: (value) => value!.isEmpty ? 'required_field'.tr : null,
      keyboardType: TextInputType.number,
    ),
  );

  Widget _buildWarrantyStartDateField() => DatePickerField(
    controller: controller.warrantyStartDateController,
    labelText: "${'warranty_start'.tr} ",
    onChanged: (vlu) {},
  );

  Widget _buildWarrantyEndDateField() => DatePickerField(
    controller: controller.warrantyEndDateController,
    onChanged: (vlu) {},
    labelText: "${'warranty_end'.tr}  ",
    validator: (value) {
      if (value.isNotEmpty &&
          controller.warrantyStartDateController.text.isNotEmpty) {
        final start = DateTime.parse(
          controller.warrantyStartDateController.text,
        );
        final end = DateTime.parse(value);
        if (end.isBefore(start)) return 'warranty_end_after_start'.tr;
      }
      return null;
    },
  );

  Widget _buildSubmitButton() => Obx(
    () => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : controller.submitMachineryForm,
        child: controller.isLoading.value
            ? const CircularProgressIndicator()
            : Text('add_button'.tr),
      ),
    ),
  );
}
