import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../app/widgets/input_card_style.dart';
import '../../controller/customer_add_controller/customer_add_controller.dart';
import '../../pages/payables_receivables/payables_receivables_screen.dart';

void showPaymentBottomSheet({
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

  Get.bottomSheet(
    Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
      ),
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
              Center(
                child: Text(
                  isPayable
                      ? "add_payable".trParams({"name": customerName})
                      : "add_receivable".trParams({"name": customerName}),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // Current amount info
              Center(
                child: Text(
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
              ),
              const SizedBox(height: 12),

              // Date picker
              InputCardStyle(
                child: TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "date".tr,
                    labelStyle: const TextStyle(color: Colors.black54),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Get.theme.primaryColor,
                    ),
                   
                    border: InputBorder.none,
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(), // ✅ restrict future dates
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Get.theme.primaryColor,
                            onPrimary: Colors.white,
                            onSurface: Colors.black87,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Get.theme.primaryColor,
                            ),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Amount input
              InputCardStyle(
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "payment_amount".tr,
                    labelStyle: const TextStyle(color: Colors.black54),
                  
                    border: InputBorder.none
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Description input
              InputCardStyle(
                child: TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "description".tr,
                    labelStyle: const TextStyle(color: Colors.black54),
                    
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Documents section
              _buildDocumentsSection(controller),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (dateController.text.isEmpty ||
                        amountController.text.isEmpty ||
                        controller.documentItems.isEmpty) {
                      Fluttertoast.showToast(
                        msg: "All fields are required",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 14.0,
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
                        );
                      }

                      Get.back(); // ✅ close bottom sheet

                      Fluttertoast.showToast(
                        msg: "Payment successfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Get.theme.primaryColor,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );

                      // Navigate to Payables/Receivables page
                      Get.to(
                        () => PayablesReceivablesPage(
                          initialTab: 0,
                          initialsubtab: isPayable ? 0 : 1,
                        ),
                      );
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: e.toString(),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Get.theme.primaryColor,
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
    ),
    isScrollControlled: true,
  );
}

Widget _buildDocumentsSection(CustomerAddController controller) => Column(
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
