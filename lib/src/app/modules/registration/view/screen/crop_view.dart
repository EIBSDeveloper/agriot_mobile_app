import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/app_style.dart';
import '../../../near_me/views/widget/widgets.dart';
import '../../controller/crop_controller.dart';
import '../../model/crop_model.dart';
import '../../model/dropdown_item.dart';
import '../widget/searchable_dropdown.dart';

class CropView extends GetView<RegCropController> {
  const CropView({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCropTypeDropdown(),
          SizedBox(height: 16),
          _buildCropDropdown(),
          SizedBox(height: 16),
          _buildHarvestFrequencyDropdown(),
          SizedBox(height: 16),
          _buildPlantationDateField(context),
          SizedBox(height: 24),
          Obx(() {
            return LandDropdown(
              lands: controller.lands,
              selectedLand: controller.selectedLand.value,
              onChanged: (land) => controller.changeLand(land!),
            );
          }),

          // SearchableDropdown<LandWithSurvey>(
          //   label: 'Land Identification *',
          //   items: controller.lands,
          //   displayItem: (country) => country.landName.toString(),
          //   selectedItem: controller.selectedLand.value,
          //   onChanged: (value) => controller.selectedLand.value = value,
          //   validator: (value) => value == null ? 'Required field' : null,
          // ),
          SizedBox(height: 16),
          Obx(() {
            if (controller.surveyList.isNotEmpty) {
              return SurveyDropdown(
                surveys: controller.surveyList,
                selectedSurvey: controller.selectedSurvey.value,
                onChanged: (value) => controller.selectedSurvey.value = value,
              );
            }
            return SizedBox();
          }),
          SizedBox(height: 16),
          _buildMeasurementSection(),
          _buildTextField(
            controller: controller.locationController,
            label: 'Location Coordinates *',
            validator: (value) => value!.isEmpty ? 'Required field' : null,
            readOnly: true,
            onTap: controller.pickLocation,
          ),
          SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: AppStyle.decoration.copyWith(
        color: const Color.fromARGB(137, 221, 234, 234),
        boxShadow: const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: 55,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          isDense: true,
          suffixIcon: readOnly ? Icon(Icons.location_on) : null,
        ),
        validator: validator,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }

  Widget _buildCropTypeDropdown() {
    return Obx(() {
      if (controller.isLoadingCropTypes.value) {
        return _buildLoadingDropdown('Loading crop types...');
      }
      return SearchableDropdown<DropdownItem>(
        label: 'Crop Type *',
        items: controller.cropTypes,
        displayItem: (country) => country.name.toString(),
        selectedItem: controller.selectedCropType.value,
        onChanged: (value) => controller.selectedCropType.value = value,
        validator: (value) => value == null ? 'Required field' : null,
      );
    });
  }

  Widget _buildCropDropdown() {
    return Obx(() {
      if (controller.selectedCropType.value == null) {
        return _buildDisabledDropdown('Select crop type first');
      }
      if (controller.isLoadingCrops.value) {
        return _buildLoadingDropdown('Loading crops...');
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchableDropdown<DropdownItem>(
            displayItem: (country) => country.name.toString(),
            label: 'Crop *',
            items: controller.crops,
            selectedItem: controller.selectedCrop.value,
            onChanged: (value) => controller.selectedCrop.value = value,
            validator: (value) => value == null ? 'Required field' : null,
          ),
          if (controller.crops.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'No crops available for selected type',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildHarvestFrequencyDropdown() {
    return Obx(() {
      if (controller.isLoadingHarvestFrequencies.value) {
        return _buildLoadingDropdown('Loading harvest frequencies...');
      }
      return SearchableDropdown<DropdownItem>(
        label: 'Harvest Frequency *',
        items: controller.harvestFrequencies,
        displayItem: (country) => country.name.toString(),
        selectedItem: controller.selectedHarvestFrequency.value,
        onChanged: (value) => controller.selectedHarvestFrequency.value = value,
        validator: (value) => value == null ? 'Required field' : null,
      );
    });
  }

  Widget _buildPlantationDateField(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(137, 221, 234, 234),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Plantation Date *',
            border: InputBorder.none,
            suffixIcon: Icon(Icons.calendar_today),
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
      );
    });
  }

  Widget _buildMeasurementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(137, 221, 234, 234),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: TextFormField(
                  controller: controller.measurementController,
                  decoration: InputDecoration(
                    labelText: 'Measurement *',
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Required field' : null,
                ),
              ),
            ),
            SizedBox(width: 16),
           Expanded(
              flex: 2,
              child: Obx(() {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(137, 221, 234, 234),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: DropdownButtonFormField<DropdownItem>(
                    value: controller.selectedMeasurementUnit.value,
                    decoration: InputDecoration(
                      labelText: 'Unit *',
                      border: InputBorder.none,
                    ),
                    items: controller.landUnits.isNotEmpty
                        ? [
                            ...controller.landUnits.map((unit) {
                              return DropdownMenuItem<DropdownItem>(
                                value: unit,
                                child: FittedBox(child: Text(unit.name)),
                              );
                            }),
                          ]
                        : [],
                    onChanged: (valu) {
                      controller.selectedMeasurementUnit.value = valu;
                    }, // Disabled as we only have one unit
                  ),
                );
              }),
             
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed: controller.isSubmitting.value ? null : controller.submitForm,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: controller.isSubmitting.value
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text('Save Crop Details'),
      );
    });
  }

  Widget _buildLoadingDropdown(String text) {
    return Container(
      decoration: AppStyle.decoration.copyWith(
        color: const Color.fromARGB(137, 221, 234, 234),
        boxShadow: const [],
      ),
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: text,
          border: InputBorder.none,
          isDense: true,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledDropdown(String text) {
    return Container(
      decoration: AppStyle.decoration.copyWith(
        color: const Color.fromARGB(137, 221, 234, 234),
        boxShadow: const [],
      ),
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: text,
          border: InputBorder.none,
          isDense: true,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.keyboard_arrow_down_outlined,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class SurveyDropdown extends StatelessWidget {
  final List<CropSurveyDetail> surveys;
  final CropSurveyDetail? selectedSurvey;
  final Function(CropSurveyDetail?) onChanged;
  final String label;

  const SurveyDropdown({
    super.key,
    required this.surveys,
    required this.selectedSurvey,
    required this.onChanged,
    this.label = 'Survey No',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.decoration.copyWith(
        color: const Color.fromARGB(137, 221, 234, 234),
        boxShadow: const [],
      ),
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: DropdownButtonFormField<CropSurveyDetail>(
        value: surveys.contains(selectedSurvey) ? selectedSurvey : null,
        items: surveys.map((CropSurveyDetail survey) {
          return DropdownMenuItem(
            value: survey,
            child: Text(
              '${survey.surveyNo} (${survey.surveyMeasurementValue} ${survey.surveyMeasurementUnit})',
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
