import 'package:argiot/src/app/modules/forming/view/widget/survey_dropdown.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/land_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/input_card_style.dart';
import '../../../registration/model/dropdown_item.dart';
import '../../../registration/view/widget/searchable_dropdown.dart';
import '../../controller/crop_controller.dart';

class CropView extends GetView<CropController> {
  const CropView({super.key});

  @override
  Widget build(BuildContext context) {
    var arguments = Get.arguments;
    int? landId;
    int? cropId;
    try {
      landId = arguments!['landId'];
      cropId = Get.arguments!['cropId'];
      if (landId != null && cropId != null) {
        Future.microtask(() => controller.loadCropDetails(landId!, cropId!));

        controller.parameterLandID.value = landId;
        controller.loadSurveyDetails(landId);
      }
    } catch (e) {
      landId = int.tryParse(arguments.toString());
      if (landId != null) {
        controller.parameterLandID.value = landId;
        controller.loadSurveyDetails(landId);
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: cropId != null ? 'Edit Crop Details' : 'Add Crop Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Form(
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
              const SizedBox(height: 16),
              const Text(
                'Land Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(
                () => LandDropdown(
                  lands: controller.lands,
                  selectedLand: controller.selectedLand.value,
                  onChanged: (land) => controller.changeLand(land!),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.surveyList.isNotEmpty) {
                  return SurveyMultiSelect(
                    surveys: controller.surveyList,
                    selectedSurveys: controller.selectedSurveys.toList(),
                    onChanged: (value) {
                      controller.selectedSurveys.assignAll(value);
                    },
                  );
                }
                return const SizedBox();
              }),
              const SizedBox(height: 16),
              _buildMeasurementSection(),

              _buildTextField(
                controller: controller.locationController,
                label: 'Location Coordinates *',
                validator: (value) => value!.isEmpty ? 'Required field' : null,
                readOnly: true,
                onTap: controller.pickLocation,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: controller.descriptionController,
                label: 'Description',
                maxLines: 4,
                // validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),

              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    int? maxLines,
    VoidCallback? onTap,
  }) => InputCardStyle(
    noHeight: true,
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
        isDense: true,
        suffixIcon: readOnly
            ? Icon(Icons.location_on, color: Get.theme.primaryColor)
            : null,
      ),
      maxLines: maxLines ?? 1,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
    ),
  );

  Widget _buildCropTypeDropdown() => Obx(() {
    if (controller.isLoadingCropTypes.value) {
      return _buildLoadingDropdown('Loading crop types...');
    }
    return SearchableDropdown<AppDropdownItem>(
      label: 'Crop Type *',
      items: controller.cropTypes,
      displayItem: (country) => country.name.toString(),
      selectedItem: controller.selectedCropType.value,
      onChanged: (value) => controller.selectedCropType.value = value,
      validator: (value) => value == null ? 'Required field' : null,
    );
  });

  Widget _buildCropDropdown() => Obx(() {
    if (controller.selectedCropType.value == null) {
      return _buildDisabledDropdown('Select crop type first');
    }
    if (controller.isLoadingCrops.value) {
      return _buildLoadingDropdown('Loading crops...');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchableDropdown<AppDropdownItem>(
          displayItem: (country) => country.name.toString(),
          label: 'Crop *',
          items: controller.crops,
          selectedItem: controller.selectedCrop.value,
          onChanged: (value) {
            controller.selectedCrop.value = value;
          },
          validator: (value) {
            if (controller.selectedCrop.value != null) {
              return null;
            }
            return value == null ? 'Required field' : null;
          },
        ),
        if (controller.crops.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'No crops available for selected type',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
      ],
    );
  });

  Widget _buildHarvestFrequencyDropdown() => Obx(() {
    if (controller.isLoadingHarvestFrequencies.value) {
      return _buildLoadingDropdown('Loading harvest frequencies...');
    }
    return SearchableDropdown<AppDropdownItem>(
      label: 'Harvest Frequency *',
      items: controller.harvestFrequencies,
      displayItem: (country) => country.name.toString(),
      selectedItem: controller.selectedHarvestFrequency.value,
      onChanged: (value) {
        controller.selectedHarvestFrequency.value = value;
      },
      validator: (value) {
        if (controller.selectedHarvestFrequency.value != null) {
          return null;
        }
        return value == null ? 'Required field' : null;
      },
    );
  });

  Widget _buildPlantationDateField(BuildContext context) => Obx(
    () => InputCardStyle(
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Plantation Date *',
          border: InputBorder.none,
          suffixIcon: Icon(Icons.calendar_today, color: Get.theme.primaryColor),
        ),
        controller: TextEditingController(
          text: controller.plantationDate.value != null
              ? '${controller.plantationDate.value!.day}/'
                    '${controller.plantationDate.value!.month}/'
                    '${controller.plantationDate.value!.year}'
              : '',
        ),
        validator: (value) =>
            controller.plantationDate.value == null ? 'Required field' : null,
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
                decoration: const InputDecoration(
                  labelText: 'Measurement *',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Obx(
              () => InputCardStyle(
                child: DropdownButtonFormField<AppDropdownItem>(
                  initialValue: controller.selectedMeasurementUnit.value,
                  decoration: const InputDecoration(
                    labelText: 'Unit *',
                    border: InputBorder.none,
                  ),

                  icon: const Icon(Icons.keyboard_arrow_down),
                  isExpanded: true,
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
          : const Text('Save Crop '),
    ),
  );

  Widget _buildLoadingDropdown(String text) =>  InputCardStyle(
               
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

  Widget _buildDisabledDropdown(String text) =>  InputCardStyle(
               
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.keyboard_arrow_down_outlined, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
