import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/loading.dart';
import '../../controller/employee_advance_controller.dart';
import '../../model/model.dart';
class UpdateEmployeeAdvanceView extends GetView<EmployeeAdvanceController> {
  const UpdateEmployeeAdvanceView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('update_employee_advance'.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeSelectionSection(),
            const SizedBox(height: 24),
            _buildAdvanceFormSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );

  Widget _buildEmployeeSelectionSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'employee_selection'.tr,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Employee Type Dropdown
            _buildDropdownFormField(
              label: 'employee_type'.tr,
              value: controller.selectedEmployeeType.value,
              errorText: controller.employeeTypeError.value,
              items: controller.employeeTypes,
              onChanged: controller.updateEmployeeType,
            ),
            
            // Employee Dropdown
            Obx(() => _buildEmployeeDropdown()),
          ],
        ),
      ),
    );

  Widget _buildEmployeeDropdown() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'employee'.tr,
          style: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Employee>(
          initialValue: controller.selectedEmployee.value,
          decoration: InputDecoration(
            errorText: controller.employeeError.value.isEmpty 
                ? null 
                : controller.employeeError.value,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          items: controller.employees.map((Employee employee) => DropdownMenuItem<Employee>(
              value: employee,
              child: Text(employee.displayName),
            )).toList(),
          onChanged: controller.updateEmployee,
          isExpanded: true,
        ),
        const SizedBox(height: 16),
      ],
    );

  Widget _buildAdvanceFormSection() => Obx(() {
      if (controller.selectedEmployee.value == null) {
        return const SizedBox();
      }
      
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'advance_details'.tr,
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildEmployeeInfo(),
              const SizedBox(height: 16),
              
              // Advance Amount
              _buildFormField(
                label: 'advance_amount'.tr,
                value: controller.advanceAmount.value,
                errorText: controller.advanceAmountError.value,
                keyboardType: TextInputType.number,
                onChanged: controller.updateAdvanceAmount,
              ),
              
              // Total Advance (read-only)
              _buildFormField(
                label: 'total_advance'.tr,
                value: controller.totalAdvance.toStringAsFixed(2),
                isReadOnly: true,
              ),
              
              // Description
              _buildFormField(
                label: 'description'.tr,
                value: controller.description.value,
                keyboardType: TextInputType.text,
                maxLines: 3,
                onChanged: controller.updateDescription,
              ),
            ],
          ),
        ),
      );
    });

  Widget _buildEmployeeInfo() => Obx(() {
      final data = controller.employeeData.value;
      if (data == null) {
        return const Loading();
      }
      
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'current_advance_info'.tr,
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('employee_name'.tr, data.employeeName),
            _buildInfoRow('employee_id'.tr, data.employeeId),
            _buildInfoRow('previous_advance'.tr, '₹${data.previousAdvance.toStringAsFixed(2)}'),
          ],
        ),
      );
    });

  Widget _buildInfoRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Get.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Get.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );

  Widget _buildDropdownFormField({
    required String label,
    required String value,
    required String? errorText,
    required List<String> items,
    required Function(String?) onChanged,
  }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value.isEmpty ? null : value,
          decoration: InputDecoration(
            errorText: errorText?.isEmpty ?? true ? null : errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          items: items.map((String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            )).toList(),
          onChanged: onChanged,
          isExpanded: true,
        ),
        const SizedBox(height: 16),
      ],
    );

  Widget _buildFormField({
    required String label,
    required String value,
    String? errorText,
    bool isReadOnly = false,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    int maxLines = 1,
  }) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: TextEditingController(text: value),
          readOnly: isReadOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            errorText: errorText?.isEmpty ?? true ? null : errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );

  Widget _buildActionButtons() => Obx(() => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.cancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('cancel'.tr),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.updateEmployeeAdvance,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('update_employee'.tr),
            ),
          ),
        ],
      ));
}