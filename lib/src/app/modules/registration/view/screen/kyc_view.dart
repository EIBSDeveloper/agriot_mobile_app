import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_style.dart';
import '../../controller/kyc_controller.dart';
import '../../model/address_model.dart';
import '../widget/searchable_dropdown.dart';

class KycView extends GetView<KycController> {
  const KycView({super.key});

  @override
  Widget build(BuildContext context) {
    var gap = SizedBox(height: 14);
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _buildTextField(
                controller: controller.nameController,
                label: 'Your Name *',
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              gap,
              _buildTextField(
                controller: controller.emailController,
                label: 'Email',
                validator: (value) =>
                    !GetUtils.isEmail(value!) ? 'Enter valid email' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              gap,
              _buildTextField(
                controller: controller.companyController,
                label: 'Company Name',
              ),
              gap,
              _buildTextField(
                controller: controller.taxNoController,
                label: 'Tax Number',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          gap,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: controller.doorNoController,
                label: 'Address',
              ),
              gap,
              _buildTextField(
                controller: controller.pincodeController,
                label: 'Pincode *',
                validator: (value) => value!.isEmpty ? 'Required field' : null,
                keyboardType: TextInputType.number,
              ),
              // gap,
              // _buildCountryDropdown(),
              // gap,
              // _buildStateDropdown(),
              // gap,
              // _buildCityDropdown(),
              // gap,
              // _buildTalukDropdown(),
              // gap,
              // _buildVillageDropdown(),
            ],
          ),

          SizedBox(height: 32),
          _buildSubmitButton(),
          SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    double? height,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: AppStyle.decoration.copyWith(
        color: const Color.fromARGB(137, 221, 234, 234),
        boxShadow: const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: height ?? 55,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          isDense: true,
        ),
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Obx(() {
      if (controller.isLoadingCountries.value) {
        return _buildLoadingDropdown('Loading countries...');
      }
      return SearchableDropdown<CountryModel>(
        label: 'Country *',
        items: controller.countries,
        displayItem: (country) => country.name.toString(),
        selectedItem: controller.selectedCountry.value,
        onChanged: (CountryModel? value) {
          controller.selectedCountry.value = value;
          controller.formKey.currentState!.validate();
        },
        validator: (value) {
          if (controller.selectedCountry.value != null) {
            return null;
          }

          return value == null ? 'Required field' : null;
        },
      );
    });
  }

  Widget _buildStateDropdown() {
    return Obx(() {
      if (controller.selectedCountry.value == null) {
        return _buildDisabledDropdown('State *');
      }
      if (controller.isLoadingStates.value) {
        return _buildLoadingDropdown('Loading states...');
      }
      return SearchableDropdown<StateModel>(
        label: 'State *',
        items: controller.states,

        displayItem: (country) => country.name.toString(),
        selectedItem: controller.selectedState.value,
        onChanged: (StateModel? value) {
          controller.selectedState.value = value;
          controller.formKey.currentState!.validate();
        },
        validator: (value) {
          if (controller.selectedState.value != null) {
            return null;
          }

          return value == null ? 'Required field' : null;
        },
      );
    });
  }

  Widget _buildCityDropdown() {
    return Obx(() {
      if (controller.selectedState.value == null) {
        return _buildDisabledDropdown('City *');
      }
      if (controller.isLoadingCities.value) {
        return _buildLoadingDropdown('Loading cities...');
      }
      return SearchableDropdown<CityModel>(
        label: 'City *',
        items: controller.cities,
        displayItem: (country) => country.name.toString(),
        selectedItem: controller.selectedCity.value,
        onChanged: (CityModel? value) {
          controller.selectedCity.value = value;
          controller.formKey.currentState!.validate();
        },
        validator: (value) {
          if (controller.selectedCity.value != null) {
            return null;
          }

          return value == null ? 'Required field' : null;
        },
      );
    });
  }

  Widget _buildTalukDropdown() {
    return Obx(() {
      if (controller.selectedCity.value == null) {
        return _buildDisabledDropdown('Taluk *');
      }
      if (controller.isLoadingTaluks.value) {
        return _buildLoadingDropdown('Loading taluks...');
      }
      return SearchableDropdown<TalukModel>(
        label: 'Taluk *',
        items: controller.taluks,
        displayItem: (country) => country.name.toString(),
        selectedItem: controller.selectedTaluk.value,
        onChanged: (TalukModel? value) {
          controller.selectedTaluk.value = value;
          controller.formKey.currentState!.validate();
        },
        validator: (value) {
          if (controller.selectedTaluk.value != null) {
            return null;
          }
          return value == null ? 'Required field' : null;
        },
      );
    });
  }

  Widget _buildVillageDropdown() {
    return Obx(() {
      if (controller.selectedTaluk.value == null) {
        return _buildDisabledDropdown('Village *');
      }
      if (controller.isLoadingVillages.value) {
        return _buildLoadingDropdown('Loading villages...');
      }
      return SearchableDropdown<VillageModel>(
        label: 'Village *',
        items: controller.villages,
        selectedItem: controller.selectedVillage.value,
        displayItem: (country) => country.name.toString(),
        onChanged: (VillageModel? value) {
          controller.selectedVillage.value = value;
          controller.formKey.currentState!.validate();
        },
        validator: (value) {
          if (controller.selectedVillage.value != null) {
            return null;
          }
          return value == null ? 'Required field' : null;
        },
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

  Widget _buildSubmitButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed: controller.isSubmitting.value ? null : controller.submitForm,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color.fromARGB(255, 100, 120, 31),
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
            : Text('Save & Continue'),
      );
    });
  }
}
