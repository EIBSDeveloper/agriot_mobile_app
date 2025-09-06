import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/app_style.dart';
import '../../controller/kyc_controller.dart';

class KycView extends GetView<KycController> {
  const KycView({super.key});

  @override
  Widget build(BuildContext context) {
    var gap = const SizedBox(height: 14);
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildTextField(
                controller: controller.nameController,
                label: 'Your Name *',
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              gap,
              _buildTextField(
                controller: controller.emailController,
                label: 'Email *',
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
                validator: (value) => (value!.isEmpty)
                    ? ('Required field')
                    : (value.length != 6 ? "Ender 6 digit Pincode" : null),
                keyboardType: TextInputType.number,
              ),
              gap,
              _buildTextField(
                controller: controller.locationController,
                label: 'Location Coordinates *',
                validator: (value) => value!.isEmpty ? 'Required field' : null,
                readOnly: true,
                onTap: controller.pickLocation,
              ),
            ],
          ),

          const SizedBox(height: 32),
          _buildSubmitButton(),
          const SizedBox(height: 60),
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
  }) => Container(
      decoration: AppStyle.decoration.copyWith(
        color: const Color.fromARGB(137, 221, 234, 234),
        boxShadow: const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      // height: height ?? 55,
      constraints: const BoxConstraints(
        minHeight: 55, // minimum height for all fields
      ),
      child: TextFormField(
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

  Widget _buildSubmitButton() => Obx(() => ElevatedButton(
        onPressed: controller.isSubmitting.value ? null : controller.submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color.fromARGB(255, 100, 120, 31),
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
            : const Text('Save & Continue'),
      ));
}
