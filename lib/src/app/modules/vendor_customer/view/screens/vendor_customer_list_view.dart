import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/vendor_customer/model/vendor_customer.dart';
import 'package:argiot/src/app/modules/vendor_customer/controller/vendor_customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../service/utils/utils.dart';
import '../../../subscription/model/package_usage.dart';

class VendorCustomerListView extends GetView<VendorCustomerController> {
  const VendorCustomerListView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'vendor_customer'.tr),
    body: RefreshIndicator(
      onRefresh: () => controller.fetchVendorCustomerList(),
      child: Column(
        children: [
          _buildFilterRow(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
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
      onPressed: () {
        PackageUsage? package = findLimit();
        if (package!.customerBalance > 0) {
          _showAddDialog();
        } else {
          showDefaultGetXDialog("Vendor/Customer");
        }
      },
      child: const Icon(Icons.add),
    ),
  );

  Widget _buildFilterRow() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        _buildTabButton('both', 'both'.tr),
        _buildTabButton('customer', 'customer'.tr),
        _buildTabButton('vendor', 'vendor'.tr),
      ],
    ),
  );

  Widget _buildTabButton(String index, String text) => Obx(
    () => Expanded(
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
    ),
  );

  Widget _buildListItem(VendorCustomer item) => Card(
    elevation: 1,
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: ListTile(
      title: Text(item.name, style: Get.textTheme.titleMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.shopName != null && item.shopName != '')
            Text(item.shopName!),
          if (item.businessName != null && item.businessName != '')
            Text(item.businessName!),
          if (item.market != null && item.market != '') Text(item.market!),
          if (item.inventoryType != null)
            Text(
              item.inventoryType!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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

  void _showAddDialog() {
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
