import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/customer_add_controller/customer_add_controller.dart';

/*
void showPaymentDialog(
  BuildContext context,
  bool isPayable,
  CustomerAddController controller,
  int farmerId,
  int customerId,
  String customerName,
  double currentAmount,
  int salesId,
) {
  final dateController = TextEditingController();
  final amountController = TextEditingController();
  final descController = TextEditingController();
  controller.clearFiles(); // Clear previous files

  print("Opening Payment Dialog");
  print("Sale ID: $salesId");
  print("Farmer ID: $farmerId");
  print("Customer ID: $customerId");
  print("Customer Name: $customerName");
  print("Amount: $currentAmount");

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          isPayable
              ? "Add Payable to $customerName"
              : "Add Receivable from $customerName",
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 10),

              // Date input
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: "Date (dd-MM-yyyy)",
                ),
              ),

              // Amount input
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: "Payment Amount"),
                keyboardType: TextInputType.number,
              ),

              // Description input
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),

              // File upload for receivables
              if (!isPayable) ...[
                const SizedBox(height: 10),
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
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          */
/*ElevatedButton(
            onPressed: () async {
              if (dateController.text.isEmpty ||
                  amountController.text.isEmpty) {
                Get.snackbar("Error", "Please fill all required fields");
                return;
              }

              try {
                if (isPayable) {
                  await controller.addCustomerPayable(
                    farmerId: farmerId,
                    customerId: customerId,
                    date: dateController.text,
                    saleId: salesId,
                    paymentAmount: amountController.text,
                    description: descController.text,
                  );
                } else {
                  await controller.addCustomerReceivable(
                    farmerId: farmerId,
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
              } catch (e) {
                print("❌ Submit Error: $e");
                Get.snackbar("Error", e.toString());
              } finally {
                Navigator.pop(context);
              }
            },
            child: const Text("Submit"),
          ),*/ /*

          ElevatedButton(
            onPressed: () async {
              if (dateController.text.isEmpty ||
                  amountController.text.isEmpty) {
                Get.snackbar("Error", "Please fill all required fields");
                return;
              }

              try {
                if (isPayable) {
                  await controller.addCustomerPayable(
                    farmerId: farmerId,
                    customerId: customerId,
                    date: dateController.text,
                    saleId: salesId,
                    paymentAmount: amountController.text,
                    description: descController.text,
                  );
                } else {
                  await controller.addCustomerReceivable(
                    farmerId: farmerId,
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
                // Close the dialog first
                Navigator.pop(context);
              } catch (e) {
                print("❌ Submit Error: $e");
                Get.snackbar("Error", e.toString());
              }
            },
            child: const Text("Submit"),
          ),
        ],
      );
    },
  );
}
*/
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
}
