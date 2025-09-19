import 'package:argiot/src/app/modules/expense/view/screens/consumption_list.dart';
import 'package:argiot/src/app/modules/expense/controller/consumption_purchase_controller.dart';
import 'package:argiot/src/app/modules/expense/view/screens/purchase_list.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConsumptionPurchaseView extends GetView<ConsumptionPurchaseController> {
  const ConsumptionPurchaseView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'inventory'.tr),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              buildInventoryTypeDropdown(),
              const SizedBox(width: 16),
              buildInventoryItemDropdown(),
            ],
          ),
        ),

        Obx(
          () => Container(
            color: Get.theme.colorScheme.surface,
            child: TabBar(
              controller: controller.tabController,
              tabs: [
                Tab(
                  text:
                      "${'consumption'.tr} (${controller.consumptionData.length})",
                ),
                Tab(
                  text: "${'purchase'.tr} (${controller.purchaseData.length})",
                ),
              ],
            ),
          ),
        ),
        Obx(
          () => Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withAlpha(50),
            ),
            padding: const EdgeInsets.only(
              right: 15,
              left: 15,
              bottom: 4,
              top: 4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    " Available ${controller.selectedInventoryItemName} ",
                    style: Get.theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "00 liter",
                  style: Get.theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // const Divider(),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value ||
                controller.selectedInventoryType.value == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              controller: controller.tabController,
              children: [
                ConsumptionList(
                  records: controller.consumptionData,
                  type: controller.selectedInventoryType.value!,
                  scrollController: controller.consumptionScrollController,
                  isLoadingMore: controller.isLoadingMoreConsumption.value,
                  hasMore: controller.hasMoreConsumption.value,
                ),
                PurchaseList(
                  records: controller.purchaseData,
                  type: controller.selectedInventoryType.value!,
                  scrollController: controller.purchaseScrollController,
                  isLoadingMore: controller.isLoadingMorePurchase.value,
                  hasMore: controller.hasMorePurchase.value,
                ),
              ],
            );
          }),
        ),

        // Bottom section (unchanged)
        // Obx(
        //   () => Container(
        //     height: 60,
        //     width: double.infinity,
        //     decoration: BoxDecoration(
        //       color: Get.theme.primaryColor.withAlpha(50),
        //       borderRadius: AppStyle.decoration.borderRadius,
        //     ),
        //     padding: const EdgeInsets.only(right: 80, left: 8),
        //     margin: const EdgeInsets.only(right: 8, bottom: 15, left: 10),
        //     child: Center(
        //       child: FittedBox(
        //         child: Text(
        //           " Available \n${controller.selectedInventoryItemName} : 00",
        //           style: Get.theme.textTheme.headlineMedium,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    ),

    floatingActionButton: FloatingActionButton(
      backgroundColor: Get.theme.primaryColor,
      onPressed: () {
        controller.open();
      },
      child: const Icon(Icons.add),
    ),
  );

  Widget buildInventoryTypeDropdown() => Expanded(
    child: Obx(
      () => Column(
        children: [
          InputCardStyle(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonFormField<int>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Inventory Type'.tr,
                border: InputBorder.none,
              ),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.keyboard_arrow_down),
              initialValue: controller.selectedInventoryType.value,
              items: controller.inventoryTypes
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
                controller.setInventoryType(value!);
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: DropdownButtonFormField<int>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Inventory Item'.tr,
            border: InputBorder.none,
          ),
          padding: EdgeInsets.zero,
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
          onChanged: (value) => controller.selectedInventoryType.value != null
              ? controller.setInventoryItem(value!)
              : null,
        ),
      ),
    ),
  );
}
