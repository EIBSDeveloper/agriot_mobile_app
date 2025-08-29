
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

    // Call load methods after first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPayable) {
        controller.loadVendorPayables( vendorId);
      } else {
        controller.loadVendorReceivables( vendorId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isPayable ? 'Vendor Payables' : 'Vendor Receivables'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final vendorList =
            isPayable
                ? controller.vendorPayables
                : controller.vendorReceivables;

        if (vendorList.isEmpty) {
          return Center(
            child: Text(
              isPayable
                  ? 'No vendor payables found.'
                  : 'No vendor receivables found.',
            ),
          );
        }

        final vendor = vendorList.first;
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
    VendorPayable vendor,
    bool isPayable,
    VendorAddController controller,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading:
                vendor.vendorImage.isNotEmpty
                    ? CircleAvatar(
                      backgroundImage: NetworkImage(vendor.vendorImage),
                    )
                    : const CircleAvatar(child: Icon(Icons.store)),
            title: Text(
              vendor.vendorName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            subtitle: Text(vendor.businessName),
          ),
          const SizedBox(height: 16),

          buildSection(
            context,
            'Fuel ${isPayable ? 'Purchases' : 'Receivables'}',
            vendor.fuelPurchases,
            isPayable,
            controller,
            isReceivable: !isPayable,
          ),

          buildSection(
            context,
            'Seed ${isPayable ? 'Purchases' : 'Receivables'}',
            vendor.seedPurchases,
            isPayable,
            controller,
            isReceivable: !isPayable,
          ),

          buildSection(
            context,
            'Pesticide ${isPayable ? 'Purchases' : 'Receivables'}',
            vendor.pesticidePurchases,
            isPayable,
            controller,
            isReceivable: !isPayable,
          ),

          buildSection(
            context,
            'Fertilizer ${isPayable ? 'Purchases' : 'Receivables'}',
            vendor.fertilizerPurchases,
            isPayable,
            controller,
            isReceivable: !isPayable,
          ),

          buildSection(
            context,
            'Vehicle ${isPayable ? 'Purchases' : 'Receivables'}',
            vendor.vehiclePurchases,
            isPayable,
            controller,
            isReceivable: !isPayable,
          ),

          buildSection(
            context,
            'Machinery ${isPayable ? 'Purchases' : 'Receivables'}',
            vendor.machineryPurchases,
            isPayable,
            controller,
            isReceivable: !isPayable,
          ),

          buildSection(
            context,
            'Tool ${isPayable ? 'Purchases' : 'Receivables'}',
            vendor.toolPurchases,
            isPayable,
            controller,
            isReceivable: !isPayable,
          ),
        ],
      ),
    );
  }

  Widget buildSection(
    BuildContext context,
    String title,
    List<dynamic>? items,
    bool isPayable,
    VendorAddController controller, {
    bool isReceivable = false,
  }) {
    return (items == null || items.isEmpty)
        ? SizedBox()
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...items.map<Widget>(
              (item) =>
                  _buildPurchaseTile(context, item, isPayable, controller),
            ),
            const SizedBox(height: 16),
          ],
        );
  }

  /*  Widget _buildPurchaseTile(
    BuildContext context,
    Purchase purchase,
    bool isPayable,
    VendorAddController controller,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          '${purchase.inventoryItem} (${purchase.inventoryType}) - ${purchase.purchaseDate}',
        ),
        subtitle: Text(
          'Total: ₹${purchase.totalPurchaseAmount.toStringAsFixed(2)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPayable)
              Text(
                'To Pay: ₹${purchase.topayAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: () {
                showAddVendorPaymentBottomSheet(
                  context: context,
                  farmerId: farmerId,
                  vendorId: vendorId,
                  isPayable: isPayable,
                  type: purchase.inventoryType,
                  controller: controller,
                  fuelPurchaseId: purchase.id,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.history, color: Colors.blue),
              onPressed: () {
                Get.to(
                  () => VendorHistoryPage(
                    userId: farmerId,
                    vendorId: vendorId,
                    type: purchase.inventoryType,
                    fuelId: purchase.id,
                    isPayable: isPayable,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }*/
  Widget _buildPurchaseTile(
    BuildContext context,
    Purchase purchase,
    bool isPayable,
    VendorAddController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withAlpha(80),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag,
              color: Get.theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Middle Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${purchase.inventoryItem} (${purchase.inventoryType})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${purchase.purchaseDate}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ₹${purchase.totalPurchaseAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                if (isPayable) ...[
                  const SizedBox(height: 4),
                  Text(
                    'To Pay: ₹${purchase.topayAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Trailing Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCircleIcon(
                icon: Icons.add,
                bgColor: Colors.grey.shade100,
                iconColor: Colors.black,
                onTap: () {
                  showAddVendorPaymentBottomSheet(
                    context: context,
                    vendorId: vendorId,
                    isPayable: isPayable,
                    type: purchase.inventoryType,
                    controller: controller,
                    fuelPurchaseId: purchase.id,
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildCircleIcon(
                icon: Icons.history,
                bgColor: Colors.grey.shade100,
                iconColor: Colors.red,
                onTap: () {
                  Get.to(
                    () => VendorHistoryPage(
                      vendorId: vendorId,
                      type: purchase.inventoryType,
                      fuelId: purchase.id,
                      isPayable: isPayable,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reusable circle icon button
  Widget _buildCircleIcon({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}

void showAddVendorPaymentBottomSheet({
  required BuildContext context,

  required int vendorId,
  required bool isPayable,
  required VendorAddController controller,
  required int fuelPurchaseId,
  required String type,
}) {
  final dateController = TextEditingController();
  final amountController = TextEditingController();
  final descController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // resizes with keyboard
    backgroundColor: Colors.transparent, // for rounded corners effect
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isPayable ? "Add Vendor Payable" : "Add Vendor Receivable",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date",
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintText: "DD-MM-YYYY",
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // removed black border
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
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

              // Amount
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // removed black border
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // removed black border
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final date = dateController.text;
                    final amount = double.tryParse(amountController.text) ?? 0;
                    final desc = descController.text;

                    if (date.isEmpty || amount == 0 || desc.isEmpty) {
                      Get.snackbar(
                        "Error",
                        "All fields are required",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    if (isPayable) {
                      controller.addVendorPayable(
                       
                        vendorId: vendorId,
                        fuelPurchaseId: fuelPurchaseId,
                        date: date,
                        amount: amount,
                        type: type,
                        description: desc,
                      );
                    } else {
                      controller.addVendorReceivable(
                       
                        vendorId: vendorId,
                        fuelPurchaseId: fuelPurchaseId,
                        date: date,
                        amount: amount,
                        type: type,
                        description: desc,
                      );
                    }

                    Navigator.of(ctx).pop();
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
