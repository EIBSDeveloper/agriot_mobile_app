import 'package:argiot/src/app/modules/expense/controller/consumption_controller.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../service/utils/enums.dart';
import '../../../widgets/loading.dart';
import '../../document/document.dart';

class ConsumptionView extends StatelessWidget {
  ConsumptionView({super.key});
  final ConsumptionController controller = Get.find<ConsumptionController>();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'consumption'.tr),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDatePicker(),

              const SizedBox(height: 16),
              _buildInventoryTypeDropdown(),
              const SizedBox(height: 16),
              _buildInventoryItemDropdown(),
              const SizedBox(height: 16),
              _buildCropDropdown(), const SizedBox(height: 16),
              Obx(
                () =>
                    controller.inventoryItemQuantity.value?.availableQuans !=
                        null
                    ? Text(
                        "Availability: ${controller.inventoryItemQuantity.value?.availableQuans ?? ''} ${controller.inventoryItemQuantity.value?.unitType ?? ""}",
                        style: Get.theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => !controller.requiresUsageHours
                    ? _buildQuantityField()
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => !controller.requiresUsageHours
                    ? const SizedBox(height: 16)
                    : const SizedBox.shrink(),
              ),

              // Conditional fields based on inventory type
              Obx(
                () => controller.requiresUsageHours
                    ? _buildUsageHoursField()
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => controller.requiresUsageHours
                    ? const SizedBox(height: 16)
                    : const SizedBox.shrink(),
              ),

              Obx(
                () => controller.requiresKilometerFields
                    ? _buildStartKilometerField()
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => controller.requiresKilometerFields
                    ? const SizedBox(height: 16)
                    : const SizedBox.shrink(),
              ),

              Obx(
                () => controller.requiresKilometerFields
                    ? _buildEndKilometerField()
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => controller.requiresKilometerFields
                    ? const SizedBox(height: 16)
                    : const SizedBox.shrink(),
              ),

              Obx(
                () => controller.requiresToolItems
                    ? _buildToolItemsField()
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => controller.requiresToolItems
                    ? const SizedBox(height: 16)
                    : const SizedBox.shrink(),
              ),

              const Divider(),
              _buildDocumentsSection(),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
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
    documentItems: controller.documentItems,
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
          text: controller.selectedDate.value.toLocal().toString().split(
            ' ',
          )[0],
        ),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: Get.context!,
            initialDate: controller.selectedDate.value,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null && picked != controller.selectedDate.value) {
            controller.setSelectedDate(picked);
          }
        },
      ),
    ),
  );

  Widget _buildCropDropdown() => Obx(
    () => MyDropdown(
      items: controller.crop,
      selectedItem: controller.selectedCropType.value,
      onChanged: (land) => controller.changeCrop(land!),
      label: "${'crop'.tr} *",
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
        initialValue: controller.selectedInventoryType.value,
        items: controller.inventoryTypes
            .map(
              (type) =>
                  DropdownMenuItem<int>(value: type.id, child: Text(type.name)),
            )
            .toList(),
        onChanged: (value) {
          controller.setInventoryType(value!);
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
        initialValue: controller.selectedInventoryItem.value,
        items: controller.inventoryItems
            .map(
              (item) =>
                  DropdownMenuItem<int>(value: item.id, child: Text(item.name)),
            )
            .toList(),
        onChanged: (value) => controller.selectedInventoryType.value != null
            ? controller.setInventoryItem(value!)
            : null,
      ),
    ),
  );

  Widget _buildQuantityField() {
    final availableQuans =
        controller.inventoryItemQuantity.value?.availableQuans;
    final enteredQuantity = int.tryParse(controller.quantity.value) ?? 0;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: InputCardStyle(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: "${'quantity'.tr} *",
                border: InputBorder.none,
              ),
              style: TextStyle(
                color:
                    (availableQuans != null && availableQuans < enteredQuantity)
                    ? Colors.red
                    : null,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'required_field'.tr;
                }

                if (availableQuans != null &&
                    availableQuans < enteredQuantity) {
                  return "${"please_enter_less_than".tr} $availableQuans";
                }

                return null; // Valid input
              },

              onChanged: controller.setQuantity,
            ),
          ),
        ),
        //              if(  _controller.requiresUnit) Expanded(
        // flex:2,
        //               child: child)
      ],
    );
  }

  Widget _buildUsageHoursField() => InputCardStyle(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: "${'usage_hours'.tr} *",
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
      onChanged: controller.setUsageHours,
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
      onChanged: controller.setStartKilometer,
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
      onChanged: controller.setEndKilometer,
    ),
  );

  Widget _buildToolItemsField() => InputCardStyle(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: 'tool_items'.tr,
        border: InputBorder.none,
      ),
      validator: (value) => value == null ? 'required_field'.tr : null,
      onChanged: controller.setToolItems,
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
      onChanged: controller.setDescription,
    ),
  );

  Widget _buildSaveButton() => Obx(
    () => ElevatedButton(
      onPressed: controller.isLoading.value
          ? null
          : () async {
              //  Obx(
              //   () =>
              //       controller.inventoryItemQuantity.value?.availableQuans !=
              //           null
              //       ? Text(
              //           "Availability: ${controller.inventoryItemQuantity.value?.availableQuans ?? ''} ${controller.inventoryItemQuantity.value?.unitType ?? ""}",
              //           style: Get.theme.textTheme.bodyMedium!.copyWith(
              //             fontWeight: FontWeight.bold,
              //           ),
              //         )
              //       : const SizedBox.shrink(),
              // );
              final success = await controller.submitConsumption();
              if (success) {
                Get
                  ..back(result: true)
                  ..toNamed(
                    Routes.consumptionPurchaseList,
                    arguments: {"id": controller.selectedInventoryType.value},
                    preventDuplicates: true,
                  );
              }
            },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: controller.isLoading.value
          ? const Loading(size:50)
          : Text('save'.tr),
    ),
  );
}
