import 'package:argiot/src/app/modules/expense/controller/expense_controller.dart';
import 'package:argiot/src/app/modules/expense/model/expense_type.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/input_card_style.dart';

class AddExpenseScreen extends GetView<ExpenseController> {
  final _formKey = GlobalKey<FormState>();

  AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'Add New Expenses'.tr),
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
                label: "${'crop'.tr} *",
              ),
              const SizedBox(height: 16),
             InputCardStyle(
               
                child: TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: DateFormat(
                      'dd/MM/yyyy',
                    ).format(controller.selectedDate.value),
                  ),
                  decoration: InputDecoration(
                    labelText: "${'Date'.tr} *",
                    
                    suffixIcon:  Icon(Icons.calendar_today,color: Get.theme.primaryColor,),
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
              InputCardStyle(
               
                child: DropdownButtonFormField<ExpenseType>(
                  initialValue: controller.selectedExpenseType.value.id == 0
                      ? null
                      : controller.selectedExpenseType.value,

                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: controller.expenseTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        ),
                      )
                      .toList(),
                  onChanged: (type) => controller.selectedExpenseType(type!),
                  decoration: InputDecoration(
                    labelText: "${'Type of Expense'.tr}  *",
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an expense type'.tr;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
            InputCardStyle(
               
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
