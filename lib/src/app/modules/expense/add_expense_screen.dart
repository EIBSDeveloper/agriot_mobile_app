import 'package:argiot/src/app/modules/expense/expense_controller.dart';
import 'package:argiot/src/app/modules/expense/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/app_style.dart';
import '../task/view/screens/screen.dart';

class AddExpenseScreen extends GetView<ExpenseController> {
  final _formKey = GlobalKey<FormState>();

  AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('Add New Expenses'.tr),
      ),
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
                  label: 'Crop*'.tr,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: AppStyle.decoration.copyWith(
                    color: const Color.fromARGB(137, 221, 234, 234),
                    boxShadow: const [],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  height: 55,
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: DateFormat(
                        'dd/MM/yyyy',
                      ).format(controller.selectedDate.value),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Date*'.tr,
                      suffixIcon: const Icon(Icons.calendar_today),
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
                Container(
                  decoration: AppStyle.decoration.copyWith(
                    color: const Color.fromARGB(137, 221, 234, 234),
                    boxShadow: const [],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    // vertical: 5,
                  ),
                  height: 55,
                  child: DropdownButtonFormField<ExpenseType>(
                    value: controller.selectedExpenseType.value.id == 0
                        ? null
                        : controller.selectedExpenseType.value,
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
                      hintText: 'Type of Expense*'.tr,
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
                Container(
                  decoration: AppStyle.decoration.copyWith(
                    color: const Color.fromARGB(137, 221, 234, 234),
                    boxShadow: const [],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  height: 55,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Amount*'.tr,
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

                const SizedBox(height: 16),
                Container(
                  decoration: AppStyle.decoration.copyWith(
                    color: const Color.fromARGB(137, 221, 234, 234),
                    boxShadow: const [],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  child: TextFormField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText : 'description'.tr,
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
