// lib/modules/expenses/models/expense_model.dart
import 'package:argiot/src/routes/app_routes.dart';
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
      body: Obx(() {
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
              onTap: (){
                Get.toNamed(Routes.fuelList);
              }
            ),
            const Divider(),
            _buildInventoryItem(
              'vehicle'.tr,
              '${inventory.vehicle.totalFuelCapacity}',
            ),
            const Divider(),
            _buildInventoryItem(
              'machinery'.tr,
              '${inventory.machinery.totalFuelCapacity}',
            ),
            const Divider(),
            _buildInventoryItem('tools'.tr, '${inventory.tools.totalQuantity}'),
            const Divider(),
            _buildInventoryItem(
              'pesticides'.tr,
              '${inventory.pesticides.totalQuantity} kg',
            ),
            const Divider(),
            _buildInventoryItem(
              'fertilizers'.tr,
              '${inventory.fertilizers.totalQuantity} kg',
            ),
            const Divider(),
            _buildInventoryItem('seeds'.tr, '${inventory.seeds.totalQuantity}'),
          ],
        );
      }),
    );
  }

  Widget _buildInventoryItem(String title, String quantity,{Function()? onTap}) {
    return ListTile(
      title: Text(title),
      trailing: Text('($quantity)'),
      onTap: onTap,
    );
  }
}
