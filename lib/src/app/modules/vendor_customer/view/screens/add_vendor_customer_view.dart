import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/vendor_customer/controller/vendor_customer_controller.dart';
import 'package:argiot/src/app/modules/vendor_customer/model/market.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddVendorCustomerView extends GetView<VendorCustomerController> {
  const AddVendorCustomerView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'add_${controller.selectedType}'.tr),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            if (controller.selectedType.value == 'vendor' ||
                controller.selectedType.value == 'both')
              _buildInventoryTypeSection(),

            _buildBasicInfoSection(),
            _buildLocationSection(),
            _buildFinancialSection(),
            // _buildImageSection(),
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

            icon: const Icon(Icons.keyboard_arrow_down),
            initialValue: controller.selectedMarket.value,
            decoration: InputDecoration(
              labelText: "${'select_market'.tr}*",
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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

  Widget _buildInventoryTypeSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("${'inventory_type'.tr} *", style: Get.textTheme.titleSmall),
      const SizedBox(height: 8),
      Obx(() {
        if (controller.isinveroryLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final model = controller.purchaseModel.value;
        if (model == null) {
          return const Center(child: Text("No data available"));
        }

        final items = model.items;

        final options = items.entries.map((entry) {
          final key = entry.key;
          return MultiSelectItem<String>(key, key);
        }).toList();

        return MultiSelectDialogField<String>(
          items: options,
          dialogHeight: 300,
          initialValue: controller.selectedKeys.toList(),
          title: const Text("Select Inventory Types"),
          itemsTextStyle: const TextStyle(color: Colors.black),
          selectedItemsTextStyle: const TextStyle(color: Colors.black),
          searchHintStyle: const TextStyle(color: Colors.black),
          searchTextStyle: const TextStyle(color: Colors.black),
          buttonText: const Text("Select Inventory Types"),
          selectedColor: Get.theme.primaryColor,
          chipDisplay: MultiSelectChipDisplay(
            textStyle: const TextStyle(color: Colors.black),
            chipColor: AppStyle.inputBoxColor,
            onTap: (value) => controller.toggleSelection(value),
          ),
          onConfirm: (values) {
            controller.setSelectedKeys(values.toSet());
          },
        );
      }),
      const SizedBox(height: 16),
    ],
  );

  Widget _buildBasicInfoSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('basic_info'.tr, style: Get.textTheme.titleSmall),
      const SizedBox(height: 8),
      InputCardStyle(
        child: TextFormField(
          controller: controller.nameController,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText:
                "${controller.selectedType.value == 'customer' ? 'customer_name'.tr : 'vendor_name'.tr}*",
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
            labelText:
                controller.selectedType.value == 'customer' ||
                    controller.selectedType.value == 'both'
                ? "${'shop_name'.tr} *"
                : "${'business_name'.tr} *",
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
      Text('location_info'.tr, style: Get.textTheme.titleSmall),
      const SizedBox(height: 8),
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
            labelText: "${'pincode'.tr}*",
            border: InputBorder.none,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'required_field'.tr;
            if (value!.length != 6) return 'pincode_length'.tr;
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
      Text('financial_info'.tr, style: Get.textTheme.titleSmall),
      const SizedBox(height: 8),
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
      onPressed: controller.isSubmitting.value ? null :(){
         controller.submitForm(id:  Get.arguments?["id"]);
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
}
