import 'package:argiot/src/app/modules/expense/controller/purchases_add_controller.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/input_card_style.dart';

class VehicleView extends GetView<PurchasesAddController> {
  const VehicleView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'vehicle_screen_title'.tr),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            controller.buildPurchaseAmountField(),
            const SizedBox(height: 16),
            controller.buildPaidAmountField(),
            const SizedBox(height: 16),

            controller.buildDocumentsSection(),
            const SizedBox(height: 24),

           
            _buildInsuranceCheckbox(),
            Obx(
              () => controller.showInsuranceDetails.value
                  ? _buildInsuranceSection(context)
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16), controller.buildDescriptionField(),

               const SizedBox(height: 16),
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );

  Widget _buildRegNoField() => InputCardStyle(
    child: TextFormField(
      controller: controller.regNoController,
      decoration: InputDecoration(
        hintText: 'reg_no_label'.tr,
        border: InputBorder.none,
        errorText: controller.errors['reg_no'],
      ),
    ),
  );

  Widget _buildOwnerNameField() => InputCardStyle(
    child: TextFormField(
      controller: controller.ownerNameController,
      decoration: InputDecoration(
        hintText: 'owner_name_label'.tr,
        border: InputBorder.none,
        errorText: controller.errors['owner_name'],
      ),
    ),
  );

  Widget _buildDateOfRegField(BuildContext context) => InputCardStyle(
    child: TextFormField(
      controller: controller.dateOfRegController,
      onTap: () {
        controller.selectDate(controller.dateOfRegController, context);
      },
      validator: (value) => value!.isEmpty ? 'required_field'.tr : null,
      decoration: InputDecoration(
        hintText: 'date_of_reg_label'.tr,
        border: InputBorder.none,
        suffixIcon: Icon(Icons.calendar_today, color: Get.theme.primaryColor),
      ),
      readOnly: true,
    ),
  );

  Widget _buildRegValidTillField(BuildContext context) => InputCardStyle(
    child: TextFormField(
      controller: controller.regValidTillController,
      validator: (value) => value!.isEmpty ? 'required_field'.tr : null,
      onTap: () =>
          controller.selectDate(controller.regValidTillController, context),
      decoration: InputDecoration(
        hintText: 'reg_valid_till_label'.tr,

        border: InputBorder.none,
        suffixIcon: Icon(Icons.calendar_today, color: Get.theme.primaryColor),
      ),
      readOnly: true,
    ),
  );

  Widget _buildEngineNoField() => InputCardStyle(
    child: TextFormField(
      controller: controller.engineNoController,
      decoration: InputDecoration(
        hintText: 'engine_no_label'.tr,
        border: InputBorder.none,
      ),
    ),
  );

  Widget _buildChasisNoField() => InputCardStyle(
    child: TextFormField(
      controller: controller.chasisNoController,
      decoration: InputDecoration(
        hintText: 'chasis_no_label'.tr,
        border: InputBorder.none,
      ),
    ),
  );

  Widget _buildRunningKmField() => InputCardStyle(
    child: TextFormField(
      controller: controller.runningKmController,
      decoration: InputDecoration(
        hintText: 'running_km_label'.tr,
        border: InputBorder.none,
        errorText: controller.errors['running_km'],
      ),
      keyboardType: TextInputType.number,
    ),
  );

  Widget _buildServiceFrequencyRow() => Row(
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

            icon: const Icon(Icons.keyboard_arrow_down),
            items: ['KM', 'Days']
                .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
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

  Widget _buildFuelCapacityField() => InputCardStyle(
    child: TextFormField(
      controller: controller.fuelCapacityController,
      decoration: InputDecoration(
        hintText: 'fuel_capacity_label'.tr,
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
    ),
  );

  Widget _buildAverageMileageField() => InputCardStyle(
    child: TextFormField(
      controller: controller.averageMileageController,
      decoration: InputDecoration(
        hintText: 'average_mileage_label'.tr,
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
    ),
  );

  Widget _buildInsuranceCheckbox() => Row(
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

  Widget _buildInsuranceSection(BuildContext context) => Column(
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

  Widget _buildCompanyNameField() => InputCardStyle(
    child: TextFormField(
      controller: controller.companyNameController,
      validator: (value) => value!.isEmpty ? 'required_field'.tr : null,

      decoration: InputDecoration(
        border: InputBorder.none,

        hintText: 'company_name_label'.tr,
        errorText: controller.errors['company_name'],
      ),
    ),
  );

  Widget _buildInsuranceNoField() => InputCardStyle(
    child: TextFormField(
      controller: controller.insuranceNoController,
      validator: (value) => value!.isEmpty ? 'required_field'.tr : null,

      decoration: InputDecoration(
        hintText: 'insurance_no_label'.tr,
        border: InputBorder.none,
        errorText: controller.errors['insurance_no'],
      ),
    ),
  );

  Widget _buildInsuranceAmountField() => InputCardStyle(
    child: TextFormField(
      controller: controller.insuranceAmountController,
      validator: (value) => value!.isEmpty ? 'required_field'.tr : null,

      decoration: InputDecoration(
        hintText: 'insurance_amount_label'.tr,
        border: InputBorder.none,
        errorText: controller.errors['insurance_amount'],
      ),
      keyboardType: TextInputType.number,
    ),
  );

  Widget _buildStartDateField(BuildContext context) => InputCardStyle(
    child: TextFormField(
      controller: controller.startDateController,
      validator: (value) => value!.isEmpty ? 'required_field'.tr : null,

      onTap: () =>
          controller.selectDate(controller.startDateController, context),
      decoration: InputDecoration(
        hintText: 'start_date_label'.tr,
        border: InputBorder.none,
        suffixIcon: Icon(Icons.calendar_today, color: Get.theme.primaryColor),
        errorText: controller.errors['start_date'],
      ),
      readOnly: true,
    ),
  );

  Widget _buildEndDateField(BuildContext context) => InputCardStyle(
    child: TextFormField(
      controller: controller.endDateController,
      validator: (value) => value!.isEmpty ? 'required_field'.tr : null,

      onTap: () => controller.selectDate(controller.endDateController, context),
      decoration: InputDecoration(
        hintText: 'end_date_label'.tr,

        border: InputBorder.none,
        suffixIcon: Icon(Icons.calendar_today, color: Get.theme.primaryColor),
        errorText: controller.errors['end_date'],
      ),
      readOnly: true,
    ),
  );

  Widget _buildRenewalDateField(BuildContext context) => InputCardStyle(
    child: TextFormField(
      controller: controller.renewalDateController,
      validator: (value) => value!.isEmpty ? 'required_field'.tr : null,

      onTap: () =>
          controller.selectDate(controller.renewalDateController, context),
      decoration: InputDecoration(
        hintText: 'renewal_date_label'.tr,
        border: InputBorder.none,
        suffixIcon: Icon(Icons.calendar_today, color: Get.theme.primaryColor),
        errorText: controller.errors['renewal_date'],
      ),
      readOnly: true,
    ),
  );

  Widget _buildSubmitButton() => Obx(
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
