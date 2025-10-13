import 'package:argiot/src/app/modules/near_me/views/widget/land_dropdown.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../forming/view/widget/survey_dropdown.dart';
import '../../controller/crop_controller.dart';
import '../../model/dropdown_item.dart';
import '../widget/searchable_dropdown.dart';

class CropView extends GetView<RegCropController> {
  const CropView({super.key});

  @override
  Widget build(BuildContext context) => Form(
    key: controller.formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCropTypeDropdown(),
        const SizedBox(height: 16),
        _buildCropDropdown(),
        const SizedBox(height: 16),
        _buildHarvestFrequencyDropdown(),
        const SizedBox(height: 16),
        _buildPlantationDateField(context),
        const SizedBox(height: 24),
        Obx(
          () => LandDropdown(
            lands: controller.lands,
            selectedLand: controller.selectedLand.value,
            onChanged: (land) => controller.changeLand(land!),
          ),
        ),

        // SearchableDropdown<LandWithSurvey>(
        //   label: 'Land Identification *',
        //   items: controller.lands,
        //   displayItem: (country) => country.landName.toString(),
        //   selectedItem: controller.selectedLand.value,
        //   onChanged: (value) => controller.selectedLand.value = value,
        //   validator: (value) => value == null ? 'Required field' : null,
        // ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.surveyList.isNotEmpty) {
            return SurveyMultiSelect(
              surveys: controller.surveyList,
              selectedSurveys: controller.selectedSurvey,
              onChanged: (value) => controller.selectedSurvey.value = value,
            );
          }
          return const SizedBox();
        }),
        const SizedBox(height: 16),
        _buildTextField(
          controller: controller.locationController,
          label: '${'location_coordinates'.tr} *',
          validator: (value) => value!.isEmpty ? 'required_field'.tr : null,
          readOnly: true,
          onTap: controller.pickLocation,
        ),   const SizedBox(height: 16),
        _buildMeasurementSection(),
        const SizedBox(height: 32),
        _buildSubmitButton(),
      ],
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) => InputCardStyle(
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
        isDense: true,
        suffixIcon: readOnly ? const Icon(Icons.location_on) : null,
      ),
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
    ),
  );

  Widget _buildCropTypeDropdown() => Obx(() {
    if (controller.isLoadingCropTypes.value) {
      return _buildLoadingDropdown('loading_crop_types'.tr);
    }
    return SearchableDropdown<AppDropdownItem>(
      label: '${'crop_type'.tr} *',
      items: controller.cropTypes,
      displayItem: (country) => country.name.toString(),
      selectedItem: controller.selectedCropType.value,
      onChanged: (value) => controller.selectedCropType.value = value,
      validator: (value) => value == null ? 'required_field'.tr : null,
    );
  });

  Widget _buildCropDropdown() => Obx(() {
    if (controller.isLoadingCrops.value) {
      return _buildLoadingDropdown('loading_crops'.tr);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchableDropdown<AppDropdownItem>(
          displayItem: (country) => country.name.toString(),
          label: '${'crop'.tr} *',
          items: controller.crops,
          selectedItem: controller.selectedCrop.value,
          onChanged: (value) => controller.selectedCrop.value = value,
          validator: (value) => value == null ? 'required_field'.tr : null,
        ),
        if (controller.crops.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'no_crops_available'.tr,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
      ],
    );
  });

  Widget _buildHarvestFrequencyDropdown() => Obx(() {
    if (controller.isLoadingHarvestFrequencies.value) {
      return _buildLoadingDropdown('loading_harvest_frequencies'.tr);
    }
    return SearchableDropdown<AppDropdownItem>(
      label: '${'harvest_frequency'.tr} *',
      items: controller.harvestFrequencies,
      displayItem: (country) => country.name.toString(),
      selectedItem: controller.selectedHarvestFrequency.value,
      onChanged: (value) => controller.selectedHarvestFrequency.value = value,
      validator: (value) => value == null ? 'required_field'.tr : null,
    );
  });

  Widget _buildPlantationDateField(BuildContext context) => Obx(
    () => InputCardStyle(
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: '${'plantation_date'.tr} *',
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        controller: TextEditingController(
          text: controller.plantationDate.value != null
              ? '${controller.plantationDate.value!.day}/'
                    '${controller.plantationDate.value!.month}/'
                    '${controller.plantationDate.value!.year}'
              : '',
        ),
        validator: (value) => controller.plantationDate.value == null
            ? 'required_field'.tr
            : null,
        onTap: () => controller.selectPlantationDate(context),
      ),
    ),
  );

  Widget _buildMeasurementSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            flex: 3,
            child: InputCardStyle(
              child: TextFormField(
                controller: controller.measurementController,
                decoration: InputDecoration(
                  labelText: '${'measurement'.tr} *',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'required_field'.tr : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Obx(
              () => InputCardStyle(
                child: DropdownButtonFormField<AppDropdownItem>(
                  isExpanded: true,

                  icon: const Icon(Icons.keyboard_arrow_down),
                  initialValue: controller.selectedMeasurementUnit.value,
                  decoration: InputDecoration(
                    labelText: '${'unit'.tr} *',
                    border: InputBorder.none,
                  ),
                  items: controller.landUnits.isNotEmpty
                      ? [
                          ...controller.landUnits.map(
                            (unit) => DropdownMenuItem<AppDropdownItem>(
                              value: unit,
                              child: FittedBox(child: Text(unit.name)),
                            ),
                          ),
                        ]
                      : [],
                  onChanged: (valu) {
                    controller.selectedMeasurementUnit.value = valu;
                  }, // Disabled as we only have one unit
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ],
  );

  Widget _buildSubmitButton() => Obx(
    () => ElevatedButton(
      onPressed: controller.isSubmitting.value ? null : controller.submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: controller.isSubmitting.value
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text('save_crop_details'.tr),
    ),
  );

  Widget _buildLoadingDropdown(String text) => InputCardStyle(
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: text,
        border: InputBorder.none,
        isDense: true,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    ),
  );
}
