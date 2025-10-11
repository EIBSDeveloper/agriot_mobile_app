import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/vendor_customer/controller/vendor_customer_controller.dart';
import 'package:argiot/src/app/modules/vendor_customer/model/vendor_customer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../../../service/utils/utils.dart';
import '../../../../widgets/loading.dart';
import '../../../../widgets/toggle_bar.dart';

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
                return const Loading();
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
        Get.toNamed(Routes.addVendorCustomer);
      },
      child: const Icon(Icons.add),
    ),
  );

  Widget _buildFilterRow() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Obx(
      () => ToggleBar(
        onTap: (index) {
          controller.selectedFilter.value = index;
          controller.fetchVendorCustomerList();
        },
        activePageIndex: controller.selectedFilter.value,
        buttonsList: ["customer".tr, "vendor".tr],
      ),
    ),
  );

  Widget _buildListItem(VendorCustomer item) => Card(
    elevation: 1,
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: ListTile(
      title: Text(capitalizeFirstLetter(item.name), style: Get.textTheme.titleMedium),
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
          Get.toNamed(Routes.vendorCustomerDetails, arguments: {'id': item.id}),
    ),
  );
}
