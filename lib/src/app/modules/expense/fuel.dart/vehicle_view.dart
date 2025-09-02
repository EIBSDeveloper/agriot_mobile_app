import 'package:argiot/src/app/modules/expense/fuel.dart/purchases_add_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/input_card_style.dart';

class VehicleView extends GetView<PurchasesAddController> {
  const VehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('vehicle_screen_title'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.buildDateField(),
            SizedBox(height: 16),
            controller.buildInventoryCategoryDropdown(),
            SizedBox(height: 16),
            controller.buildInventoryItemDropdown(),
            const SizedBox(height: 16),
            // Vendor Dropdown
            controller.buildVendorDropdown(),
            const SizedBox(height: 16),
            _buildRegNoField(),
            const SizedBox(height: 16),
            _buildOwnerNameField(),
            const SizedBox(height: 16),
            _buildDateOfRegField(context),
            const SizedBox(height: 16),
            _buildRegValidTillField(context),
            const SizedBox(height: 16),
            _buildEngineNoField(),
            const SizedBox(height: 16),
            _buildChasisNoField(),
            const SizedBox(height: 16),
            _buildRunningKmField(),
            const SizedBox(height: 16),
            _buildServiceFrequencyRow(),
            const SizedBox(height: 16),
            _buildFuelCapacityField(),
            const SizedBox(height: 16),
            _buildAverageMileageField(),
            const SizedBox(height: 16),
              controller.buildPaidAmountField(),
          const SizedBox(height: 16),
            controller.buildPurchaseAmountField(),
            const SizedBox(height: 16),

            controller.buildDescriptionField(),

            const SizedBox(height: 16),
            _buildInsuranceCheckbox(),
            Obx(
              () => controller.showInsuranceDetails.value
                  ? _buildInsuranceSection(context)
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRegNoField() {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.regNoController,
        decoration: InputDecoration(
          hintText: 'reg_no_label'.tr,
          border: InputBorder.none,
          errorText: controller.errors['reg_no'],
        ),
      ),
    );
  }

  Widget _buildOwnerNameField() {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.ownerNameController,
        decoration: InputDecoration(
          hintText: 'owner_name_label'.tr,
          border: InputBorder.none,
          errorText: controller.errors['owner_name'],
        ),
      ),
    );
  }

  Widget _buildDateOfRegField(BuildContext context) {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.dateOfRegController,
        decoration: InputDecoration(
          hintText: 'date_of_reg_label'.tr,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () =>
                controller.selectDate(controller.dateOfRegController, context),
          ),
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildRegValidTillField(BuildContext context) {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.regValidTillController,
        decoration: InputDecoration(
          hintText: 'reg_valid_till_label'.tr,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => controller.selectDate(
              controller.regValidTillController,
              context,
            ),
          ),
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildEngineNoField() {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.engineNoController,
        decoration: InputDecoration(
          hintText: 'engine_no_label'.tr,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildChasisNoField() {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.chasisNoController,
        decoration: InputDecoration(
          hintText: 'chasis_no_label'.tr,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRunningKmField() {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.runningKmController,
        decoration: InputDecoration(
          hintText: 'running_km_label'.tr,border:  InputBorder.none,
          errorText: controller.errors['running_km'],
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildServiceFrequencyRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: InputCardStyle(
            child: TextFormField(
              controller: controller.serviceFrequencyController,
              decoration: InputDecoration(
                hintText: 'service_frequency_label'.tr,
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: InputCardStyle(
            child: DropdownButtonFormField<String>(
              value: controller.serviceFrequencyUnit.value,
              items: ['KM', 'Miles']
                  .map(
                    (unit) => DropdownMenuItem(value: unit, child: Text(unit)),
                  )
                  .toList(),
              onChanged: (value) => controller.setServiceFrequencyUnit(value!),
              decoration: InputDecoration(
                hintText: 'unit_label'.tr,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFuelCapacityField() {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.fuelCapacityController,
        decoration: InputDecoration(
          hintText: 'fuel_capacity_label'.tr,
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildAverageMileageField() {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.averageMileageController,
        decoration: InputDecoration(
          hintText: 'average_mileage_label'.tr,
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildInsuranceCheckbox() {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            value: controller.showInsuranceDetails.value,
            onChanged: controller.toggleInsuranceDetails,
          ),
        ),
        Text('insurance_details_label'.tr),
      ],
    );
  }

  Widget _buildInsuranceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Divider(),
        Text('insurance_details_section'.tr, style: Get.textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildCompanyNameField(),
        const SizedBox(height: 16),
        _buildInsuranceNoField(),
        const SizedBox(height: 16),
        _buildInsuranceAmountField(),
        const SizedBox(height: 16),
        _buildStartDateField(context),
        const SizedBox(height: 16),
        _buildEndDateField(context),
        const SizedBox(height: 16),
        _buildRenewalDateField(context),
      ],
    );
  }

  Widget _buildCompanyNameField() {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.companyNameController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'company_name_label'.tr,
          errorText: controller.errors['company_name'],
        ),
      ),
    );
  }

  Widget _buildInsuranceNoField() {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.insuranceNoController,
        decoration: InputDecoration(
          hintText: 'insurance_no_label'.tr,
          border: InputBorder.none,
          errorText: controller.errors['insurance_no'],
        ),
      ),
    );
  }

  Widget _buildInsuranceAmountField() {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.insuranceAmountController,

        decoration: InputDecoration(
          hintText: 'insurance_amount_label'.tr,
          border: InputBorder.none,
          errorText: controller.errors['insurance_amount'],
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildStartDateField(BuildContext context) {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.startDateController,
        decoration: InputDecoration(
          hintText: 'start_date_label'.tr,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () =>
                controller.selectDate(controller.startDateController, context),
          ),
          errorText: controller.errors['start_date'],
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildEndDateField(BuildContext context) {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.endDateController,
        decoration: InputDecoration(
          hintText: 'end_date_label'.tr,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () =>
                controller.selectDate(controller.endDateController, context),
          ),
          errorText: controller.errors['end_date'],
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildRenewalDateField(BuildContext context) {
    return InputCardStyle(
      child: TextFormField(
        controller: controller.renewalDateController,
        decoration: InputDecoration(
          hintText: 'renewal_date_label'.tr,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => controller.selectDate(
              controller.renewalDateController,
              context,
            ),
          ),
          errorText: controller.errors['renewal_date'],
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.submitVehicleForm,
          child: controller.isLoading.value
              ? const CircularProgressIndicator()
              : Text('add_button'.tr),
        ),
      ),
    );
  }
}
