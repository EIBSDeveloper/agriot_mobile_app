
import 'package:argiot/src/app/modules/sales/controller/new_sales_controller.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../near_me/views/widget/widgets.dart';
import '../../../../core/app_style.dart';
import '../../../routes/app_routes.dart';
class NewSalesView extends StatefulWidget {
  const NewSalesView({super.key});

  @override
  State<NewSalesView> createState() => _NewSalesViewState();
}

class _NewSalesViewState extends State<NewSalesView> {
  final NewSalesController controller = Get.find<NewSalesController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller.loadData();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'New Sales', showBackButton: true),

    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
              _buildDatePicker(),
              const SizedBox(height: 10),
              // Product Dropdown
              _buildProductDropdown(),
              const SizedBox(height: 10),

              // Customer Dropdown
              _buildCustomerDropdown(),
              const SizedBox(height: 10),

              // Sales Quantity
              Row(
                children: [
                  Expanded(child: _buildSalesQuantityField()),
                  const SizedBox(width: 10),

                  // Unit Dropdown
                  Expanded(child: _buildUnitDropdown()),
                ],
              ),
              const SizedBox(height: 10),

              // Quantity Amount
              _buildQuantityAmountField(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: Get.textTheme.bodyLarge),

                  Text(
                    "${controller.salesAmount.value}",
                    style: Get.textTheme.bodyLarge,
                  ),
                ],
              ),
              // // Sales Amount
              // _buildSalesAmountField(),
              const SizedBox(height: 10),
              const Divider(), const SizedBox(height: 16),

              // Deductions Section
              _buildDeductionsSection(),

              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),
              // Amount Paid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Net sale', style: Get.textTheme.bodyLarge),

                  Text(
                    "${controller.salesAmount.value - controller.deductionAmount.value}",
                    style: Get.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildAmountPaidField(),
              const SizedBox(height: 10),
              _buildDocumentsSection(), const SizedBox(height: 10),
              // Description
              _buildDescriptionField(),
              const SizedBox(height: 20),

              // Submit Button
              _buildSubmitButton(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    }),
  );

  Widget _buildDocumentsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Card(
            color: Get.theme.primaryColor,
            child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.add),
              onPressed: controller.addDocumentItem,
              tooltip: 'Add Document',
            ),
          ),
        ],
      ),
      Obx(() {
        if (controller.documentItems.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No documents added',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.documentItems.length,
          itemBuilder: (context, index) => Column(
            children: [
              const SizedBox(height: 5),
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        "${index + 1}, ${controller.documentItems[index].newFileType!}",
                      ),
                      const Icon(Icons.attach_file),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      controller.removeDocumentItem(index);
                    },
                    color: Get.theme.primaryColor,
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Divider(),
            ],
          ),
        );
      }),
    ],
  );
  Widget _buildProductDropdown() => Obx(
    () => MyDropdown(
      items: controller.crop,
      selectedItem: controller.selectedCropType.value,
      onChanged: (land) => controller.changeCrop(land!),
      label: 'Crop*',
      // disable: isEditing,
    ),
  );

  Widget _buildCustomerDropdown() => Row(
    children: [
      Expanded(
        child: InputCardStyle(
          child: DropdownButtonFormField<int>(
            icon: const Icon(Icons.keyboard_arrow_down),
            decoration: const InputDecoration(
              hintText: 'Customer * ',

              border: InputBorder.none,
            ),
            value: controller.selectedCustomer.value,
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
                value == null ? 'Please select a customer' : null,
          ),
        ),
      ),
      Card(
        color: Get.theme.primaryColor,
        child: IconButton(
          color: Colors.white,
          onPressed: () {
            Get.toNamed(
              '/add-vendor-customer',
              // arguments: {"type": 'vendor'},
            )?.then((result) {
              controller.fetchCustomerList();
            });
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
        decoration: const InputDecoration(
          hintText: 'Date',
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
      decoration: const InputDecoration(
        hintText: 'Sales Quantity',
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
      initialValue: controller.salesQuantity.value.toString(),
      onChanged: (value) {
        controller.salesQuantity.value = int.tryParse(value);
        controller.salesAmount.value =
            (controller.quantityAmount.value * controller.salesQuantity.value!);
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter quantity' : null,
    ),
  );

  Widget _buildUnitDropdown() => Obx(
    () => MyDropdown(
      items: controller.unit,
      selectedItem: controller.selectedUnit.value,
      onChanged: (unit) => controller.changeUnit(unit!),
      label: 'Unit*',
      // disable: isEditing,
    ),
  );

  Widget _buildQuantityAmountField() => InputCardStyle(
    child: TextFormField(
      decoration: const InputDecoration(
        hintText: 'Amount per unit*',
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
      initialValue: controller.quantityAmount.value.toString(),
      onChanged: (value) {
        controller.quantityAmount.value = int.tryParse(value)!;
        controller.salesAmount.value =
            (controller.quantityAmount.value * controller.salesQuantity.value!);
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter amount' : null,
    ),
  );

  Widget _buildDeductionsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Deductions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  title: Text(
                    (deduction['new_reason'] ?? deduction['reason_name']) ?? '',
                  ),
                  subtitle: Text(
                    '${deduction['charges']} ${deduction['rupee'] == '1' ? '₹' : '%'}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
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
            Text('Total Deduction:', style: Get.textTheme.bodyLarge),
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
      decoration: const InputDecoration(
        hintText: 'Amount Paid*',
        border: InputBorder.none,
      ),
      initialValue: controller.amountPaid.value,
      keyboardType: TextInputType.number,
      onChanged: (value) => controller.amountPaid.value = value,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter amount paid' : null,
    ),
  );

  Widget _buildDescriptionField() => Container(
    decoration: AppStyle.decoration.copyWith(
      color: const Color.fromARGB(137, 221, 234, 234),
      boxShadow: const [],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

    child: TextFormField(
      decoration: const InputDecoration(
        hintText: 'Description',
        border: InputBorder.none,
      ),
      maxLines: 3,
      onChanged: (value) => controller.description.value = value,
    ),
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          final success = await controller.addSales();
          if (success) {
            Get.back();
          }
        }
      },
      child: const Text('Submit'),
    ),
  );
}
