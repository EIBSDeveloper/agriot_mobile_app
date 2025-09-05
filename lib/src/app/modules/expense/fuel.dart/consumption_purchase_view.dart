import 'package:argiot/src/app/modules/expense/fuel.dart/consumption_list.dart';
import 'package:argiot/src/app/modules/expense/fuel.dart/consumption_purchase_controller.dart';
import 'package:argiot/src/app/modules/expense/fuel.dart/purchase_list.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../../../utils.dart';

class ConsumptionPurchaseView extends GetView<ConsumptionPurchaseController> {
  const ConsumptionPurchaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: capitalizeFirstLetter(
          controller.selectedInventoryTypeName.value,
        ),
      ),
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
          Obx(() {
            return Container(
              color: Get.theme.colorScheme.surface,
              child: TabBar(
                controller: TabController(
                  length: 2,
                  initialIndex: controller.currentTabIndex.value,
                  vsync: Navigator.of(context),
                ),
                onTap: controller.changeTab,
                tabs: [
                  Tab(
                    text:
                        "${'consumption'.tr} (${controller.consumptionData.length})",
                  ),
                  Tab(
                    text:
                        "${'purchase'.tr} (${controller.purchaseData.length})",
                  ),
                ],
              ),
            );
          }),

          // Content Area
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return IndexedStack(
                index: controller.currentTabIndex.value,
                children: [
                  ConsumptionList(records: controller.consumptionData),
                  PurchaseList(records: controller.purchaseData),
                ],
              );
            }),
          ),
          Obx(() {
            return Container(
              height: 60,
              width: double.infinity,
              decoration: AppStyle.inputDecoration!.copyWith(
                color: Get.theme.primaryColor.withAlpha(100),
              ),
              padding: const EdgeInsets.only(right: 80, left: 8),
              margin: const EdgeInsets.only(right: 8, bottom: 15, left: 10),
              child: Center(
                child: FittedBox(
                  child: Text(
                    " Available ${controller.selectedInventoryItemName} : 00",
                    style: Get.theme.textTheme.headlineMedium,
                  ),
                ),
              ),
            );
          }),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Get.theme.primaryColor, 
        onPressed: () {
          if (controller.currentTabIndex.value == 0) {
            Get.toNamed(
              Routes.fuelConsumption,
              arguments: {
                "type": controller.selectedInventoryType.value,
                "category": controller.selectedInventoryCategory.value,
                "item": controller.selectedInventoryItem.value,
              },
            )?.then((res) {});
          } else {
            if (controller.selectedInventoryType.value == 7) {
              Get.toNamed(
                '/fuel-expenses-entry',
                arguments: {"id": controller.selectedInventoryType.value},
              );
            } else if (controller.selectedInventoryType.value == 1) {
              Get.toNamed(
                '/vehicle_entry',
                arguments: {"id": controller.selectedInventoryType.value},
              );
            } else if (controller.selectedInventoryType.value == 2) {
              Get.toNamed(
                '/machinery_entry',
                arguments: {"id": controller.selectedInventoryType.value},
              );
            } else {
              Get.toNamed(
                '/fertilizer_entry',
                arguments: {"id": controller.selectedInventoryType.value},
              );
            }
          }
        },
        child: Icon(Icons.add),
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
