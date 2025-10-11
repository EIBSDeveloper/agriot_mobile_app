import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/payable/pages/payables_receivables/payables_receivables_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/modules/expense/view/widgets/month_day_format.dart';
import '../../../app/widgets/loading.dart';
import '../../controller/vendor_add_controller/vendor_add_controller.dart';
import '../../controller/vendorcontroller/vendorcontroller.dart';
import '../../model/vendor/vendor_purchase_model.dart';
import '../../repository/vendor_add_repository/vendor_add_repository.dart';
import '../../repository/vendor_repository/vendor_repository.dart';
import 'vendor_historydetails.dart';

class VendorPurchasePage extends StatelessWidget {
  final int vendorId;
  final bool isPayable;

  const VendorPurchasePage({
    super.key,
    required this.vendorId,
    required this.isPayable,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      VendorPurchaseController(repository: VendorPurchaseRepository()),
    );

    final vendorAddController = Get.put(
      VendorAddController(repository: VendorAddRepository()),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPayable) {
        controller.loadVendorPayables(vendorId);
      } else {
        controller.loadVendorReceivables(vendorId);
      }
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: isPayable ? 'vendor_payables'.tr : 'vendor_receivables'.tr,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Loading();
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        // Use the full vendor object directly
        final vendor = isPayable
            ? controller.vendorPayables.value
            : controller.vendorReceivables.value;

        if (vendor == null) {
          return Center(
            child: Text(
              isPayable ? 'no_vendor_payables'.tr : 'no_vendor_receivables'.tr,
            ),
          );
        }

        return _buildVendorDetails(
          context,
          vendor,
          isPayable,
          vendorAddController,
        );
      }),
    );
  }

  Widget _buildVendorDetails(
    BuildContext context,
    Vendormodel vendor,
    bool isPayable,
    VendorAddController controller,
  ) => SingleChildScrollView(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vendor Info
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: vendor.vendorImage.isNotEmpty
                  ? NetworkImage(vendor.vendorImage)
                  : const AssetImage('assets/images/store_placeholder.png')
                        as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vendor.businessName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Purchases / Expenses
        Column(
          children: vendor.expenses
              .map(
                (expense) => _buildPurchaseTile(
                  context,
                  expense,
                  isPayable,
                  controller,
                  vendorId: vendor.id,
                ),
              )
              .toList(),
        ),
      ],
    ),
  );

  Widget _buildPurchaseTile(
    BuildContext context,
    Expense expense,
    bool isPayable,
    VendorAddController controller, {
    required int vendorId,
  }) => Card(
    margin: const EdgeInsets.symmetric(vertical: 6),
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MonthDayFormat(date: DateFormat("dd-MM-yyyy").parse(expense.date)),
          const SizedBox(width: 10), // Purchase info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "${'total'.tr}: ₹${expense.totalAmount}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isPayable)
                  Text(
                    "${'to_pay'.tr}: ₹${expense.toAmount}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                if (!isPayable)
                  Text(
                    "${'received'.tr}: ₹${expense.receivedAmount}",
                    style: const TextStyle(fontSize: 14),
                  ),
              ],
            ),
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Get.theme.colorScheme.primary,
                  size: 28,
                ),
                onPressed: () {
                  showAddVendorPaymentBottomSheet(
                    vendorId: vendorId,
                    isPayable: isPayable,
                    type: "expense",
                    // replace with actual type if available
                    controller: controller,
                    fuelPurchaseId: expense.id,
                  );
                },
              ),

              IconButton(
                icon: const Icon(Icons.history, color: Colors.red, size: 26),
                onPressed: () {
                  Get.to(
                    () => VendorHistoryPage(
                      expenseId: expense.id,
                      isPayable:
                          isPayable, // true for payables, false for receivables
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
  void showAddVendorPaymentBottomSheet({
    required int vendorId,
    required bool isPayable,
    required VendorAddController controller,
    required int fuelPurchaseId,
    required String type,
  }) {
    final formKey = GlobalKey<FormState>();
    final dateController = TextEditingController();
    final amountController = TextEditingController();
    final descController = TextEditingController();

    controller.clearFiles();

    // Default date = today
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
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    isPayable
                        ? "add_vendor_payable".tr
                        : "add_vendor_receivable".tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Picker (Mandatory)
                  InputCardStyle(
                    child: TextFormField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            text: "Date",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: " *",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        hintText: "dd_mm_yyyy",
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: Get.theme.primaryColor,
                        ),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a date";
                        }
                        return null;
                      },
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: Get.context!,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Get.theme.primaryColor,
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

                  // Amount (Mandatory)
                  InputCardStyle(
                    child: TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            text: "Payment Amount",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: " *",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter payment amount";
                        }
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0) {
                          return "Enter a valid amount";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description (Optional)
                  InputCardStyle(
                    child: TextFormField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Description (Optional)",
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Documents (Optional)
                  _buildDocumentsSection(controller),

                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final date = dateController.text;
                        final amount =
                            double.tryParse(amountController.text) ?? 0;
                        final desc = descController.text;

                        try {
                          if (isPayable) {
                            await controller.addVendorPayable(
                              vendorId: vendorId,
                              fuelPurchaseId: fuelPurchaseId,
                              date: date,
                              amount: amount,
                              type: type,
                              description: desc,
                            );

                            Get.back();

                            Fluttertoast.showToast(
                              msg: "Payment successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Get.theme.primaryColor,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );

                            Get.to(
                              () => const PayablesReceivablesPage(
                                initialTab: 1,
                                initialsubtab: 0,
                              ),
                            );
                          } else {
                            await controller.addVendorReceivable(
                              vendorId: vendorId,
                              fuelPurchaseId: fuelPurchaseId,
                              date: date,
                              amount: amount,
                              type: type,
                              description: desc,
                            );

                            Get.back();

                            Fluttertoast.showToast(
                              msg: "Payment successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Get.theme.primaryColor,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );

                            Get.to(
                              () => const PayablesReceivablesPage(
                                initialTab: 1,
                                initialsubtab: 1,
                              ),
                            );
                          }
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
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDocumentsSection(VendorAddController controller) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Documents (Optional)',
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
                  Text(
                    "${index + 1}. ${controller.documentItems[index].newFileType!}",
                  ),
                  const Icon(Icons.attach_file),
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
              const Divider(),
            ],
          ),
        );
      }),
    ],
  );
}
