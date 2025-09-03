
import 'package:argiot/consumption_controller.dart';

import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/modules/task/view/screens/screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'src/app/widgets/input_card_style.dart';

// consumption_view.dart
class ConsumptionView extends StatelessWidget {
  final ConsumptionController _controller = Get.find<ConsumptionController>();

  ConsumptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Consumption'.tr),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDatePicker(),
              SizedBox(height: 16),
              _buildCropDropdown(),
              
              SizedBox(height: 16),
              _buildInventoryTypeDropdown(),
              SizedBox(height: 16),
              _buildInventoryCategoryDropdown(),
              SizedBox(height: 16),
              _buildInventoryItemDropdown(),
              SizedBox(height: 16),
              _buildQuantityField(),
              SizedBox(height: 16),
              // Conditional fields based on inventory type
              Obx(() => _controller.requiresUsageHours ? _buildUsageHoursField() : SizedBox.shrink()),
              Obx(() => _controller.requiresUsageHours ? SizedBox(height: 16) : SizedBox.shrink()),
              
              Obx(() => _controller.requiresKilometerFields ? _buildStartKilometerField() : SizedBox.shrink()),
              Obx(() => _controller.requiresKilometerFields ? SizedBox(height: 16) : SizedBox.shrink()),
              
              Obx(() => _controller.requiresKilometerFields ? _buildEndKilometerField() : SizedBox.shrink()),
              Obx(() => _controller.requiresKilometerFields ? SizedBox(height: 16) : SizedBox.shrink()),
              
              Obx(() => _controller.requiresToolItems ? _buildToolItemsField() : SizedBox.shrink()),
              Obx(() => _controller.requiresToolItems ? SizedBox(height: 16) : SizedBox.shrink()),
              
              _buildDescriptionField(),
              SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Obx(
      () => InputCardStyle(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: 'Date'.tr,
            border: InputBorder.none,
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          controller: TextEditingController(
            text: _controller.selectedDate.value.toLocal().toString().split(' ')[0],
          ),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: Get.context!,
              initialDate: _controller.selectedDate.value,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null && picked != _controller.selectedDate.value) {
              _controller.setSelectedDate(picked);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCropDropdown() {
    return Obx(() {
      return MyDropdown(
        items: _controller.crop,
        selectedItem: _controller.selectedCropType.value,
        onChanged: (land) => _controller.changeCrop(land!),
        label: 'crop'.tr,
      );
    });
  }

  Widget _buildInventoryTypeDropdown() {
    return Obx(
      () => InputCardStyle(
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            hintText: 'Inventory Type'.tr,
            border: InputBorder.none,
          ),
          value: _controller.selectedInventoryType.value,
          items: _controller.inventoryTypes
              .map(
                (type) => DropdownMenuItem<int>(
                  value: type.id,
                  child: Text(type.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            _controller.setInventoryType(value!);
            _controller.fetchInventoryCategories(value);
          },
        ),
      ),
    );
  }

  Widget _buildInventoryCategoryDropdown() {
    return Obx(
      () => InputCardStyle(
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            hintText: 'Inventory Category'.tr,
            border: InputBorder.none,
          ),
          value: _controller.selectedInventoryCategory.value,
          items: _controller.inventoryCategories
              .map(
                (category) => DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                ),
              )
              .toList(),
          onChanged: _controller.selectedInventoryType.value != null
              ? (value) {
                  _controller.setInventoryCategory(value!);
                  _controller.fetchInventoryItems(value);
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildInventoryItemDropdown() {
    return Obx(
      () => InputCardStyle(
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            hintText: 'Inventory Item'.tr,
            border: InputBorder.none,
          ),
          value: _controller.selectedInventoryItem.value,
          items: _controller.inventoryItems
              .map(
                (item) => DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(item.name),
                ),
              )
              .toList(),
          onChanged: (value) =>
              _controller.selectedInventoryCategory.value != null
              ? _controller.setInventoryItem(value!)
              : null,
        ),
      ),
    );
  }

  Widget _buildQuantityField() {
    return InputCardStyle(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Quantity'.tr,
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
        onChanged: _controller.setQuantity,
      ),
    );
  }

  Widget _buildUsageHoursField() {
    return InputCardStyle(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Usage Hours'.tr,
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
        onChanged: _controller.setUsageHours,
      ),
    );
  }

  Widget _buildStartKilometerField() {
    return InputCardStyle(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Start Kilometer'.tr,
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
        onChanged: _controller.setStartKilometer,
      ),
    );
  }

  Widget _buildEndKilometerField() {
    return InputCardStyle(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'End Kilometer'.tr,
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
        onChanged: _controller.setEndKilometer,
      ),
    );
  }

  Widget _buildToolItemsField() {
    return InputCardStyle(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Tool Items'.tr,
          border: InputBorder.none,
        ),
        onChanged: _controller.setToolItems,
      ),
    );
  }

  Widget _buildDescriptionField() {
    return InputCardStyle(
      noHeight: true,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Description'.tr,
          border: InputBorder.none,
        ),
        maxLines: 3,
        onChanged: _controller.setDescription,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(
      () => ElevatedButton(
        onPressed: _controller.isLoading.value
            ? null
            : () async {
                final success = await _controller.submitConsumption();
                if (success) {
                  Get.back();
                }
              },
        style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
        child: _controller.isLoading.value
            ? CircularProgressIndicator()
            : Text('Save'.tr),
      ),
    );
  }
}