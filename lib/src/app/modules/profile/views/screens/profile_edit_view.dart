import 'dart:io';

import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/profile/controller/profile_edit_controller.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../widgets/loading.dart';

class ProfileEditView extends GetView<ProfileEditController> {
  const ProfileEditView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'edit_profile'.tr, showBackButton: true),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Loading();
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
            var startsWith = controller.imagePath.startsWith('http');
            return CircleAvatar(
              radius: 50,
              backgroundImage: startsWith
                  ? CachedNetworkImageProvider(controller.imagePath.value)
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
            'personal_information'.tr,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: controller.nameController,
            label: '${'full_name'.tr} *',
            validator: (value) =>
                value?.isEmpty ?? true ? 'required_field'.tr : null,
          ),

          const SizedBox(height: 12),
          _buildTextField(
            controller: controller.emailController,
            label: '${'email'.tr} *',
            validator: (value) =>
                !GetUtils.isEmail(value ?? '') ? 'enter_valid_email'.tr : null,
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
            'address_information'.tr,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),  const SizedBox(height: 12),
          _buildTextField(
            controller: controller.locationController,
            label: '${'location_coordinates'.tr} *',
            validator: (value) => value!.isEmpty ? 'required_field'.tr : null,
            readOnly: true,
            maxLines: 1,
            onTap: controller.pickLocation,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: controller.pincodeController,
            label: '${'pincode'.tr} *',
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) =>
                value?.isEmpty ?? true ? 'required_field'.tr : null,
            keyboardType: TextInputType.number,
          ),
        
          const SizedBox(height: 12),
          _buildTextField(
            controller: controller.doorNoController,
            label: 'address'.tr,
            maxLines: 3,
            // validator: (value) =>
            //     value?.isEmpty ?? true ? 'required_field'.tr : null,
          ),
          const SizedBox(height: 12),
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
            'company_information'.tr,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: controller.companyController,
            label: 'company_name'.tr,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: controller.taxNoController,
            label: 'tax_identification_number'.tr,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: controller.descriptionController,
            label: 'description'.tr,
            maxLines: 3,
          ),
        ],
      ),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxLines,
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
        labelText: label,
        border: InputBorder.none,
        isDense: true,
        suffixIcon: readOnly ? const Icon(Icons.location_on) : null,
      ),
      maxLines: maxLines,
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
            : Text('save_changes'.tr, style: const TextStyle(fontSize: 16)),
      ),
    ),
  );
}
