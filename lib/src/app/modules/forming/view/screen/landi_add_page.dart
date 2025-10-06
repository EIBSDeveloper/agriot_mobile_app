import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../service/utils/enums.dart';
import '../../../../widgets/input_card_style.dart';
import '../../../document/document.dart';
import '../../../manager/model/dropdown_model.dart';
import '../../../registration/controller/kyc_controller.dart';
import '../../../registration/model/dropdown_item.dart';
import '../../../registration/view/widget/searchable_dropdown.dart';
import '../../../registration/view/widget/survey_item_widget.dart';
import '../../controller/land_controller.dart';

class LandViewPage extends GetView<LandController> {
  LandViewPage({super.key});

  final kycController = Get.find<KycController>();
  final gap = const SizedBox(height: 14);
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args != null && args['landId'] != null) {
      controller.landId.value = args['landId'];
    }
    return Scaffold(
      appBar: const CustomAppBar(title: 'Land Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: controller.landIdController,
                label: 'Land Name *',
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              gap,
              _buildTextField(
                controller: controller.pattaNoController,
                label: 'Patta Number',
                // validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              gap,
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => InputCardStyle(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButtonFormField<AssignMangerModel>(
                          initialValue: controller.selectedManger.value,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: controller.managers
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              controller.selectedManger.value = value,
                          decoration: const InputDecoration(
                            labelText: 'Assign Manager',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    color: Get.theme.primaryColor,
                    child: IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Get.toNamed(Routes.employeeAdd)?.then((result) {
                          controller.loadManagers();
                        });
                      },
                      tooltip: 'Add Manager Detail',
                    ),
                  ),
                ],
              ),
              gap,
              SearchableDropdown<AppDropdownItem>(
                label: 'Soil Type ',
                items: controller.soilTypes,
                selectedItem: controller.selectedSoilType.value,
                onChanged: (value) => controller.selectedSoilType.value = value,
                // validator: (value) => value == null ? 'Required field' : null,
                displayItem: (value) => value.name.toString(),
              ),

              gap,
              _buildTextField(
                controller: controller.locationListController,
                label: 'Location Coordinates *',
                validator: (value) => value!.isEmpty ? 'Required field' : null,
                readOnly: true,
                onTap: controller.listpickLocation,
              ),
              gap,
              _buildTextField(
                controller: controller.pincodeController,
                label: 'Pincode *',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required field' : null,
                keyboardType: TextInputType.number,
              ),
              gap,
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: controller.measurementController,
                      label: 'Measurement *',
                      validator: (value) =>
                          value!.isEmpty ? 'Required field' : null,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(
                    () => Expanded(
                      flex: 2,
                      child: SearchableDropdown<AppDropdownItem>(
                        label: 'Unit *',
                        items: controller.landUnits,
                        displayItem: (value) => value.name.toString(),
                        selectedItem: controller.selectedLandUnit.value,
                        onChanged: (value) =>
                            controller.selectedLandUnit.value = value,
                        // validator: (value) => value == null ? 'Required field' : null,
                      ),
                    ),
                  ),
                ],
              ),

              gap,
              const Divider(),
              _buildSurveyDetailsSection(),
              gap,
              const Divider(),
              _buildDocumentsSection(),
              gap,
              const Divider(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurveyDetailsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
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
            onChanged: (item) => controller.surveyItems[index] = item,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) => InputCardStyle(
    child: TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
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
