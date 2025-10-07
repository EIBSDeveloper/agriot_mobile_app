import 'package:argiot/src/app/widgets/lower_case_text_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../widgets/input_card_style.dart';
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
                label: '${'your_name'.tr} *',
                validator: (value) =>
                    value!.isEmpty ? 'required_field'.tr : null,
              ),

              if (!controller.isEmailLogin.value) ...[
                gap,
                _buildTextField(
                  controller: controller.emailController,
                  label: '${'email'.tr} *',
                  inputFormatters: [LowerCaseTextFormatter()],
                  validator: (value) =>
                      !GetUtils.isEmail(value!) ? 'enter_valid_email'.tr : null,
                  keyboardType: TextInputType.emailAddress,
                ),
              ] else ...[
                gap,
                _buildTextField(
                  controller: controller.numberController,
                  label: '${'mobile_number'.tr} *',
                  validator: (value) =>
                      value!.isEmpty ? 'required_field'.tr : null,
                  keyboardType: TextInputType.number,
                ),
              ],
              gap,
              _buildTextField(
                controller: controller.companyController,
                label: 'company_name'.tr,
              ),
              gap,
              _buildTextField(
                controller: controller.taxNoController,
                label: 'tax_number'.tr,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          gap,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: controller.pincodeController,
                label: '${'pincode'.tr} *',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) => (value!.isEmpty)
                    ? ('required_field'.tr)
                    : (value.length != 6 ? "enter_6_digit_pincode".tr : null),
                keyboardType: TextInputType.number,
              ),

              gap,
              _buildTextField(
                controller: controller.locationController,
                label: '${'location_coordinates'.tr} *',
                validator: (value) =>
                    value!.isEmpty ? 'required_field'.tr : null,
                readOnly: true,
                onTap: controller.pickLocation,
              ),
              gap,
              _buildTextField(
                controller: controller.doorNoController,
                label: 'address'.tr,
                maxLines: 3,
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
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    int? maxLines = 1,
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
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
    ),
  );

  Widget _buildSubmitButton() => Obx(
    () => ElevatedButton(
      onPressed: controller.isSubmitting.value ? null : controller.submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Get.theme.primaryColor,
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
          : Text('save_continue'.tr),
    ),
  );
}
