// lib/app/modules/guidelines/models/inventory_model.dart

import 'package:argiot/src/app/modules/inventory/controller/inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/title_text.dart';

class InventoryOverview extends GetView<InventoryController> {
  const InventoryOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TitleText( "inventory".tr,fit: BoxFit.none,),
            ),
            SizedBox(height: 10,),
            _buildInventoryItem(
              'fuel'.tr,
              '${inventory.fuel.totalQuantity} Ltr',
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Get.theme.primaryColor,
        onPressed: controller.navigateToAddInventory,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInventoryItem(String title, String quantity) {
    return ListTile(
      title: Text(title),
      trailing: Text('($quantity)'),
      onTap: () => controller.navigateToCategoryDetail(title.toLowerCase()),
    );
  }
}
