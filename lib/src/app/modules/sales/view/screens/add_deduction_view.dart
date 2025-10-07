import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/sales/controller/new_sales_controller.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddDeductionView extends StatelessWidget {
  final NewSalesController controller = Get.find<NewSalesController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _chargesController = TextEditingController();
  final RxString _selectedType = '1'.obs; // 1 for Rupee, 2 for Percentage

  AddDeductionView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'add_deduction'.tr),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reason Input
            _buildReasonInput(),
            const SizedBox(height: 16),

            // Charges Input
            _buildChargesInput(),
            const SizedBox(height: 16),

            // Add Button
            _buildAddButton(),
          ],
        ),
      ),
    ),
  );

  Widget _buildReasonInput() => Obx(
    () => Row(
      children: [
        if (!controller.isNewReason.value)
          Expanded(
            child: MyDropdown(
              items: controller.reasonsList,
              selectedItem: controller.selectedReason.value,
              onChanged: (land) => controller.changeResion(land!),
              label: 'reason'.tr,
              // disable: isEditing,
            ),
          ),
        if (controller.isNewReason.value)
          Expanded(
            child: InputCardStyle(
              child: TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'reason_for_deduction'.tr,
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'please_enter_a_reason'.tr
                    : null,
              ),
            ),
          ),
        Card(
          color: Get.theme.primaryColor,
          child: IconButton(
            onPressed: () {
              controller.isNewReason.value = !controller.isNewReason.value;
            },
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    ),
  );

  Widget _buildChargesInput() => Row(
    children: [
      Expanded(
        child: InputCardStyle(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextFormField(
            controller: _chargesController,
            decoration: InputDecoration(
              labelText: 'deduction_amount'.tr,
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'please_enter_deduction_amount'.tr;
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'deduction_must_be_greater_than_0'.tr;
              }
              if (_selectedType.value == '2' && amount > 100) {
                return 'percentage_cannot_exceed_100'.tr;
              }
              return null;
            },
          ),
        ),
      ),
      const SizedBox(width: 10),
      SizedBox(width: 100, child: _buildTypeSelector()),
    ],
  );

  Widget _buildTypeSelector() => Obx(
    () => InputCardStyle(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedType.value,
        onChanged: (String? newValue) {
          _selectedType.value = newValue!;
        },

        items: const [
          DropdownMenuItem(
            value: '1',
            child: Row(children: [Icon(Icons.currency_rupee, size: 18)]),
          ),
          DropdownMenuItem(
            value: '2',
            child: Row(children: [Icon(Icons.percent, size: 18)]),
          ),
        ],
        decoration: InputDecoration(
          hintText: 'discount_type'.tr,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        isExpanded: true,
      ),
    ),
  );

  Widget _buildAddButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          final deduction = {
            if (!controller.isNewReason.value)
              'reason': controller.selectedReason.value.id,
            if (!controller.isNewReason.value)
              'reason_name': controller.selectedReason.value.name,
            if (controller.isNewReason.value)
              'new_reason': _reasonController.text,
            'charges': _chargesController.text,
            'rupee': _selectedType.value,
          };

          controller.addDeduction(deduction);
          Get.back();
        }
      },
      child: Text('add_deduction'.tr),
    ),
  );
}
