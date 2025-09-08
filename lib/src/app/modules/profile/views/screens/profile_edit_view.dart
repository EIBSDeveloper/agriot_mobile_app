import 'dart:io';
import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/modules/profile/controller/profile_edit_controller.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProfileEditView extends GetView<ProfileEditController> {
  const ProfileEditView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Edit Profile', showBackButton: true),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 10),
              _buildPersonalInfoSection(),
              const SizedBox(height: 10),
              _buildAddressSection(),
              const SizedBox(height: 10),
              _buildCompanySection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      );
    }),
  );

  Widget _buildImagePicker() => Center(
    child: Stack(
      children: [
        Obx(() {
          if (controller.imagePath.isNotEmpty) {
            return CircleAvatar(
              radius: 50,
              backgroundImage: controller.imagePath.startsWith('http')
                  ? NetworkImage(controller.imagePath.value)
                  : FileImage(File(controller.imagePath.value))
                        as ImageProvider,
            );
          }
          return const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 40),
          );
        }),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: controller.pickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPersonalInfoSection() => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: controller.nameController,
            label: 'Full Name *',
            validator: (value) =>
                value?.isEmpty ?? true ? 'Required field' : null,
          ),
          // const SizedBox(height: 12),
          // _buildTextField(
          //   controller: controller.phoneController,
          //   label: 'Phone Number *',
          //   validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
          //   keyboardType: TextInputType.phone,
          // ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: controller.emailController,
            label: 'Email *',
            validator: (value) =>
                !GetUtils.isEmail(value ?? '') ? 'Enter valid email' : null,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    ),
  );

  Widget _buildAddressSection() => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address Information',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: controller.doorNoController,
            label: 'Address',
            // validator: (value) =>
            //     value?.isEmpty ?? true ? 'Required field' : null,
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          _buildTextField(
            controller: controller.locationController,
            label: 'Location Coordinates *',
            validator: (value) => value!.isEmpty ? 'Required field' : null,
            readOnly: true,
            onTap: controller.pickLocation,
          ),
          const SizedBox(height: 12),
          // _buildCountryDropdown(),
          // const SizedBox(height: 12),
          // _buildStateDropdown(),
          // const SizedBox(height: 12),
          // _buildCityDropdown(),
          // const SizedBox(height: 12),
          // _buildTalukDropdown(),
          // const SizedBox(height: 12),
          // _buildVillageDropdown(),
        ],
      ),
    ),
  );

  Widget _buildCompanySection() => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Information',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: controller.companyController,
            label: 'Company Name',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: controller.taxNoController,
            label: 'Tax Identification Number',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: controller.descriptionController,
            label: 'Description',

            height: 100,
          ),
        ],
      ),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    double? height,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
  }) => InputCardStyle(
    child: TextFormField(
      inputFormatters: inputFormatters,
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
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

  Widget _buildSubmitButton() => Obx(
    () => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
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
            : const Text('Save Changes', style: TextStyle(fontSize: 16)),
      ),
    ),
  );
}
