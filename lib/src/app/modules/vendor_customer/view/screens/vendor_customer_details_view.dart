import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/modules/vendor_customer/controller/vendor_customer_controller.dart';
import 'package:argiot/src/app/modules/vendor_customer/model/vendor_customer.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        appBar: CustomAppBar(title: 'details_not_found'.tr),
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
            icon: const Icon(Icons.delete),
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

  Widget _buildVendorDetails(VendorCustomer item) => Column(
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

  Widget _buildCustomerDetails(VendorCustomer item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TitleText('details'.tr),
      const SizedBox(height: 8),
      if (item.shopName != null)
        _buildDetailRow('shop_name'.tr, item.shopName!),
      if (item.market != null) _buildDetailRow('market'.tr, item.market!),
      const Divider(),
    ],
  );

  Widget _buildCommonDetails(VendorCustomer item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildDetailRow('mobile_number'.tr, item.mobileNo),
      if (item.email != null) _buildDetailRow('email'.tr, item.email!),
      if (item.doorNo != null) _buildDetailRow('address'.tr, item.doorNo!),

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

  Widget _buildDetailRow(String label, String value, {Color? color}) => Padding(
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

  Widget _buildActionButtons(VendorCustomer item) => Row(
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
