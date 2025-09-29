import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../service/utils/enums.dart';
import '../../../document/document.dart';
import '../../controller/kyc_controller.dart';
import '../../controller/land_controller.dart';
import '../../model/dropdown_item.dart';
import '../widget/searchable_dropdown.dart';
import '../widget/survey_item_widget.dart';

class LandView extends GetView<RegLandController> {
  LandView({super.key});

  final kycController = Get.find<KycController>();
  final gap = const SizedBox(height: 14);
  @override
  Widget build(BuildContext context) => Form(
    key: controller.formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        gap,
        CustomTextField(
          controller: controller.landIdController,
          onChanged: (value) {
            controller.formKey.currentState!.validate();
          },
          label: 'Land Name *',
          validator: (value) => value!.isEmpty ? 'Required field' : null,
        ),
        gap,
        CustomTextField(
          controller: controller.pattaNoController,
          label: 'Patta Number',
        ),
        gap,
        CustomTextField(
          controller: controller.pinCode,
          label: 'Pincode *',
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          keyboardType: TextInputType.number,
          validator: (value) => (value!.isEmpty)
              ? ('Required field')
              : (value.length != 6 ? "Ender 6 digit Pincode" : null),
        ),

        gap,
        Row(
          children: [
            Expanded(
              flex: 3,
              child: CustomTextField(
                controller: controller.measurementController,
                label: 'Measurement *',
                validator: (value) => value!.isEmpty ? 'Required field' : null,
                onChanged: (value) {
                  controller.formKey.currentState!.validate();
                },
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: SearchableDropdown<AppDropdownItem>(
                label: 'Unit *',
                items: controller.landUnits,
                displayItem: (value) => value.name.toString(),
                selectedItem: controller.selectedLandUnit.value,
                onChanged: (value) {
                  controller.selectedLandUnit.value = value;
                  controller.formKey.currentState!.validate();
                },
                validator: (value) {
                  if (controller.selectedLandUnit.value != null) {
                    return null;
                  }
                  return value == null ? 'Required field' : null;
                },
              ),
            ),
          ],
        ),
        gap,
        SearchableDropdown<AppDropdownItem>(
          label: 'Soil Type',
          items: controller.soilTypes,
          selectedItem: controller.selectedSoilType.value,
          onChanged: (value) => controller.selectedSoilType.value = value,

          displayItem: (value) => value.name.toString(),
        ),
        gap,
        InputCardStyle(
          child: TextFormField(
            controller: controller.locationListController,
            decoration: const InputDecoration(
              labelText: 'Location Coordinates *',
              border: InputBorder.none,
              isDense: true,
              suffixIcon: Icon(Icons.location_on),
            ),
            validator: (value) => value!.isEmpty ? 'Required field' : null,
            readOnly: true,
            onTap: controller.listpickLocation,
          ),
        ),
        gap,
        // _buildCountryDropdown(),
        // gap,
        // _buildStateDropdown(),
        // gap,
        // _buildCityDropdown(),
        // gap,
        // _buildTalukDropdown(),
        // gap,
        // _buildVillageDropdown(),
        // gap,
        // CustomTextField(
        //   controller: controller.locationController,
        //   label: 'Location Coordinates *',
        //   validator: (value) => value!.isEmpty ? 'Required field' : null,
        //   readOnly: true,
        //   onTap: controller.pickLocation,
        // ),
        gap,
        _buildSurveyDetailsSection(),
        gap,
        _buildDocumentsSection(),
        gap,
        _buildSubmitButton(),
        gap,
        gap,
      ],
    ),
  );

  Widget _buildSurveyDetailsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Survey Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Card(
            color: Get.theme.primaryColor,
            child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.add),
              onPressed: controller.addSurveyItem,
              tooltip: 'Add Survey Detail',
            ),
          ),
        ],
      ),
      Obx(() {
        if (controller.surveyItems.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No survey details added',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.surveyItems.length,
          itemBuilder: (context, index) => SurveyItemWidget(
            index: index,
            item: controller.surveyItems[index],
            areaUnits: controller.landUnits,

            onRemove: () => controller.removeSurveyItem(index),
            onChanged: (item) {
              controller.surveyItems[index] = item;
              controller.formKey.currentState!.validate();
            },
          ),
        );
      }),
    ],
  );

  Widget _buildDocumentsSection() => DocumentsSection(
    documentItems: controller.documentItems,
    type: DocTypes.land,
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
          : const Text('Save Land Details'),
    ),
  );
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InputCardStyle(
    child: TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
        isDense: true,
        suffixIcon: readOnly ? const Icon(Icons.location_on) : null,
      ),
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
    ),
  );
}
