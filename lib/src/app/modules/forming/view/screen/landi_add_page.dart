import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/app_style.dart';
import '../../../registration/controller/kyc_controller.dart';
import '../../../registration/model/address_model.dart';
import '../../../registration/model/dropdown_item.dart';
import '../../../registration/view/widget/document_item_widget.dart';
import '../../../registration/view/widget/searchable_dropdown.dart';
import '../../../registration/view/widget/survey_item_widget.dart';
import '../../controller/land_controller.dart';

class LandViewPage extends GetView<LandController> {
  LandViewPage({super.key});

  final kycController = Get.find<KycController>();
  var gap = SizedBox(height: 14);
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args != null && args['landId'] != null) {
      controller.landId.value = args['landId'];
    }
    return Scaffold(
      appBar: AppBar(title: Text('Land Details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: controller.landIdController,
                label: 'Land Identification *',
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
                    flex: 3,
                    child: _buildTextField(
                      controller: controller.measurementController,
                      label: 'Measurement *',
                      validator: (value) =>
                          value!.isEmpty ? 'Required field' : null,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: SearchableDropdown<DropdownItem>(
                      label: 'Unit *',
                      items: controller.landUnits,
                      displayItem: (value) => value.name.toString(),
                      selectedItem: controller.selectedLandUnit.value,
                      onChanged: (value) =>
                          controller.selectedLandUnit.value = value,
                      // validator: (value) =>
                      //     value == null ? 'Required field' : null,
                    ),
                  ),
                ],
              ),
              gap,
              SearchableDropdown<DropdownItem>(
                label: 'Soil Type ',
                items: controller.soilTypes,
                selectedItem: controller.selectedSoilType.value,
                onChanged: (value) => controller.selectedSoilType.value = value,
                // validator: (value) => value == null ? 'Required field' : null,
                displayItem: (value) => value.name.toString(),
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
              _buildTextField(
                controller: controller.locationListController,
                label: 'Location Coordinates *',
                validator: (value) => value!.isEmpty ? 'Required field' : null,
                readOnly: true,
                onTap: controller.listpickLocation,
              ),
              gap,
              _buildSurveyDetailsSection(),
              gap,
              // // _buildTextField(
              // //   controller: controller.locationController,
              // //   label: 'Location Coordinates *',
              // //   validator: (value) => value!.isEmpty ? 'Required field' : null,
              // //   readOnly: true,
              // //   onTap: controller.listpickLocation,
              // // ),
              // gap,
              _buildDocumentsSection(),
              gap,
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Obx(() {
      if (kycController.isLoadingCountries.value) {
        return _buildLoadingDropdown('Loading countries...');
      }
      return SearchableDropdown<CountryModel>(
        label: 'Country *',
        items: kycController.countries,
        displayItem: (country) => country.name.toString(),
        selectedItem: kycController.selectedCountry.value,
        onChanged: (CountryModel? value) =>
            kycController.selectedCountry.value = value,
        validator: (value) => value == null ? 'Required field' : null,
      );
    });
  }

  Widget _buildStateDropdown() {
    return Obx(() {
      if (kycController.selectedCountry.value == null) {
        return _buildDisabledDropdown('Select country first');
      }
      if (kycController.isLoadingStates.value) {
        return _buildLoadingDropdown('Loading states...');
      }
      return SearchableDropdown<StateModel>(
        label: 'State *',
        items: kycController.states,

        displayItem: (country) => country.name.toString(),
        selectedItem: kycController.selectedState.value,
        onChanged: (StateModel? value) =>
            kycController.selectedState.value = value,
        validator: (value) => value == null ? 'Required field' : null,
      );
    });
  }

  Widget _buildCityDropdown() {
    return Obx(() {
      if (kycController.selectedState.value == null) {
        return _buildDisabledDropdown('Select state first');
      }
      if (kycController.isLoadingCities.value) {
        return _buildLoadingDropdown('Loading cities...');
      }
      return SearchableDropdown<CityModel>(
        label: 'City *',
        items: kycController.cities,
        displayItem: (country) => country.name.toString(),
        selectedItem: kycController.selectedCity.value,
        onChanged: (CityModel? value) =>
            kycController.selectedCity.value = value,
        validator: (value) => value == null ? 'Required field' : null,
      );
    });
  }

  Widget _buildTalukDropdown() {
    return Obx(() {
      if (kycController.selectedCity.value == null) {
        return _buildDisabledDropdown('Select city first');
      }
      if (kycController.isLoadingTaluks.value) {
        return _buildLoadingDropdown('Loading taluks...');
      }
      return SearchableDropdown<TalukModel>(
        label: 'Taluk *',
        items: kycController.taluks,
        displayItem: (country) => country.name.toString(),
        selectedItem: kycController.selectedTaluk.value,
        onChanged: (TalukModel? value) =>
            kycController.selectedTaluk.value = value,
        validator: (value) => value == null ? 'Required field' : null,
      );
    });
  }

  Widget _buildVillageDropdown() {
    return Obx(() {
      if (kycController.selectedTaluk.value == null) {
        return _buildDisabledDropdown('Select taluk first');
      }
      if (kycController.isLoadingVillages.value) {
        return _buildLoadingDropdown('Loading villages...');
      }
      return SearchableDropdown<VillageModel>(
        label: 'Village *',
        items: kycController.villages,
        selectedItem: kycController.selectedVillage.value,
        displayItem: (country) => country.name.toString(),
        onChanged: (VillageModel? value) =>
            kycController.selectedVillage.value = value,
        validator: (value) => value == null ? 'Required field' : null,
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

  Widget _buildSurveyDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Survey Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: controller.addSurveyItem,
              tooltip: 'Add Survey Detail',
            ),
          ],
        ),
        Obx(() {
          if (controller.surveyItems.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No survey details added',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.surveyItems.length,
            itemBuilder: (context, index) {
              return SurveyItemWidget(
                index: index,
                item: controller.surveyItems[index],
                areaUnits: controller.landUnits,
                onRemove: () => controller.removeSurveyItem(index),
                onChanged: (item) => controller.surveyItems[index] = item,
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Land Documents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: controller.addDocumentItem,
                tooltip: 'Add Document',
              ),
            ],
          ),
          Obx(() {
            if (controller.documentItems.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No documents added',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.documentItems.length,
              itemBuilder: (context, index) {
                return DocumentItemWidget(
                  index: index,
                  item: controller.documentItems[index],
                  documentTypes: controller.documentTypes,
                  onRemove: () => controller.removeDocumentItem(index),
                  onChanged: (item) => controller.documentItems[index] = item,
                  onPickDocument: () => controller.pickDocument(index),
                );
              },
            );
          }),
        ],
      ),
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
            : Text('Save Land Details'),
      );
    });
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
}
