import 'package:argiot/src/app/modules/expense/view/screens/consumption_list.dart';
import 'package:argiot/src/app/modules/expense/controller/consumption_purchase_controller.dart';
import 'package:argiot/src/app/modules/expense/view/screens/purchase_list.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../service/utils/utils.dart';

class ConsumptionPurchaseView extends GetView<ConsumptionPurchaseController> {
  const ConsumptionPurchaseView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: capitalizeFirstLetter(controller.selectedInventoryTypeName.value),
    ),
    body: RefreshIndicator(
      onRefresh: controller.loadData,
      child: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                buildInventoryCategoryDropdown(),
                const SizedBox(width: 16),
                buildInventoryItemDropdown(),
              ],
            ),
          ),

          // Tab Bar
          Obx(
            () => Container(
              color: Get.theme.colorScheme.surface,
              child: TabBar(
                controller: controller.tabController,
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
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return TabBarView(
                controller: controller.tabController,
                children: [
                  ConsumptionList(
                    records: controller.consumptionData,
                    type: controller.inventoryType.value!,
                  ),
                  PurchaseList(
                    records: controller.purchaseData,
                    type: controller.inventoryType.value!,
                  ),
                ],
              );
            }),
          ),

          Obx(
            () => Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Get.theme.primaryColor.withAlpha(50),
                borderRadius: AppStyle.decoration.borderRadius,
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
            ),
          ),
        ],
      ),
    ),

    floatingActionButton: FloatingActionButton(
      backgroundColor: Get.theme.primaryColor,
      onPressed: () {
        controller.open();
      },
      child: const Icon(Icons.add),
    ),
  );

  Widget buildInventoryCategoryDropdown() => Expanded(
    child: Obx(
      () => Column(
        children: [
          InputCardStyle(
            child: DropdownButtonFormField<int>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Inventory Category'.tr,
                border: InputBorder.none,
              ),

              icon: const Icon(Icons.keyboard_arrow_down),
              initialValue: controller.selectedInventoryCategory.value,
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
                controller.setInventoryCategory(value!);
              },
            ),
          ),
          //  ErrorText(error: getErrorForField('vendor')),
        ],
      ),
    ),
  );

  Widget buildInventoryItemDropdown() => Expanded(
    child: Obx(
      () => InputCardStyle(
        child: DropdownButtonFormField<int>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Inventory Item'.tr,
            border: InputBorder.none,
          ),

          icon: const Icon(Icons.keyboard_arrow_down),
          initialValue: controller.selectedInventoryItem.value,
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
