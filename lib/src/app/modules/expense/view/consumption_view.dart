import 'package:argiot/src/app/modules/expense/controller/consumption_controller.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../service/utils/enums.dart';
import '../../document/document.dart';
class ConsumptionView extends StatelessWidget {
  ConsumptionView({super.key});
  final ConsumptionController _controller = Get.find<ConsumptionController>();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'consumption'.tr),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _controller.formKey,
          child: Column(
            children: [
              _buildDatePicker(),

              const SizedBox(height: 16),
              _buildInventoryTypeDropdown(),
              const SizedBox(height: 16),
              _buildInventoryItemDropdown(),
              const SizedBox(height: 16),
              _buildCropDropdown(), const SizedBox(height: 16),
              Obx(
                () => !_controller.requiresUsageHours
                    ? _buildQuantityField()
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => !_controller.requiresUsageHours
                    ? const SizedBox(height: 16)
                    : const SizedBox.shrink(),
              ),

              // Conditional fields based on inventory type
              Obx(
                () => _controller.requiresUsageHours
                    ? _buildUsageHoursField()
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => _controller.requiresUsageHours
                    ? const SizedBox(height: 16)
                    : const SizedBox.shrink(),
              ),

              Obx(
                () => _controller.requiresKilometerFields
                    ? _buildStartKilometerField()
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => _controller.requiresKilometerFields
                    ? const SizedBox(height: 16)
                    : const SizedBox.shrink(),
              ),

              Obx(
                () => _controller.requiresKilometerFields
                    ? _buildEndKilometerField()
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => _controller.requiresKilometerFields
                    ? const SizedBox(height: 16)
                    : const SizedBox.shrink(),
              ),

              Obx(
                () => _controller.requiresToolItems
                    ? _buildToolItemsField()
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => _controller.requiresToolItems
                    ? const SizedBox(height: 16)
                    : const SizedBox.shrink(),
              ),

              const Divider(),
              _buildDocumentsSection(),
              const SizedBox(height: 24),
              const Divider(),
              _buildDescriptionField(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _buildDocumentsSection() => DocumentsSection(
    documentItems: _controller.documentItems,
    type: DocTypes.inventory,
  );

  Widget _buildDatePicker() => Obx(
    () => InputCardStyle(
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'date'.tr,
          border: InputBorder.none,
          suffixIcon: Icon(Icons.calendar_today, color: Get.theme.primaryColor),
        ),
        readOnly: true,
        controller: TextEditingController(
          text: _controller.selectedDate.value.toLocal().toString().split(
            ' ',
          )[0],
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

  Widget _buildCropDropdown() => Obx(
    () => MyDropdown(
      items: _controller.crop,
      selectedItem: _controller.selectedCropType.value,
      onChanged: (land) => _controller.changeCrop(land!),
      label: 'crop'.tr,
    ),
  );

  Widget _buildInventoryTypeDropdown() => Obx(
    () => InputCardStyle(
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: "${'inventory_type'.tr} *",
          border: InputBorder.none,
        ),

        icon: const Icon(Icons.keyboard_arrow_down),
        validator: (value) => value == null ? 'required_field'.tr : null,
        initialValue: _controller.selectedInventoryType.value,
        items: _controller.inventoryTypes
            .map(
              (type) =>
                  DropdownMenuItem<int>(value: type.id, child: Text(type.name)),
            )
            .toList(),
        onChanged: (value) {
          _controller.setInventoryType(value!);
        },
      ),
    ),
  );

 
  Widget _buildInventoryItemDropdown() => Obx(
    () => InputCardStyle(
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: "${'inventory_item'.tr} *",
          border: InputBorder.none,
        ),

        icon: const Icon(Icons.keyboard_arrow_down),
        validator: (value) => value == null ? 'required_field'.tr : null,
        initialValue: _controller.selectedInventoryItem.value,
        items: _controller.inventoryItems
            .map(
              (item) =>
                  DropdownMenuItem<int>(value: item.id, child: Text(item.name)),
            )
            .toList(),
        onChanged: (value) =>
            _controller.selectedInventoryType.value != null
            ? _controller.setInventoryItem(value!)
            : null,
      ),
    ),
  );

  Widget _buildQuantityField() => Row(
    children: [
      Expanded(
        flex: 3,
        child: InputCardStyle(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: "${'quantity'.tr} *",
              border: InputBorder.none,
            ),

            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'required_field'.tr : null,
            onChanged: _controller.setQuantity,
          ),
        ),
      ),
      //              if(  _controller.requiresUnit) Expanded(
      // flex:2,
      //               child: child)
    ],
  );

  Widget _buildUsageHoursField() => InputCardStyle(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: "${'usage_hours'.tr} *",
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
      onChanged: _controller.setUsageHours,
    ),
  );

  Widget _buildStartKilometerField() => InputCardStyle(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: "${'start_kilometer'.tr} *",
        border: InputBorder.none,
      ),
      validator: (value) => value == null ? 'required_field'.tr : null,
      keyboardType: TextInputType.number,
      onChanged: _controller.setStartKilometer,
    ),
  );

  Widget _buildEndKilometerField() => InputCardStyle(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: "${'end_kilometer'.tr} *",
        border: InputBorder.none,
      ),
      validator: (value) => value == null ? 'required_field'.tr : null,
      keyboardType: TextInputType.number,
      onChanged: _controller.setEndKilometer,
    ),
  );

  Widget _buildToolItemsField() => InputCardStyle(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: 'tool_items'.tr,
        border: InputBorder.none,
      ),
      validator: (value) => value == null ? 'required_field'.tr : null,
      onChanged: _controller.setToolItems,
    ),
  );

  Widget _buildDescriptionField() => InputCardStyle(
    noHeight: true,
    child: TextFormField(
      decoration: InputDecoration(
        labelText: 'description'.tr,
        border: InputBorder.none,
      ),
      maxLines: 3,
      onChanged: _controller.setDescription,
    ),
  );

  Widget _buildSaveButton() => Obx(
    () => ElevatedButton(
      onPressed: _controller.isLoading.value
          ? null
          : () async {
              final success = await _controller.submitConsumption();
              if (success) {
                Get
                  ..back(result: true)
                  ..toNamed(
                    '/consumption-purchase',
                    arguments: {"id": _controller.selectedInventoryType.value},
                    preventDuplicates: true,
                  );
              }
            },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: _controller.isLoading.value
          ? const CircularProgressIndicator()
          : Text('save'.tr),
    ),
  );
}