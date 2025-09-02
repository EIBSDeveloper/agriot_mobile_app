import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/app_style.dart';
import '../../../../widgets/input_card_style.dart';
import '../../../near_me/views/widget/widgets.dart';
import '../../../registration/model/crop_model.dart';
import '../../../registration/model/dropdown_item.dart';
import '../../../registration/view/widget/searchable_dropdown.dart';
import '../../controller/crop_controller.dart';

class CropViewPage extends GetView<CropController> {
  const CropViewPage({super.key});

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
        padding: EdgeInsets.all(10),
        child: Form(
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
              SizedBox(height: 16),
              Text(
                'Land Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Obx(() {
                return LandDropdown(
                  lands: controller.lands,
                  selectedLand: controller.selectedLand.value,
                  onChanged: (land) => controller.changeLand(land!),
                );
              }),
              SizedBox(height: 16),
              Obx(() {
                if (controller.surveyList.isNotEmpty) {
                  return SurveyDropdown(
                    surveys: controller.surveyList,
                    selectedSurvey: controller.selectedSurvey.value,
                    onChanged: (value) =>
                        controller.selectedSurvey.value = value,
                  );
                }
                return SizedBox();
              }),
              SizedBox(height: 16),
              _buildMeasurementSection(),
              _buildTextField(
                controller: controller.descriptionController,
                label: 'Description',
                maxLines: 4,
                // validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              SizedBox(height: 16),
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
  }) {
    return InputCardStyle(
      noHeight: true,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          isDense: true,
          suffixIcon: readOnly ? Icon(Icons.location_on) : null,
        ),
        maxLines: maxLines ?? 1,
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
  }

  Widget _buildPlantationDateField(BuildContext context) {
    return Obx(() {
      return InputCardStyle(
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
              child: InputCardStyle(
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
                return InputCardStyle(
                  child: DropdownButtonFormField<DropdownItem>(
                    value: controller.selectedMeasurementUnit.value,
                    decoration: InputDecoration(
                      hintText: 'Unit *',
                      border: InputBorder.none,
                    ),
                    isExpanded : true,
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
            : Text('Save Crop '),
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
  final bool addNew;
  final Function(CropSurveyDetail?) onChanged;
  final String label;

  const SurveyDropdown({
    super.key,
    required this.surveys,
    required this.selectedSurvey,
    required this.onChanged,
    this.addNew = false,
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
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
