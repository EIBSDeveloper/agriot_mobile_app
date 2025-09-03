import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/customer_add_controller/customer_add_controller.dart';
import '../../pages/payables_receivables/payables_receivables_screen.dart';

/*void showPaymentBottomSheet({
  required BuildContext context,
  required bool isPayable,
  required CustomerAddController controller,

  required int customerId,
  required String customerName,
  required double currentAmount,
  required int salesId,
}) {
  final dateController = TextEditingController();
  final amountController = TextEditingController();
  final descController = TextEditingController();
  controller.clearFiles(); // Clear previous files

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  isPayable
                      ? "Add Payable to $customerName"
                      : "Add Receivable from $customerName",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Current amount info
                Text(
                  isPayable
                      ? "Current Payable: ₹${currentAmount.toStringAsFixed(2)}"
                      : "Current Receivable: ₹${currentAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPayable ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 12),

                // Date picker
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Date",
                    labelStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.black54,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none, // removed black border
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.green,
                              onPrimary: Colors.white,
                              onSurface: Colors.black87,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Amount input
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Payment Amount",
                    labelStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Colors.black54,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none, // removed black border
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Description input
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(
                      Icons.description,
                      color: Colors.black54,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none, // removed black border
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // File upload for receivables
                if (!isPayable) ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      await controller.pickMultipleFiles();
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Document"),
                  ),
                  const SizedBox(height: 5),
                  Obx(
                    () => Column(
                      children:
                          controller.base64Files
                              .map(
                                (f) => ListTile(
                                  leading: const Icon(Icons.insert_drive_file),
                                  title: Text(f["fileName"] ?? "Document"),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (dateController.text.isEmpty ||
                          amountController.text.isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Please fill all required fields",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      try {
                        if (isPayable) {
                          await controller.addCustomerPayable(
                            customerId: customerId,
                            date: dateController.text,
                            saleId: salesId,
                            paymentAmount: amountController.text,
                            description: descController.text,
                          );
                        } else {
                          await controller.addCustomerReceivable(
                            customerId: customerId,
                            date: dateController.text,
                            saleId: salesId,
                            paymentAmount: amountController.text,
                            description: descController.text,
                            documents:
                                controller.base64Files
                                    .map((e) => e["base64"]!)
                                    .toList(),
                          );
                        }
                        Navigator.pop(ctx); // Close bottom sheet
                      } catch (e) {
                        Get.snackbar(
                          "Error",
                          e.toString(),
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}*/
void showPaymentBottomSheet({
  required BuildContext context,
  required bool isPayable,
  required CustomerAddController controller,
  required int customerId,
  required String customerName,
  required double currentAmount,
  required int salesId,
}) {
  final dateController = TextEditingController();
  final amountController = TextEditingController();
  final descController = TextEditingController();
  controller.clearFiles(); // Clear previous files
  // Set current date as default
  final now = DateTime.now();
  dateController.text =
      "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  isPayable
                      ? "add_payable".trParams({"name": customerName})
                      : "add_receivable".trParams({"name": customerName}),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Current amount info
                Text(
                  isPayable
                      ? "current_payable".trParams({
                        "amount": currentAmount.toStringAsFixed(2),
                      })
                      : "current_receivable".trParams({
                        "amount": currentAmount.toStringAsFixed(2),
                      }),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPayable ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 12),

                // Date picker
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "date".tr,
                    labelStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.black54,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.green,
                              onPrimary: Colors.white,
                              onSurface: Colors.black87,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Amount input
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "payment_amount".tr,
                    labelStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(
                      Icons.money_outlined,
                      color: Colors.black54,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Description input
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: "description".tr,
                    labelStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(
                      Icons.description,
                      color: Colors.black54,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // File upload for receivables
                if (!isPayable) ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      await controller.pickMultipleFiles();
                    },
                    icon: const Icon(Icons.upload_file),
                    label: Text("upload_document".tr),
                  ),
                  const SizedBox(height: 5),
                  Obx(
                    () => Column(
                      children:
                          controller.base64Files
                              .map(
                                (f) => ListTile(
                                  leading: const Icon(Icons.insert_drive_file),
                                  title: Text(f["fileName"] ?? "document".tr),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (dateController.text.isEmpty ||
                          amountController.text.isEmpty) {
                        Get.snackbar(
                          "error".tr,
                          "fill_required_fields".tr,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      try {
                        if (isPayable) {
                          await controller.addCustomerPayable(
                            customerId: customerId,
                            date: dateController.text,
                            saleId: salesId,
                            paymentAmount: amountController.text,
                            description: descController.text,
                          );
                          Get.back();
                          // Go to Customer → Payables tab
                          Get.to(
                            () => const PayablesReceivablesPage(
                              initialTab: 0,
                              initialsubtab: 0,
                            ),
                          );
                        } else {
                          await controller.addCustomerReceivable(
                            customerId: customerId,
                            date: dateController.text,
                            saleId: salesId,
                            paymentAmount: amountController.text,
                            description: descController.text,
                            documents:
                                controller.base64Files
                                    .map((e) => e["base64"]!)
                                    .toList(),
                          );
                          Get.back();

                          // Go to Customer → Receivables tab
                          Get.to(
                            () => const PayablesReceivablesPage(
                              initialTab: 0,
                              initialsubtab: 1,
                            ),
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          "error".tr,
                          e.toString(),
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "submit".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
