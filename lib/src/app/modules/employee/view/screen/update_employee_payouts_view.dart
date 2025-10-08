import 'package:argiot/src/app/modules/employee/view/widget/payouts_form_field.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/loading.dart';
import '../../../manager/model/dropdown_model.dart';
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
        return const Loading();
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
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText('employee_info'.tr),
          const SizedBox(height: 16),
          // Role Dropdown
          Obx(
            () => InputCardStyle(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonFormField<DrapDown>(
                initialValue: controller.selectedEmployeeType.value,
                items: controller.employeeTypes
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (value) =>
                    controller.selectedEmployeeType.value = value,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: const InputDecoration(
                  labelText: 'Employee Type *',
                  border: InputBorder.none,
                ),
                validator: (value) => value == null ? 'Required field' : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Work Type
          Obx(
            () => InputCardStyle(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonFormField<DrapDown>(
                initialValue: controller.selectedWorkType.value,
                items: controller.workTypes
                    .map(
                      (e) => DropdownMenuItem<DrapDown>(
                        value: e,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.selectedWorkType.value = value;
                  controller.getEmployee();
                },
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: const InputDecoration(
                  labelText: 'Work Type *',
                  border: InputBorder.none,
                ),
                validator: (value) => value == null ? 'Required field' : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Work Type
          Obx(
            () => InputCardStyle(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonFormField<DrapDown>(
                initialValue: controller.selectedEmoployee.value,
                items: controller.employee
                    .map(
                      (e) => DropdownMenuItem<DrapDown>(
                        value: e,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.selectedEmoployee.value = value;
                  controller.loadEmployeeData();
                },
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: const InputDecoration(
                  labelText: 'Employee *',
                  border: InputBorder.none,
                ),
                validator: (value) => value == null ? 'Required field' : null,
              ),
            ),
          ),
        ],
      ),
    );
  });

  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 10),
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
      TitleText('PayoutType'.tr),
      const SizedBox(height: 16),
      InputCardStyle(
        child: DropdownButtonFormField<DrapDown>(
          initialValue: controller.payoutType.value,
          items: controller.payoutTypes
              .map(
                (e) =>
                    DropdownMenuItem<DrapDown>(value: e, child: Text(e.name)),
              )
              .toList(),
          onChanged: (DrapDown? newValue) {
            if (newValue != null) {
              controller.payoutType(newValue);
            }
          },
          validator: (value) => value == null ? 'Required field' : null,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            labelText: 'Payouts Type'.tr,
            border: InputBorder.none,
          ),
        ),
      ),

      // Date of Payouts
      PayoutsFormField(
        label: "${'date_of_payouts'.tr} *",
        value: controller.dateOfPayouts.value,
        errorText: controller.dateError.value,
        isReadOnly: true,
        validator: (value) => value == null ? 'Required field' : null,
        onTap: () => _selectDate(context),
      ),

      Obx(
        () => controller.payoutType.value!.id ==1 
            ? _buildInfoRow(
                'Previous Advance'.tr,
                '₹${controller.employeeData.value?.advanceAmount ?? ""}',
              )
            : _buildInfoRow(
                'advance_amount'.tr,
                '₹${controller.employeeData.value?.advanceAmount ?? ""}',
              ),
      ),

      // Deduction of Advance Amount
      Obx(
        () => controller.payoutType.value!.id != 1
            ? PayoutsFormField(
                label: "${'deduction_advance_amount'.tr} *",
                value: controller.deductionAdvanceAmount.value,
                errorText: controller.deductionError.value,
                validator: (value) => value == null ? 'Required field' : null,
                keyboardType: TextInputType.number,
                onChanged: controller.updateDeductionAmount,
              )
            : const SizedBox.shrink(),
      ),

      // Obx(
      //   () => controller.payoutType.value != 'Advance'
      //       ? _buildInfoRow(
      //           'balance_advance'.tr,
      //           '₹${controller.employeeData.value?.balanceAdvance ?? ""}',
      //         )
      //       : const SizedBox.shrink(),
      // ),
      // const SizedBox(height: 16),
      // Payouts Amount
      Obx(
        () => controller.payoutType.value!.id ==0
            ? PayoutsFormField(
                label: "${'advance_amount'.tr} *",
                value: controller.payoutsAmount.value,
                errorText: controller.payoutsError.value,
                keyboardType: TextInputType.number,
                onChanged: controller.updatePayoutsAmount,
              )
            : PayoutsFormField(
                label: "${'payouts_amount'.tr} *",
                value: controller.payoutsAmount.value,
                errorText: controller.payoutsError.value,
                keyboardType: TextInputType.number,
                onChanged: controller.updatePayoutsAmount,
              ),
      ),
      Obx(
        () => controller.payoutType.value!.id == 0
            ? _buildInfoRow(
                'totel_advance'.tr,
                '₹${((controller.employeeData.value?.advanceAmount ?? 0) + (int.tryParse(controller.payoutsAmount.value) ?? 0))}',
              )
            : const SizedBox(),
      ),

      // To Pay
      Obx(
        () => controller.payoutType.value!.id != 0
            ? PayoutsFormField(
                label: "${'to_pay'.tr} *",
                value: controller.toPay.value,
                errorText: controller.toPayError.value,
                keyboardType: TextInputType.number,
                validator: (value) => value == null ? 'Required field' : null,
                onChanged: controller.updateToPay,
              )
            : const SizedBox.shrink(),
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
