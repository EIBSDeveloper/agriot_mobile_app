// lib/app/modules/guidelines/models/inventory_model.dart

import 'package:argiot/src/app/modules/inventory/controller/inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AddInventory extends GetView<InventoryController> {
  const AddInventory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('add_inventory'.tr),
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.notifications),
          //   onPressed: () {},
          // ),
          // const CircleAvatar(
          //   child: Icon(Icons.person),
          // ),
          // const SizedBox(width: 10),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryItem('fuel'.tr, () {
          
          }),
          const Divider(),
          _buildCategoryItem('vehicle'.tr, () {}),
          const Divider(),
          _buildCategoryItem('machinery'.tr, () {}),
          const Divider(),
          _buildCategoryItem('tools'.tr, () {}),
          const Divider(),
          _buildCategoryItem('pesticides'.tr, () {}),
          const Divider(),
          _buildCategoryItem('fertilizers'.tr, () {}),
          const Divider(),
          _buildCategoryItem('seeds'.tr, () {}),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, Function()? onPressed) {
    return ListTile(
      title: Text(category),
      trailing: IconButton(
        icon: const Icon(Icons.add, color: Colors.green),
        onPressed: onPressed,
      ),
    );
  }

}
