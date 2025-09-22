import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/sales/controller/new_sales_controller.dart';
import 'package:argiot/src/app/modules/document/view/widget/documents_section.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../service/utils/enums.dart';
import '../../../../service/utils/pop_messages.dart';
import '../../../../service/utils/utils.dart';
import '../../../../routes/app_routes.dart';
import '../../../subscription/model/package_usage.dart';

class NewSalesView extends StatefulWidget {
  const NewSalesView({super.key});

  @override
  State<NewSalesView> createState() => _NewSalesViewState();
}

class _NewSalesViewState extends State<NewSalesView> {
  final NewSalesController controller = Get.find<NewSalesController>();

  @override
  void initState() {
    super.initState();
    controller.loadData();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: Get.arguments?["id"] != null ? 'new_sales'.tr : "",
      showBackButton: true,
    ),

    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDatePicker(),
              const SizedBox(height: 10),
              _buildProductDropdown(),
              const SizedBox(height: 10),
              _buildCustomerDropdown(),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _buildSalesQuantityField()),
                  const SizedBox(width: 10),
                  Expanded(child: _buildUnitDropdown()),
                ],
              ),
              const SizedBox(height: 10),

              _buildQuantityAmountField(),
              const SizedBox(height: 10),

              // Reactive sales amount display
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('sales_amount'.tr, style: Get.textTheme.bodyLarge),
                    Text(
                      "${controller.salesAmount.value}",
                      style: Get.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 16),

              _buildDeductionsSection(),

              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),

              // Reactive total sales amount display
              Obx(() {
                final total =
                    controller.salesAmount.value -
                    controller.deductionAmount.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'total_sales_amount'.tr,
                      style: Get.textTheme.bodyLarge,
                    ),
                    Text("$total", style: Get.textTheme.bodyLarge),
                  ],
                );
              }),

              const SizedBox(height: 10),
              _buildAmountPaidField(),
              const SizedBox(height: 10),

              // DocumentsSection already has internal Obx, so no extra here
              DocumentsSection(
                documentItems: controller.documentItems,
                type: DocTypes.sales,
              ),

              const SizedBox(height: 10),
              _buildDescriptionField(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    }),
  );

  Widget _buildProductDropdown() => Obx(
    () => MyDropdown(
      items: controller.crop,
      selectedItem: controller.selectedCropType.value,
      onChanged: (land) => controller.changeCrop(land!),
      label: "${'crop'.tr} *",
      // disable: isEditing,
    ),
  );

  Widget _buildCustomerDropdown() => Row(
    children: [
      Expanded(
        child: InputCardStyle(
          child: DropdownButtonFormField<int>(
            icon: const Icon(Icons.keyboard_arrow_down),
            decoration: InputDecoration(
              labelText: 'customer'.tr,
              border: InputBorder.none,
            ),
            initialValue: controller.selectedCustomer.value,
            onChanged: (value) => controller.selectedCustomer.value = value,
            items: controller.customerList
                .map(
                  (customer) => DropdownMenuItem<int>(
                    value: customer.id,
                    child: Text(customer.name),
                  ),
                )
                .toList(),
            validator: (value) =>
                value == null ? 'please_select_a_customer'.tr : null,
          ),
        ),
      ),
      Card(
        color: Get.theme.primaryColor,
        child: IconButton(
          color: Colors.white,
          onPressed: () async {
            PackageUsage? package = await findLimit();
            if (package!.customerBalance > 0) {
              Get.toNamed( Routes.addVendorCustomer)?.then((result) {
                controller.fetchCustomerList();
              });
            } else {
              showDefaultGetXDialog("vendor_customer".tr);
            }
          },
          icon: const Icon(Icons.add),
        ),
      ),
    ],
  );

  Widget _buildDatePicker() => InputCardStyle(
    child: InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: Get.context!,
          initialDate: controller.selectedDate.value,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (selected != null) {
          controller.selectedDate.value = selected;
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'date'.tr,
          border: InputBorder.none,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    ),
  );

  Widget _buildSalesQuantityField() => InputCardStyle(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: 'sales_quantity'.tr,
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
      initialValue:
          (controller.salesQuantity.value != 0
                  ? controller.salesQuantity.value
                  : '')
              .toString(),
      onChanged: (value) {
        controller.salesQuantity.value = int.tryParse(value);
        controller.salesAmount.value =
            (controller.quantityAmount.value * controller.salesQuantity.value!);
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'please_enter_quantity'.tr : null,
    ),
  );

  Widget _buildUnitDropdown() => Obx(
    () => MyDropdown(
      items: controller.unit,
      selectedItem: controller.selectedUnit.value,
      onChanged: (unit) => controller.changeUnit(unit!),
      label: 'unit'.tr,
      // disable: isEditing,
    ),
  );

  Widget _buildQuantityAmountField() => InputCardStyle(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: 'amount_per_unit'.tr,
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,

      initialValue:
          (controller.quantityAmount.value != 0
                  ? controller.quantityAmount.value
                  : '')
              .toString(),
      onChanged: (value) {
        controller.quantityAmount.value = int.tryParse(value)!;
        controller.salesAmount.value =
            (controller.quantityAmount.value * controller.salesQuantity.value!);
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'please_enter_amount'.tr : null,
    ),
  );

  Widget _buildDeductionsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'deductions'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Card(
            color: Get.theme.primaryColor,
            child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.add),
              onPressed: () => Get.toNamed(Routes.addDeduction),
            ),
          ),
        ],
      ),
      Obx(
        () => Column(
          children: controller.deductions
              .map(
                (deduction) => ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  minVerticalPadding: 0,
                  title: Text(
                    (deduction['new_reason'] ?? deduction['reason_name']) ?? '',
                  ),
                  subtitle: Text(
                    '${deduction['charges']} ${deduction['rupee'] == '1' ? '₹' : '%'}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Get.theme.primaryColor,
                    onPressed: () {
                      final index = controller.deductions.indexOf(deduction);
                      controller.removeDeduction(index);
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ),
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 16),
      Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('deduction_amount'.tr, style: Get.textTheme.bodyLarge),
            Text(
              controller.deductionAmount.value.toString(),
              style: Get.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildAmountPaidField() => InputCardStyle(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: 'amount_paid'.tr,
        border: InputBorder.none,
      ),
      initialValue: controller.amountPaid.value,
      keyboardType: TextInputType.number,
      onChanged: (value) => controller.amountPaid.value = value,
      validator: (value) =>
          value == null || value.isEmpty ? 'please_enter_amount_paid'.tr : null,
    ),
  );

  Widget _buildDescriptionField() => InputCardStyle(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: 'description'.tr,
        border: InputBorder.none,
      ),
      maxLines: 3,
      onChanged: (value) => controller.description.value = value,
    ),
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        controller.addSales();
      },
      child: Text('submit'.tr),
    ),
  );
}
