import 'package:argiot/src/app/modules/inventory/controller/inventory_controller.dart';
import 'package:argiot/src/app/modules/inventory/model/inventory_list.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../widgets/loading.dart';

class InventoryOverview extends GetView<InventoryController> {
  const InventoryOverview({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: RefreshIndicator(
      onRefresh: () async {
        controller.loadInventoryItemList();
      },
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Loading();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        if (controller.inventoryItemList.value == null) {
          return Center(child: Text('no_inventory_data'.tr));
        }

        return ListView.separated(
          itemCount: controller.inventoryItemList.value!.length,
          itemBuilder: (context, index) {
            final item = controller.inventoryItemList.value![index];

            return Obx(
              () => InventoryListCard(
                isExpanded: controller.expandedLandId.value == item.id,
                type: item,
                onTap: () => controller.navigateToCategoryDetail(item.id),
                onExpand: () => controller.toggleExpandLand(item.id),
              ),
            );
          }, separatorBuilder: (BuildContext context, int index) => const Divider(),
        );
      }),
    ),
    floatingActionButton: controller.hasConsumption()
        ? FloatingActionButton(
            backgroundColor: Get.theme.primaryColor,
            onPressed: controller.navigateToAddInventory,
            child: const Icon(Icons.add),
          )
        : const SizedBox(),
  );
}

class InventoryListCard extends StatelessWidget {
  const InventoryListCard({
    super.key,
    required this.isExpanded,
    required this.type,
    required this.onTap,
    required this.onExpand,
  });
  final VoidCallback onTap;
  final VoidCallback onExpand;
  final bool isExpanded;
  final InventoryList type;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    color: !isExpanded
        ? Colors.white
        : (Get.theme.colorScheme.primary.withAlpha(50)),
    child: Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        type.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          // color: TEc
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${type.count})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 40,
                    color: Get.theme.primaryColor,
                  ),
                  onPressed: onExpand,
                ),
              ],
            ),
          ),
        ),

        if (type.count != 0 && isExpanded) ...[
          ...type.items!.map(
            (item) => InkWell(
              onTap: () {
                Get.toNamed(
                  Routes.consumptionPurchaseList,
                  arguments: {"id": type.id, 'tab': 0, 'item': item.id},
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: AppStyle.decoration.copyWith(boxShadow: []),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if(item.availableQuans!= 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${item.availableQuans} ${item.unitType}",
                        style: TextStyle(
                          color: Get.theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    ),
  );
}
