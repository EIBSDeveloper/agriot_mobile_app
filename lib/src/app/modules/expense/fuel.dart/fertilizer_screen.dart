import 'package:argiot/src/app/modules/expense/fuel.dart/purchases_add_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FertilizerScreen extends GetView<PurchasesAddController> {
  const FertilizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('fertilizer_entry_title'.tr),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Field
            controller.buildDateField(),
            const SizedBox(height: 16),

            controller.buildInventoryCategoryDropdown(),
            SizedBox(height: 16),
            controller.buildInventoryItemDropdown(),
            const SizedBox(height: 16),

            // Vendor Dropdown
            controller.buildVendorDropdown(),
            const SizedBox(height: 16),
            // Vendor Field

            // Quantity Field
            Row(
              children: [
                Expanded(flex: 2, child: controller.buildLitreField()),
                const SizedBox(width: 8),
                // Expanded(
                //   flex: 1,
                //   child: Obx(
                //     () => DropdownButtonFormField<String>(
                //       value: controller.selectedUnit.value,
                //       items: ['Kilo', 'Gram', 'Ton']
                //           .map(
                //             (unit) => DropdownMenuItem(
                //               value: unit,
                //               child: Text(unit),
                //             ),
                //           )
                //           .toList(),
                //       onChanged: (value) {
                //         if (value != null) {
                //           controller.setUnit(value);
                //         }
                //       },
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 16),
            controller.buildPaidAmountField(),
            const SizedBox(height: 16),

            // Purchase Amount Field
            controller.buildPurchaseAmountField(),
            const SizedBox(height: 16),

            controller.buildDescriptionField(),

            const SizedBox(height: 24),

            // Submit Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: !controller.isLoading.value
                      ? controller.submitFertilizerForm
                      : null,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : Text('add_button'.tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
