// lib/modules/expenses/models/expense_model.dart
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/inventory_controller.dart';

class PurchaseItemsScreen extends GetView<InventoryController> {
  const PurchaseItemsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'Add New Purchase'.tr),
    body: RefreshIndicator(
      onRefresh: () async {
        controller.loadInventory();
      },
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final inventory = controller.inventory.value;
        if (inventory == null) {
          return Center(child: Text('no_inventory_data'.tr));
        }

        return ListView(
          children: [
            _buildInventoryItem(
              'fuel'.tr,
              '${inventory.fuel.totalQuantity.round()} Ltr',
              open: () {
                controller.navigateToCategoryDetail(
                  'fuel',
                  inventory.fuel.id,
                  tab: 1,
                );
              },
              onTap: () {
                Get.toNamed(
                  '/fuel-expenses-entry',
                  arguments: {"id": inventory.fuel.id},
                )?.then((res) {
                  controller.loadInventory();
                });
              },
            ),
            const Divider(),
            _buildInventoryItem(
              'vehicle'.tr,
              '${inventory.vehicle.totalFuelCapacity.round()}',
              open: () {
                controller.navigateToCategoryDetail(
                  'vehicle',
                  inventory.vehicle.id,
                  tab: 1,
                );
              },
              onTap: () {
                Get.toNamed(
                  '/vehicle_entry',
                  arguments: {"id": inventory.vehicle.id},
                )?.then((res) {
                  if (res ?? false) {
                    controller.loadInventory();
                  }
                });
              },
            ),
            const Divider(),
            _buildInventoryItem(
              'machinery'.tr,
              '${inventory.machinery.totalFuelCapacity.round()}',
              open: () {
                controller.navigateToCategoryDetail(
                  'machinery',
                  inventory.machinery.id,
                  tab: 1,
                );
              },
              onTap: () {
                Get.toNamed(
                  '/machinery_entry',
                  arguments: {"id": inventory.machinery.id},
                )?.then((res) {
                  if (res ?? false) {
                    controller.loadInventory();
                  }
                });
              },
            ),
            const Divider(),
            _buildInventoryItem(
              'tools'.tr,
              '${inventory.tools.totalQuantity.round()}',
              open: () {
                controller.navigateToCategoryDetail(
                  'tools',
                  inventory.tools.id,
                  tab: 1,
                );
              },
              onTap: () {
                Get.toNamed(
                  '/fertilizer_entry',
                  arguments: {"id": inventory.tools.id},
                )?.then((res) {
                  if (res ?? false) {
                    controller.loadInventory();
                  }
                });
              },
            ),
            const Divider(),
            _buildInventoryItem(
              'pesticides'.tr,
              '${inventory.pesticides.totalQuantity.round()} kg',
              open: () {
                controller.navigateToCategoryDetail(
                  'pesticides',
                  inventory.pesticides.id,
                  tab: 1,
                );
              },
              onTap: () {
                Get.toNamed(
                  '/fertilizer_entry',
                  arguments: {"id": inventory.pesticides.id},
                )?.then((res) {
                  if (res ?? false) {
                    controller.loadInventory();
                  }
                });
              },
            ),
            const Divider(),
            _buildInventoryItem(
              'fertilizers'.tr,
              '${inventory.fertilizers.totalQuantity.round()} kg',
              open: () {
                controller.navigateToCategoryDetail(
                  'fertilizers',
                  inventory.fertilizers.id,
                  tab: 1,
                );
              },
              onTap: () {
                Get.toNamed(
                  '/fertilizer_entry',
                  arguments: {"id": inventory.fertilizers.id},
                )?.then((res) {
                  if (res ?? false) {
                    controller.loadInventory();
                  }
                });
              },
            ),
            const Divider(),
            _buildInventoryItem(
              'seeds'.tr,
              '${inventory.seeds.totalQuantity.round()} kg',
              open: () {
                controller.navigateToCategoryDetail(
                  'seeds',
                  inventory.seeds.id,
                  tab: 1,
                );
              },
              onTap: () {
                Get.toNamed(
                  '/fertilizer_entry',
                  arguments: {"id": inventory.seeds.id},
                )?.then((res) {
                  if (res ?? false) {
                    controller.loadInventory();
                  }
                });
              },
            ),
          ],
        );
      }),
    ),
  );

  Widget _buildInventoryItem(
    String title,
    String quantity, {
    Function()? onTap,
    Function()? open,
  }) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title Text
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Quantity with tap handler (open)
          InkWell(
            onTap: open,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    '($quantity)  ',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.open_in_new, color: Colors.green.shade700),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
