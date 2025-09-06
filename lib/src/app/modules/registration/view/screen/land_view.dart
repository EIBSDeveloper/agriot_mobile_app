import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/app_style.dart';
import '../../controller/kyc_controller.dart';
import '../../controller/land_controller.dart';
import '../../model/dropdown_item.dart';
import '../widget/document_item_widget.dart';
import '../widget/searchable_dropdown.dart';
import '../widget/survey_item_widget.dart';

class LandView extends GetView<RegLandController> {
  LandView({super.key});

  final kycController = Get.find<KycController>();
  var gap = const SizedBox(height: 14);
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
            label: 'Land Identification *',
            validator: (value) => value!.isEmpty ? 'Required field' : null,
          ),
          gap,
          CustomTextField(
            controller: controller.pattaNoController,
            label: 'Patta Number',
          ),
          gap,
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CustomTextField(
                  controller: controller.measurementController,
                  label: 'Measurement *',
                  validator: (value) =>
                      value!.isEmpty ? 'Required field' : null,
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
          Container(
            decoration: AppStyle.decoration.copyWith(
              color: const Color.fromARGB(137, 221, 234, 234),
              boxShadow: const [],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            constraints: const BoxConstraints(
      minHeight: 55, // minimum height for all fields
    ),
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
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: controller.addSurveyItem,
              tooltip: 'Add Survey Detail',
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

  Widget _buildDocumentsSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Land Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: controller.addDocumentItem,
              tooltip: 'Add Document',
            ),
          ],
        ),
        Obx(() {
          if (controller.documentItems.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No documents added',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.documentItems.length,
            itemBuilder: (context, index) => DocumentItemWidget(
                index: index,
                item: controller.documentItems[index],
                documentTypes: controller.documentTypes,
                onRemove: () => controller.removeDocumentItem(index),
                onChanged: (item) => controller.documentItems[index] = item,
                onPickDocument: () => controller.pickDocument(index),
              ),
          );
        }),
      ],
    );

  Widget _buildSubmitButton() => Obx(() => ElevatedButton(
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
      ));

  // Widget _buildTextField({
  //   required TextEditingController controller,
  //   required String label,
  //   String? Function(String?)? validator,
  //   TextInputType? keyboardType,
  //   bool readOnly = false,
  //   VoidCallback? onTap,
  // }) {
  //   return Container(
  //     decoration: AppStyle.decoration.copyWith(
  //       color: const Color.fromARGB(137, 221, 234, 234),
  //       boxShadow: const [],
  //     ),
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //     height: 55,
  //     child: TextFormField(
  //       controller: controller,
  //       decoration: InputDecoration(
  //         labelText: label,
  //         border: InputBorder.none,
  //         isDense: true,
  //         suffixIcon: readOnly ? Icon(Icons.location_on) : null,
  //       ),
  //       validator: validator,
  //       onChanged: (value){
  //         controller.text =value;
  //       },
  //       keyboardType: keyboardType,
  //       readOnly: readOnly,
  //       onTap: onTap,
  //     ),
  //   );
  // }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
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
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
      decoration: AppStyle.decoration.copyWith(
        color: const Color.fromARGB(137, 221, 234, 234),
        boxShadow: const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
   constraints: const BoxConstraints(
      minHeight: 55, // minimum height for all fields
    ),
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
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
}
