import 'package:argiot/src/app/modules/expense/fuel.dart/consumption_list.dart';
import 'package:argiot/src/app/modules/expense/fuel.dart/consumption_purchase_controller.dart';
import 'package:argiot/src/app/modules/expense/fuel.dart/purchase_list.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConsumptionPurchaseView extends GetView<ConsumptionPurchaseController> {
  const ConsumptionPurchaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('consumption_purchase_title'.tr)),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                buildInventoryCategoryDropdown(),
                SizedBox(width: 16),
                buildInventoryItemDropdown(),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Get.theme.colorScheme.surface,
            child: TabBar(
              controller: TabController(
                length: 2,
                initialIndex: controller.currentTabIndex.value,
                vsync: Navigator.of(context),
              ),
              onTap: controller.changeTab,
              tabs: [
                Tab(text: 'consumption'.tr),
                Tab(text: 'purchase'.tr),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // if (controller.selectedItem.value == null) {
              //   return Center(
              //     child: Text('select_item_to_view_data'.tr),
              //   );
              // }

              return IndexedStack(
                index: controller.currentTabIndex.value,
                children: [
                  ConsumptionList(records: controller.consumptionData),
                  PurchaseList(records: controller.purchaseData),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildInventoryCategoryDropdown() {
    return Expanded(
      child: Obx(
        () => Column(
          children: [
            InputCardStyle(
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Inventory Category'.tr,
                  border: InputBorder.none,
                ),
                value: controller.selectedInventoryCategory.value,
                items: controller.inventoryCategories
                    .map(
                      (category) => DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.inventoryCategory(value);
                },
              ),
            ),
            //  ErrorText(error: getErrorForField('vendor')),
          ],
        ),
      ),
    );
  }

  Widget buildInventoryItemDropdown() {
    return Expanded(
      child: Obx(
        () => InputCardStyle(
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'Inventory Item'.tr,
              border: InputBorder.none,
            ),
            value: controller.selectedInventoryItem.value,
            items: controller.inventoryItems
                .map(
                  (item) => DropdownMenuItem<int>(
                    value: item.id,
                    child: Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                controller.selectedInventoryCategory.value != null
                ? controller.setInventoryItem(value!)
                : null,
          ),
        ),
      ),
    );
  }
}
