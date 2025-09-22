import 'package:argiot/src/app/modules/expense/controller/expense_controller.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../routes/app_routes.dart';
import '../../../../widgets/input_card_style.dart';

class AddExpenseScreen extends GetView<ExpenseController> {
  final _formKey = GlobalKey<FormState>();

  AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'Add Expenses'.tr),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Obx(() {
          if (controller.isLoading.value && controller.expenseTypes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              const SizedBox(height: 16),
              MyDropdown(
                items: controller.crop,
                selectedItem: controller.selectedCrop.value,
                onChanged: (crop) => controller.selectedCrop(crop!),
                label: "${'crop'.tr} ",
              ),
              const SizedBox(height: 16),
              InputCardStyle(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: DateFormat(
                      'dd/MM/yyyy',
                    ).format(controller.selectedDate.value),
                  ),
                  decoration: InputDecoration(
                    labelText: "${'Date'.tr} *",

                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Get.theme.primaryColor,
                    ),
                    border: InputBorder.none,
                  ),
                  onTap: () => controller.selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date'.tr;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => InputCardStyle(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButtonFormField<int>(
                          // validator: (value) => value == null ? 'required_field'.tr : null,
                          decoration: InputDecoration(
                            labelText: 'vendor'.tr,
                            border: InputBorder.none,
                          ),

                          icon: const Icon(Icons.keyboard_arrow_down),
                          initialValue: controller.selectedVendor.value,
                          onChanged: (value) =>
                              controller.selectedVendor.value = value,
                          items: controller.vendorList
                              .map(
                                (customer) => DropdownMenuItem<int>(
                                  value: customer.id,
                                  child: Text(customer.name),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    color: Get.theme.primaryColor,
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        Get.toNamed(
                          Routes.addVendorCustomer,
                          arguments: {"type": 'vendor'},
                        )?.then((result) {
                          controller.fetchVendorList();
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InputCardStyle(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "${'Amount'.tr} *",
                    // prefixText: ' ₹ ',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) =>
                      controller.amount(double.tryParse(value) ?? 0),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount'.tr;
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Please enter a valid amount'.tr;
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),
              InputCardStyle(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'description'.tr,
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                  ),
                  onChanged: controller.description.call,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    controller.submitExpense();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text('Save'.tr),
              ),
            ],
          );
        }),
      ),
    ),
  );
}
