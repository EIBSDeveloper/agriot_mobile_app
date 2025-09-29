import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/update_employee_payouts_controller.dart';

class UpdateEmployeePayoutsView
    extends GetView<UpdateEmployeePayoutsController> {
  const UpdateEmployeePayoutsView({super.key});

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.updateDate(picked.toIso8601String().split('T')[0]);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'update_employee_payouts'.tr),
    body: Obx(() {
      if (controller.isLoading.value && controller.employeeData.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.employeeData.value == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.errorMessage.value),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.loadEmployeeData,
                child: Text('retry'.tr),
              ),
            ],
          ),
        );
      }

      return _buildContent(context);
    }),
  );

  Widget _buildContent(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEmployeeInfo(),
        const SizedBox(height: 24),
        _buildPayoutsForm(context),
        const SizedBox(height: 32),
        _buildActionButtons(),
      ],
    ),
  );

  Widget _buildEmployeeInfo() => Obx(() {
    var _ = controller.employeeData.value;
    // if (data == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'employee_info'.tr,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Role Dropdown
          InputCardStyle(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonFormField<String>(
              // initialValue: controller.selectedRole.value,
              items: ['Manager', 'Employee']
                  .map(
                    (String role) => DropdownMenuItem<String>(
                      value: role,
                      child: Text(role.tr),
                    ),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  // controller.updateRoleFilter(newValue);
                }
              },
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              decoration: InputDecoration(
                labelText: 'employee_type'.tr,
                border: InputBorder.none,
              ),
            ),
          ), // Role Dropdown
          const SizedBox(height: 16),
          InputCardStyle(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonFormField<String>(
              // initialValue: controller.selectedRole.value,
              items: ['2', '1']
                  .map(
                    (String role) => DropdownMenuItem<String>(
                      value: role,
                      child: Text(role.tr),
                    ),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  // controller.updateRoleFilter(newValue);
                }
              },
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              decoration: InputDecoration(
                labelText: 'work_type'.tr,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          InputCardStyle(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonFormField<String>(
              // initialValue: controller.selectedRole.value,
              items: ['Ravi', 'Bala']
                  .map(
                    (String role) => DropdownMenuItem<String>(
                      value: role,
                      child: Text(role.tr),
                    ),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  // controller.updateRoleFilter(newValue);
                }
              },
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              decoration: InputDecoration(
                labelText: 'employee'.tr,
                border: InputBorder.none,
              ),
            ),
          ),

          // _buildInfoRow('employee_name'.tr, data?.employeeName??""),
          // _buildInfoRow('employee_id'.tr, data?.employeeId?),
          // _buildInfoRow('employee_type'.tr, data?.employeeType?),
          // _buildInfoRow('work_type'.tr, data?.workType?),
        ],
      ),
    );
  });

  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(flex: 3, child: Text(value, style: Get.textTheme.bodyMedium)),
      ],
    ),
  );

  Widget _buildPayoutsForm(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'PayoutType'.tr,
        style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      InputCardStyle(
        child: DropdownButtonFormField<String>(
          initialValue: controller.payoutType.value,
          items: ['Advance', 'Salary']
              .map(
                (String role) =>
                    DropdownMenuItem<String>(value: role, child: Text(role.tr)),
              )
              .toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.payoutType(newValue);
            }
          },
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            labelText: 'work_type'.tr,
            border: InputBorder.none,
          ),
        ),
      ),
      const SizedBox(height: 16),
      // Date of Payouts
      PayoutsFormField(
        label: 'date_of_payouts'.tr,
        value: controller.dateOfPayouts.value,
        errorText: controller.dateError.value,
        isReadOnly: true,
        onTap: () => _selectDate(context),
      ),

      _buildInfoRow(
        'advance_amount'.tr,
        '₹${controller.employeeData.value?.advanceAmount ?? ""}',
      ),
      const SizedBox(height: 16),
      // Deduction of Advance Amount
      PayoutsFormField(
        label: 'deduction_advance_amount'.tr,
        value: controller.deductionAdvanceAmount.value,
        errorText: controller.deductionError.value,
        keyboardType: TextInputType.number,
        onChanged: controller.updateDeductionAmount,
      ),

      _buildInfoRow(
        'balance_advance'.tr,
        '₹${controller.employeeData.value?.balanceAdvance ?? ""}',
      ),
      const SizedBox(height: 16),
      // Payouts Amount
      PayoutsFormField(
        label: 'payouts_amount'.tr,
        value: controller.payoutsAmount.value,
        errorText: controller.payoutsError.value,
        keyboardType: TextInputType.number,
        onChanged: controller.updatePayoutsAmount,
      ),

      // To Pay
      PayoutsFormField(
        label: 'to_pay'.tr,
        value: controller.toPay.value,
        errorText: controller.toPayError.value,
        keyboardType: TextInputType.number,
        onChanged: controller.updateToPay,
      ),

      // Description
      PayoutsFormField(
        label: 'description'.tr,
        value: controller.description.value,
        keyboardType: TextInputType.text,
        maxLines: 3,
        onChanged: controller.updateDescription,
      ),
    ],
  );

  Widget _buildActionButtons() => Obx(
    () => Row(
      children: [
        // Expanded(
        //   child: OutlinedButton(
        //     onPressed: controller.cancel,
        //     style: OutlinedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //     ),
        //     child: Text('cancel'.tr),
        //   ),
        // ),
        // const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.updatePayouts,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('update_payouts'.tr),
          ),
        ),
      ],
    ),
  );
}

// Move the PayoutsFormField widget to the same file
class PayoutsFormField extends StatelessWidget {
  final String label;
  final String? value;
  final String? errorText;
  final bool isReadOnly;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final int? maxLines;

  const PayoutsFormField({
    super.key,
    required this.label,
    this.value,
    this.errorText,
    this.isReadOnly = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),
      InputCardStyle(
        padding: const EdgeInsets.all(0),
        child: TextFormField(
          controller: TextEditingController(text: value),
          readOnly: isReadOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            errorText: errorText?.isEmpty ?? true ? null : errorText,
            border: InputBorder.none,
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
          onTap: onTap,
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}
