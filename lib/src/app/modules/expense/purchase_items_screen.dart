// lib/modules/expenses/models/expense_model.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../inventory/controller/inventory_controller.dart';
import '../near_me/views/widget/widgets.dart';

class PurchaseItemsScreen extends GetView<InventoryController> {
  const PurchaseItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Add New Expenses'.tr),
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
            padding: const EdgeInsets.all(16),
            children: [
              _buildInventoryItem(
                'fuel'.tr,
                '${inventory.fuel.totalQuantity} Ltr',
                onTap: () {
                  // Get.toNamed(Routes.fuelList);
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
                '${inventory.vehicle.totalFuelCapacity}',
                onTap: () {
                  Get.toNamed(
                    '/vehicle_entry',
                    arguments: {"id": inventory.vehicle.id},
                  )?.then((res) {
                    controller.loadInventory();
                  });
                },
              ),
              const Divider(),
              _buildInventoryItem(
                'machinery'.tr,
                '${inventory.machinery.totalFuelCapacity}',
                onTap: () {
                  Get.toNamed(
                    '/machinery_entry',
                    arguments: {"id": inventory.machinery.id},
                  )?.then((res) {
                    controller.loadInventory();
                  });
                },
              ),
              const Divider(),
              _buildInventoryItem(
                'tools'.tr,
                '${inventory.tools.totalQuantity}',
                onTap: () {
                  Get.toNamed(
                    '/fertilizer_entry',
                    arguments: {"id": inventory.tools.id},
                  )?.then((res) {
                    controller.loadInventory();
                  });
                },
              ),
              const Divider(),
              _buildInventoryItem(
                'pesticides'.tr,
                '${inventory.pesticides.totalQuantity} kg',
                onTap: () {
                  Get.toNamed(
                    '/fertilizer_entry',
                    arguments: {"id": inventory.pesticides.id},
                  )?.then((res) {
                    controller.loadInventory();
                  });
                },
              ),
              const Divider(),
              _buildInventoryItem(
                'fertilizers'.tr,
                '${inventory.fertilizers.totalQuantity} kg',
                onTap: () {
                  Get.toNamed(
                    '/fertilizer_entry',
                    arguments: {"id": inventory.fertilizers.id},
                  )?.then((res) {
                    controller.loadInventory();
                  });
                },
              ),
              const Divider(),
              _buildInventoryItem(
                'seeds'.tr,
                '${inventory.seeds.totalQuantity}',
                onTap: () {
                  Get.toNamed(
                    '/fertilizer_entry',
                    arguments: {"id": inventory.seeds.id},
                  )?.then((res) {
                    controller.loadInventory();
                  });
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInventoryItem(
    String title,
    String quantity, {
    Function()? onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Text('($quantity)'),
      onTap: onTap,
    );
  }
}
