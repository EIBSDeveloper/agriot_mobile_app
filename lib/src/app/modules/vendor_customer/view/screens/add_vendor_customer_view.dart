import 'dart:io';

import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/vendor_customer/controller/vendor_customer_controller.dart';
import 'package:argiot/src/app/modules/vendor_customer/model/market.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddVendorCustomerView extends StatefulWidget {
  const AddVendorCustomerView({super.key});

  @override
  State<AddVendorCustomerView> createState() => _AddVendorCustomerViewState();
}

class _AddVendorCustomerViewState extends State<AddVendorCustomerView> {
  final VendorCustomerController controller = Get.put(
    VendorCustomerController(),
  );
  @override
  void dispose() {
    controller.clearForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'add_contact'.tr, actions: []),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            _buildBasicInfoSection(),
            _buildLocationSection(),
            _buildFinancialSection(),
            // Obx(
            //   () => (controller.selectedType.value == 'vendor')
            //       ? _buildInventoryTypeSection()
            //       : const SizedBox.shrink(),
            // ),
            _buildSubmitButton(),
          ],
        ),
      ),
    ),
  );

  Widget _buildMarketTypeSection() => Obx(() {
    if (controller.isMARKETLoading.value) {
      return _buildMarketLoadingDropdown();
    }
    return Column(
      children: [
        InputCardStyle(
          child: DropdownButtonFormField<Market>(
            isExpanded: true,
            validator: (value) =>
                value?.name.isEmpty ?? true ? 'required_field'.tr : null,
            icon: const Icon(Icons.keyboard_arrow_down),
            initialValue: controller.selectedMarket.value,
            decoration: InputDecoration(
              labelText: "${'select_market'.tr}*",
              border: InputBorder.none,
            ),
            items: controller.markets
                .map(
                  (Market market) => DropdownMenuItem<Market>(
                    value: market,
                    child: Text(market.name),
                  ),
                )
                .toList(),
            onChanged: (Market? value) {
              controller.selectedMarket.value = value;
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  });

  Widget _buildBasicInfoSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // _buildImagePicker(),
      const SizedBox(height: 8),
      InputCardStyle(
        child: DropdownButtonFormField<String>(
          isExpanded: true,

          icon: const Icon(Icons.keyboard_arrow_down),
          initialValue: controller.selectedType.value,
          decoration: InputDecoration(
            labelText: 'select_contact'.tr,
            border: InputBorder.none,
          ),
          items: [
            DropdownMenuItem(value: 'customer', child: Text('customer'.tr)),
            DropdownMenuItem(value: 'vendor', child: Text('vendor'.tr)),
          ],
          onChanged: (String? value) {
            controller.selectedType.value = value!;
          },
        ),
      ),
      const SizedBox(height: 12),

      InputCardStyle(
        child: TextFormField(
          controller: controller.nameController,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: "${'name'.tr} *",
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'required_field'.tr : null,
        ),
      ),
      const SizedBox(height: 12),
      InputCardStyle(
        child: TextFormField(
          controller: controller.mobileController,
          decoration: InputDecoration(
            labelText: "${'mobile_number'.tr} *",
            border: InputBorder.none,
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'required_field'.tr;
            if (!GetUtils.isPhoneNumber(value!)) return 'invalid_phone'.tr;
            return null;
          },
        ),
      ),
      const SizedBox(height: 12),
      InputCardStyle(
        child: TextFormField(
          controller: controller.emailController,
          decoration: InputDecoration(
            labelText: 'email'.tr,
            border: InputBorder.none,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isNotEmpty ?? false) {
              if (!GetUtils.isEmail(value!)) return 'invalid_email'.tr;
            }
            return null;
          },
        ),
      ),
      const SizedBox(height: 12),
      InputCardStyle(
        child: TextFormField(
          controller: controller.shopNameController,
          decoration: InputDecoration(
            labelText: 'business_name'.tr,
            border: InputBorder.none,
          ),
        ),
      ),
      const SizedBox(height: 12),
      _buildMarketTypeSection(),
    ],
  );

  Widget _buildLocationSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Location URL
      InputCardStyle(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextFormField(
          controller: controller.locationController,
          decoration: const InputDecoration(
            labelText: 'Location *',
            border: InputBorder.none,
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'required_field'.tr
              : null,
          readOnly: true,
          onTap: controller.pickLocation,
        ),
      ),
      const SizedBox(height: 12),
      InputCardStyle(
        child: TextField(
          controller: controller.doorNoController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'address'.tr,
            border: InputBorder.none,
          ),
        ),
      ),
      const SizedBox(height: 12),
      InputCardStyle(
        child: TextFormField(
          controller: controller.pincodeController,
          decoration: InputDecoration(
            labelText: "${'pincode'.tr} *",
            border: InputBorder.none,
          ),
          // inputFormatters: [
          //   FilteringTextInputFormatter.digitsOnly,
          //   LengthLimitingTextInputFormatter(6),
          // ],
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'required_field'.tr;
            }
            if (value.length > 11) {
              return 'Please enter a valid Pincode'.tr;
            }

            return null;
          },
        ),
      ),
      const SizedBox(height: 12),
    ],
  );

  Widget _buildMarketLoadingDropdown() => InputDecorator(
    decoration: InputDecoration(
      labelText: 'loading_markets'.tr,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      suffixIcon: const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ),
    child: const SizedBox.shrink(),
  );

  Widget _buildFinancialSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      InputCardStyle(
        child: TextFormField(
          controller: controller.gstNoController,
          decoration: InputDecoration(
            labelText: 'gst_number'.tr,
            border: InputBorder.none,
          ),
        ),
      ),

      const SizedBox(height: 12),
      InputCardStyle(
        child: TextFormField(
          controller: controller.descriptionController,
          decoration: InputDecoration(
            labelText: 'description'.tr,
            border: InputBorder.none,
          ),
          maxLines: 3,
        ),
      ),
      const SizedBox(height: 16),
    ],
  );

  Widget _buildSubmitButton() => Obx(
    () => ElevatedButton(
      onPressed: controller.isSubmitting.value
          ? null
          : () {
              controller.submitForm(id: Get.arguments?["id"]);
            },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Get.theme.primaryColor,
      ),
      child: controller.isSubmitting.value
          ? const CircularProgressIndicator(color: Colors.white)
          : Text('submit'.tr, style: const TextStyle(color: Colors.white)),
    ),
  );

  Widget _buildImagePicker() => Center(
    child: InkWell(
      onTap: controller.pickImage,
      child: Stack(
        children: [
          Obx(() {
            if (controller.imagePath.isNotEmpty) {
              return CircleAvatar(
                radius: 50,
                backgroundImage: controller.imagePath.startsWith('http')
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
        ],
      ),
    ),
  );
}
