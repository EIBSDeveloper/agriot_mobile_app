import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/modules/vendor/vendor_customer_controller.dart';
import 'package:argiot/src/app/modules/vendor/vendor_customer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_style.dart';
import '../../../utils.dart';
import '../../widgets/input_card_style.dart';
import '../../widgets/title_text.dart';

class VendorCustomerListView extends GetView<VendorCustomerController> {
  const VendorCustomerListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'vendor_customer'.tr),
      body: RefreshIndicator(
        onRefresh: () {
          return controller.fetchVendorCustomerList();
        },
        child: Column(
          children: [
            _buildFilterRow(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: controller.vendorCustomerList.length,
                  itemBuilder: (context, index) {
                    final item = controller.vendorCustomerList[index];
                    return _buildListItem(item!);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Get.theme.primaryColor,
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          _buildTabButton('both', 'both'.tr),
          _buildTabButton('customer', 'customer'.tr),
          _buildTabButton('vendor', 'vendor'.tr),
        ],
      ),
    );
  }

  Widget _buildTabButton(String index, String text) {
    return Obx(() {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: controller.selectedFilter.value == index
                  ? Get.theme.primaryColor
                  : Colors.grey[200],
            ),
            onPressed: () {
              controller.selectedFilter.value = index;
              controller.fetchVendorCustomerList();
            },
            child: Text(
              text.tr,
              style: Get.textTheme.bodyLarge?.copyWith(
                color: controller.selectedFilter.value == index
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildListItem(VendorCustomer item) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(item.name, style: Get.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.shopName != null) Text(item.shopName!),
            if (item.businessName != null) Text(item.businessName!),
            if (item.inventoryType != null) Text(item.inventoryType!),
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            makePhoneCall(item.mobileNo);
          },
          icon: Icon(Icons.call, color: Get.theme.primaryColor),
        ),
        onTap: () =>
            Get.toNamed('/vendor-customer-details', arguments: {'id': item.id}),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Text(
              'add_new'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('customer'.tr),
              leading: const Icon(Icons.person),
              onTap: () {
                Get.back();
                controller.selectedType.value = 'customer';
                Get.toNamed('/add-vendor-customer');
              },
            ),
            ListTile(
              title: Text('vendor'.tr),
              leading: const Icon(Icons.store),
              onTap: () {
                Get.back();
                controller.selectedType.value = 'vendor';
                Get.toNamed('/add-vendor-customer');
              },
            ),
            ListTile(
              title: Text('both'.tr),
              leading: const Icon(Icons.people_alt),
              onTap: () {
                Get.back();
                controller.selectedType.value = 'both';
                Get.toNamed('/add-vendor-customer');
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class AddVendorCustomerView extends GetView<VendorCustomerController> {
  const AddVendorCustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'add_${controller.selectedType}'.tr,
      ),
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
  }

  Widget _buildMarketTypeSection() {
    return Obx(() {
      if (controller.isMARKETLoading.value) {
        return _buildMarketLoadingDropdown();
      }
      return Column(
        children: [
          InputCardStyle(
            child: DropdownButtonFormField<Market>(
              isExpanded: true,
              value: controller.selectedMarket.value,
              decoration: InputDecoration(
                hintText: "${'select_market'.tr}*",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: controller.markets.map((Market market) {
                return DropdownMenuItem<Market>(
                  value: market,
                  child: Text(market.name),
                );
              }).toList(),
              onChanged: (Market? value) {
                controller.selectedMarket.value = value;
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    });
  }

  Widget _buildInventoryTypeSection() {
    return Column(
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
            title: Text("Select Inventory Types"),
            itemsTextStyle: TextStyle(color: Colors.black),
            selectedItemsTextStyle: TextStyle(color: Colors.black),
            searchHintStyle: TextStyle(color: Colors.black),
            searchTextStyle: TextStyle(color: Colors.black),
            buttonText: Text("Select Inventory Types"),
            selectedColor: Get.theme.primaryColor,
            chipDisplay: MultiSelectChipDisplay(
              textStyle: TextStyle(color: Colors.black),
              chipColor: const Color.fromARGB(137, 221, 234, 234),
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
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('basic_info'.tr, style: Get.textTheme.titleSmall),
        const SizedBox(height: 8),
        InputCardStyle(
          child: TextFormField(
            controller: controller.nameController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
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
              hintText: "${'mobile_number'.tr} *",
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
              hintText: 'email'.tr,
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
              hintText:
                  controller.selectedType.value == 'customer' ||
                      controller.selectedType.value == 'both'
                  ? 'shop_name'.tr
                  : 'business_name'.tr,
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildMarketTypeSection(),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('location_info'.tr, style: Get.textTheme.titleSmall),
        const SizedBox(height: 8),
        InputCardStyle(
          child: TextField(
            controller: controller.doorNoController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'address'.tr,
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        InputCardStyle(
          child: TextFormField(
            controller: controller.pincodeController,
            decoration: InputDecoration(
              hintText: "${'pincode'.tr}*",
              border: InputBorder.none,
            ),
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
  }

  Widget _buildMarketLoadingDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'loading_markets'.tr,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: Padding(
          padding: EdgeInsets.all(12.0),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      child: SizedBox.shrink(),
    );
  }

  Widget _buildFinancialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('financial_info'.tr, style: Get.textTheme.titleSmall),
        const SizedBox(height: 8),
        InputCardStyle(
          child: TextFormField(
            controller: controller.gstNoController,
            decoration: InputDecoration(
              hintText: 'gst_number'.tr,
              border: InputBorder.none,
            ),
          ),
        ),

        const SizedBox(height: 12),
        Container(
          decoration: AppStyle.decoration.copyWith(
            color: const Color.fromARGB(137, 221, 234, 234),
            boxShadow: const [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

          child: TextFormField(
            controller: controller.descriptionController,
            decoration: InputDecoration(
              hintText: 'description'.tr,
              border: InputBorder.none,
            ),
            maxLines: 3,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed: controller.isSubmitting.value ? null : controller.submitForm,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Get.theme.primaryColor,
        ),
        child: controller.isSubmitting.value
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('submit'.tr, style: TextStyle(color: Colors.white)),
      );
    });
  }
}

class VendorCustomerDetailsView extends GetView<VendorCustomerController> {
  const VendorCustomerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final VendorCustomer? item =
        Get.arguments['item'] ??
        controller.vendorCustomerList.firstWhereOrNull(
          (e) => e!.id == Get.arguments['id'],
        );

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: Text('details_not_found'.tr)),
        body: Center(child: Text('item_not_found'.tr)),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: item.name,
        actions: [
          IconButton(
            onPressed: () {
              controller.deleteDetails(item.id, item.type);
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.type == 'vendor') _buildVendorDetails(item),
            if (item.type == 'customer') _buildCustomerDetails(item),
            _buildCommonDetails(item),
            const SizedBox(height: 20),
            _buildActionButtons(item),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Get.theme.primaryColor,
        onPressed: () => makePhoneCall(item.mobileNo),
        child: const Icon(Icons.call),
      ),
    );
  }

  Widget _buildVendorDetails(VendorCustomer item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText('vendor_details'.tr),
        const SizedBox(height: 8),
        if (item.businessName != null)
          _buildDetailRow('business_name'.tr, item.businessName!),
        if (item.inventoryType != null)
          _buildDetailRow('inventory_type'.tr, item.inventoryType!),
        const Divider(),
      ],
    );
  }

  Widget _buildCustomerDetails(VendorCustomer item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText('customer_details'.tr),
        const SizedBox(height: 8),
        if (item.shopName != null)
          _buildDetailRow('shop_name'.tr, item.shopName!),
        if (item.market != null) _buildDetailRow('market'.tr, item.market!),
        const Divider(),
      ],
    );
  }

  Widget _buildCommonDetails(VendorCustomer item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('mobile_number'.tr, item.mobileNo),
        if (item.email != null) _buildDetailRow('email'.tr, item.email!),
        if (item.doorNo != null) _buildDetailRow('address'.tr, item.doorNo!),
        // if (item.country != null) _buildDetailRow('country'.tr, item.country!),
        // if (item.state != null) _buildDetailRow('state'.tr, item.state!),
        // if (item.city != null) _buildDetailRow('city'.tr, item.city!),
        // if (item.taluk != null) _buildDetailRow('taluk'.tr, item.taluk!),
        // if (item.village != null) _buildDetailRow('village'.tr, item.village!),
        // if (item.postCode != null)
        _buildDetailRow('pincode'.tr, item.postCode.toString()),
        if (item.gstNo != null) _buildDetailRow('gst_number'.tr, item.gstNo!),
        if (item.taxNo != null) _buildDetailRow('tax_number'.tr, item.taxNo!),
        _buildDetailRow(
          'opening_balance'.tr,
          '${item.isCredit ? ' + ' : ' - '}${item.openingBalance}',
          color: item.isCredit ? Colors.green : Colors.red,
        ),
        if (item.description != null)
          _buildDetailRow('description'.tr, item.description!),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(VendorCustomer item) {
    return Row(
      children: [
        // Expanded(
        //   child: ElevatedButton.icon(
        //     onPressed: () =>,
        //     icon: const Icon(Icons.call),
        //     label: Text('call'.tr),
        //     style: ElevatedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //     ),
        //   ),
        // ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _navigateToEdit(item),
            icon: const Icon(Icons.edit),
            label: Text('edit'.tr),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToEdit(VendorCustomer item) {
    // Populate the form with existing data
    controller.selectedType.value = item.type;
    controller.nameController.text = item.name;
    controller.mobileController.text = item.mobileNo;
    controller.emailController.text = item.email ?? '';
    controller.shopNameController.text =
        item.shopName ?? item.businessName ?? '';
    controller.doorNoController.text = item.doorNo ?? '';
    controller.pincodeController.text = item.postCode?.toString() ?? '';
    controller.gstNoController.text = item.gstNo ?? '';
    controller.taxNoController.text = item.taxNo ?? '';
    controller.openingBalanceController.text = item.openingBalance.toString();
    controller.descriptionController.text = item.description ?? '';

    // Navigate to edit screen
    Get.toNamed(
      '/add-vendor-customer',
      arguments: {'isEditing': true, 'id': item.id},
    );
  }
}
