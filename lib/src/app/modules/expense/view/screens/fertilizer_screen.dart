import 'package:argiot/src/app/modules/expense/controller/purchases_add_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../service/utils/utils.dart';
import '../../../near_me/views/widget/widgets.dart';

class FertilizerScreen extends GetView<PurchasesAddController> {
  const FertilizerScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title:
          "${capitalizeFirstLetter(getType(Get.arguments['id']))} ${'add'.tr}",
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Field
            controller.buildDateField(),
            const SizedBox(height: 16),

            controller.buildInventoryCategoryDropdown(),
            const SizedBox(height: 16),
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
              ],
            ),
            const SizedBox(height: 16),
            controller.buildPaidAmountField(),
            const SizedBox(height: 16),

            // Purchase Amount Field
            controller.buildPurchaseAmountField(),
            const SizedBox(height: 16),

            controller.buildDocumentsSection(),
            const SizedBox(height: 24),
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
    ),
  );
}
