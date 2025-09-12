/*import 'package:argiot/src/payable/pages/customer_vendor/vendorreceivableshistory.dart';
import 'package:argiot/src/payable/repository/customer_add_repository/customer_add_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/customer_add_controller/customer_add_controller.dart';
import '../../controller/customer_vendor_controller/customer_vendor_controller.dart';
import '../../controller/vendor_add_controller/vendor_add_controller.dart';
import '../../model/customer_vendor_model/customer_vendor_model.dart';
import '../../repository/customer_vendor_repository/customer_vendor_repository.dart';
import '../../repository/vendor_add_repository/vendor_add_repository.dart';
import '../payables_receivables/payables_receivables_screen.dart';
import 'historydetailspage.dart';

enum DetailsType { payables, receivables }

class CustomerVendorDetailsPage extends StatefulWidget {
  final int id;
  final DetailsType? detailsType;

  CustomerVendorDetailsPage({
    super.key,
    required this.id,
    required this.detailsType,
  });

  @override
  State<CustomerVendorDetailsPage> createState() =>
      _CustomerVendorDetailsPageState();
}

class _CustomerVendorDetailsPageState extends State<CustomerVendorDetailsPage> {
  final controller = Get.put(
    CustomerVendorController(repository: CustomerVendorRepository()),
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadReceivables(widget.id, widget.detailsType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer & Vendor Details')),
      body: Obx(() {
        if (controller.isLoading.value)
          return Center(child: CircularProgressIndicator());
        if (controller.error.isNotEmpty)
          return Center(child: Text('Error: ${controller.error.value}'));

        final vendorReceivables = controller.vendorReceivables;
        final customerReceivables = controller.customerReceivables;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= Receivables =================
              if (widget.detailsType == DetailsType.receivables) ...[
                // Vendor Section
                if (vendorReceivables.isNotEmpty) ...[
                  Text(
                    'Vendor Receivables',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...vendorReceivables
                      .map((vendor) => buildVendorReceivables(vendor))
                      .toList(),
                ],

                // Customer Section
                if (customerReceivables.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'Customer Receivables',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...customerReceivables.map((customer) {
                    return buildSalesreceivableList(
                      customer.sales,
                      customer.customerId,
                      customer.customerName,
                    );
                  }).toList(),
                ],
              ],

              // ================= Payables =================
              if (widget.detailsType == DetailsType.payables) ...[
                if (vendorReceivables.isNotEmpty) ...[
                  Text(
                    "Vendor Payables",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...vendorReceivables
                      .map((vendor) => buildVendorPayables(vendor))
                      .toList(),
                ],

                if (customerReceivables.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    "Customer Payables",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...customerReceivables.map((customer) {
                    return buildSalesPayableList(
                      customer.sales,
                      customer.customerId,
                      customer.customerName,
                    );
                  }).toList(),
                ],
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget buildPremiumCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildVendorReceivables(VendorReceivable vendor) {
    final vendorAddController = Get.put(
      VendorAddController(repository: VendorAddRepository()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            vendor.vendorImage.isNotEmpty
                ? Image.network(
                  vendor.vendorImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
                : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: Icon(Icons.person, size: 40),
                ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.vendorName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(vendor.businessName),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),

        // Fuel
        ...vendor.fuelReceivables.map(
          (f) => buildReceivableCard(
            title: "Fuel Purchase",
            inventoryItem: f.inventoryItem,
            inventoryType: f.inventoryType,
            total: f.totalPurchaseAmount,
            paid: f.amountPaid,
            received: f.receivedAmount,
            toReceive: f.toReceiveAmount,
            onAddPayment: () {
              print("Opening Add Payment Bottom Sheet");
              print("vendorId: ${vendor.vendorId}");
              print("fuelPurchaseId: ${f.fuelPurchaseId}");
              print("type: ${f.inventoryType}");
              print("isPayable: false");
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: f.fuelPurchaseId,
                type: f.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: f.fuelPurchaseId,
                  type: f.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Seed
        ...vendor.seedReceivables.map(
          (s) => buildReceivableCard(
            title: "Seed Purchase",
            inventoryItem: s.inventoryItem,
            inventoryType: s.inventoryType,
            total: s.totalPurchaseAmount,
            paid: s.amountPaid,
            received: s.receivedAmount,
            toReceive: s.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: s.seedPurchaseId,
                type: s.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: s.seedPurchaseId,
                  type: s.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Fertilizer
        ...vendor.fertilizerReceivables.map(
          (f) => buildReceivableCard(
            title: "Fertilizer Purchase",
            inventoryItem: f.inventoryItem,
            inventoryType: f.inventoryType,
            total: f.totalPurchaseAmount,
            paid: f.amountPaid,
            received: f.receivedAmount,
            toReceive: f.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: f.fertilizerPurchaseId,
                type: f.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: f.fertilizerPurchaseId,
                  type: f.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Pesticide
        ...vendor.pesticideReceivables.map(
          (p) => buildReceivableCard(
            title: "Pesticide Purchase",
            inventoryItem: p.inventoryItem,
            inventoryType: p.inventoryType,
            total: p.totalPurchaseAmount,
            paid: p.amountPaid,
            received: p.receivedAmount,
            toReceive: p.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: p.pesticidePurchaseId,
                type: p.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: p.pesticidePurchaseId,
                  type: p.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Vehicle
        ...vendor.vehicleReceivables.map(
          (v) => buildReceivableCard(
            title: "Vehicle Purchase",
            inventoryItem: v.inventoryItem,
            inventoryType: v.inventoryType,
            total: v.totalPurchaseAmount,
            paid: v.amountPaid,
            received: v.receivedAmount,
            toReceive: v.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: v.vehiclePurchaseId,
                type: v.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: v.vehiclePurchaseId,
                  type: v.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Machinery
        ...vendor.machineryReceivables.map(
          (m) => buildReceivableCard(
            title: "Machinery Purchase",
            inventoryItem: m.inventoryItem,
            inventoryType: m.inventoryType,
            total: m.totalPurchaseAmount,
            paid: m.amountPaid,
            received: m.receivedAmount,
            toReceive: m.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: m.machineryPurchaseId,
                type: m.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: m.machineryPurchaseId,
                  type: m.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Tools
        ...vendor.toolReceivables.map(
          (t) => buildReceivableCard(
            title: "Tool Purchase",
            inventoryItem: t.inventoryItem,
            inventoryType: t.inventoryType,
            total: t.totalPurchaseAmount,
            paid: t.amountPaid,
            received: t.receivedAmount,
            toReceive: t.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: t.toolPurchaseId,
                type: t.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: t.toolPurchaseId,
                  type: t.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildVendorPayables(VendorReceivable vendor) {
    final vendorAddController = Get.put(
      VendorAddController(repository: VendorAddRepository()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            vendor.vendorImage.isNotEmpty
                ? Image.network(
                  vendor.vendorImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
                : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: Icon(Icons.person, size: 40),
                ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.vendorName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(vendor.businessName),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),

        // Example for fuel payables
        ...vendor.fuelReceivables.map(
          (f) => buildReceivableCard(
            title: "Fuel Purchase (Payable)",
            inventoryItem: f.inventoryItem,
            inventoryType: f.inventoryType,
            total: f.totalPurchaseAmount,
            paid: f.amountPaid,
            received: f.receivedAmount,
            toReceive: f.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: true, // 🔑 mark as payable
                controller: vendorAddController,
                fuelPurchaseId: f.fuelPurchaseId,
                type: f.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: f.fuelPurchaseId,
                  type: f.inventoryType,
                  isPayable: true,
                ),
              );
            },
          ),
        ),
        // repeat for seed, fertilizer, etc. just like receivables
      ],
    );
  }

  // ------------------ VENDOR PURCHASES ------------------
  Widget buildReceivableCard({
    required String title,
    required String inventoryItem,
    required String inventoryType,
    required double total,
    required double paid,
    required double received,
    required double toReceive,
    required VoidCallback? onAddPayment,
    required VoidCallback? onHistory,
  }) {
    return buildPremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$title:", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.red),
                    onPressed: onAddPayment,
                  ),
                  IconButton(
                    icon: Icon(Icons.history, color: Colors.grey),
                    onPressed: onHistory,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(inventoryItem),
          SizedBox(height: 8),
          Text(
            "Inventory: $inventoryItem ($inventoryType)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: ₹$total",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Paid: ₹$paid", style: TextStyle(color: Colors.green)),
            ],
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Received: ₹$received",
                style: TextStyle(color: Colors.blue),
              ),
              Text(
                "To Receive: ₹$toReceive",
                style: TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------ CUSTOMER SALES ------------------
  Widget buildSalesreceivableList(
    List<Sale> sales,
    int customerId,
    String customerName,
  ) {
    if (sales.isEmpty) return SizedBox.shrink();
    final customerAddController = Get.put(
      CustomerAddController(repository: CustomerAddRepository()),
    );

    return Column(
      children:
          sales.map((sale) {
            return buildPremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with date & icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sales Date:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.blue),
                            onPressed: () {
                              showAddcustomerBottomSheet(
                                isPayable: false,
                                controller: customerAddController,
                                customerId: customerId,
                                customerName: customerName,
                                currentAmount: sale.totalSalesAmount,
                                salesId: sale.salesId,
                                context: Get.context!,
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.history, color: Colors.grey),
                            onPressed: () {
                              Get.to(
                                () => HistoryDetailsPage(
                                  farmerId: 339,
                                  customerId: customerId,
                                  saleId: sale.salesId,
                                  isPayable: false,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(sale.salesDate),
                  SizedBox(height: 8),
                  Text(
                    "Crop: ${sale.cropName}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: ₹${sale.totalSalesAmount}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Paid: ₹${sale.amountPaid}",
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Received: ₹${sale.receivedAmount}",
                        style: TextStyle(color: Colors.blue),
                      ),
                      Text(
                        "To Pay: ₹${sale.toPayAmount}",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget buildSalesPayableList(
    List<Sale> sales,
    int customerId,
    String customerName,
  ) {
    if (sales.isEmpty) return SizedBox.shrink();
    final customerAddController = Get.put(
      CustomerAddController(repository: CustomerAddRepository()),
    );

    return Column(
      children:
          sales.map((sale) {
            return buildPremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sales Date:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.red),
                            onPressed: () {
                              showAddcustomerBottomSheet(
                                isPayable: true, // 🔑 mark as payable
                                controller: customerAddController,
                                customerId: customerId,
                                customerName: customerName,
                                currentAmount: sale.totalSalesAmount,
                                salesId: sale.salesId,
                                context: Get.context!,
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.history, color: Colors.grey),
                            onPressed: () {
                              Get.to(
                                () => HistoryDetailsPage(
                                  farmerId: 339,
                                  customerId: customerId,
                                  saleId: sale.salesId,
                                  isPayable: true,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(sale.salesDate),
                  SizedBox(height: 8),
                  Text(
                    "Crop: ${sale.cropName}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: ₹${sale.totalSalesAmount}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Paid: ₹${sale.amountPaid}",
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Received: ₹${sale.receivedAmount}",
                        style: TextStyle(color: Colors.blue),
                      ),
                      Text(
                        "To Pay: ₹${sale.toPayAmount}",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // ------------------ BUILD PAGE ------------------
}*/
import 'package:argiot/src/payable/pages/customer_vendor/vendorreceivableshistory.dart';
import 'package:argiot/src/payable/repository/customer_add_repository/customer_add_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/service/utils/enums.dart';
import '../../controller/customer_add_controller/customer_add_controller.dart';
import '../../controller/customer_vendor_controller/customer_vendor_controller.dart';
import '../../controller/vendor_add_controller/vendor_add_controller.dart';
import '../../model/customer_vendor_model/customer_vendor_model.dart';
import '../../repository/customer_vendor_repository/customer_vendor_repository.dart';
import '../../repository/vendor_add_repository/vendor_add_repository.dart';
import '../payables_receivables/payables_receivables_screen.dart';
import 'historydetailspage.dart';



class CustomerVendorDetailsPage extends StatefulWidget {

  final DetailsTypes? detailsType;

const  CustomerVendorDetailsPage({
    super.key,
    required this.detailsType,
  });

  @override
  State<CustomerVendorDetailsPage> createState() =>
      _CustomerVendorDetailsPageState();
}

class _CustomerVendorDetailsPageState extends State<CustomerVendorDetailsPage> {
  final controller = Get.put(
    CustomerVendorController(repository: CustomerVendorRepository()),
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadReceivables(widget.detailsType);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text('Customer & Vendor Details'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.isNotEmpty) {
          return Center(
            child: Text('${'Error:'.tr} ${controller.error.value}'),
          );
        }

        final vendorReceivables = controller.vendorReceivables;
        final customerReceivables = controller.customerReceivables;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= Receivables =================
              if (widget.detailsType == DetailsTypes.receivables) ...[
                if (vendorReceivables.isNotEmpty) ...[
                  Text(
                    'Vendor Receivables'.tr,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...vendorReceivables
                      .map((vendor) => buildVendorReceivables(vendor))
                      ,
                ],
                if (customerReceivables.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Customer Receivables'.tr,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...customerReceivables.map((customer) => buildSalesreceivableList(
                      customer.sales,
                      customer.customerId,
                      customer.customerName,
                    )),
                ],
              ],

              // ================= Payables =================
              if (widget.detailsType == DetailsTypes.payables) ...[
                if (vendorReceivables.isNotEmpty) ...[
                  Text(
                    "Vendor Payables".tr,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...vendorReceivables
                      .map((vendor) => buildVendorPayables(vendor))
                      ,
                ],
                if (customerReceivables.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    "Customer Payables".tr,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...customerReceivables.map((customer) => buildSalesPayableList(
                      customer.sales,
                      customer.customerId,
                      customer.customerName,
                    )),
                ],
              ],
            ],
          ),
        );
      }),
    );

  Widget buildPremiumCard({required Widget child}) => Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(150),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

  Widget buildVendorReceivables(VendorReceivable vendor) {
    final vendorAddController = Get.put(
      VendorAddController(repository: VendorAddRepository()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            vendor.vendorImage.isNotEmpty
                ? Image.network(
                  vendor.vendorImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
                : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 40),
                ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.vendorName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(vendor.businessName),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Fuel
        ...vendor.fuelReceivables.map(
          (f) => buildReceivableCard(
            title: "Fuel Purchase".tr,
            inventoryItem: f.inventoryItem,
            inventoryType: f.inventoryType,
            total: f.totalPurchaseAmount,
            paid: f.amountPaid,
            received: f.receivedAmount,
            toReceive: f.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: f.fuelPurchaseId,
                type: f.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: f.fuelPurchaseId,
                  type: f.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),
        // Fuel
        ...vendor.fuelReceivables.map(
          (f) => buildReceivableCard(
            title: "Fuel Purchase".tr,
            inventoryItem: f.inventoryItem,
            inventoryType: f.inventoryType,
            total: f.totalPurchaseAmount,
            paid: f.amountPaid,
            received: f.receivedAmount,
            toReceive: f.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: f.fuelPurchaseId,
                type: f.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: f.fuelPurchaseId,
                  type: f.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Seed
        ...vendor.seedReceivables.map(
          (s) => buildReceivableCard(
            title: "Seed Purchase".tr,
            inventoryItem: s.inventoryItem,
            inventoryType: s.inventoryType,
            total: s.totalPurchaseAmount,
            paid: s.amountPaid,
            received: s.receivedAmount,
            toReceive: s.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: s.seedPurchaseId,
                type: s.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: s.seedPurchaseId,
                  type: s.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Fertilizer
        ...vendor.fertilizerReceivables.map(
          (f) => buildReceivableCard(
            title: "Fertilizer Purchase".tr,
            inventoryItem: f.inventoryItem,
            inventoryType: f.inventoryType,
            total: f.totalPurchaseAmount,
            paid: f.amountPaid,
            received: f.receivedAmount,
            toReceive: f.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: f.fertilizerPurchaseId,
                type: f.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: f.fertilizerPurchaseId,
                  type: f.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Pesticide
        ...vendor.pesticideReceivables.map(
          (p) => buildReceivableCard(
            title: "Pesticide Purchase".tr,
            inventoryItem: p.inventoryItem,
            inventoryType: p.inventoryType,
            total: p.totalPurchaseAmount,
            paid: p.amountPaid,
            received: p.receivedAmount,
            toReceive: p.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: p.pesticidePurchaseId,
                type: p.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: p.pesticidePurchaseId,
                  type: p.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Vehicle
        ...vendor.vehicleReceivables.map(
          (v) => buildReceivableCard(
            title: "Vehicle Purchase".tr,
            inventoryItem: v.inventoryItem,
            inventoryType: v.inventoryType,
            total: v.totalPurchaseAmount,
            paid: v.amountPaid,
            received: v.receivedAmount,
            toReceive: v.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: v.vehiclePurchaseId,
                type: v.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: v.vehiclePurchaseId,
                  type: v.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Machinery
        ...vendor.machineryReceivables.map(
          (m) => buildReceivableCard(
            title: "Machinery Purchase".tr,
            inventoryItem: m.inventoryItem,
            inventoryType: m.inventoryType,
            total: m.totalPurchaseAmount,
            paid: m.amountPaid,
            received: m.receivedAmount,
            toReceive: m.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: m.machineryPurchaseId,
                type: m.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: m.machineryPurchaseId,
                  type: m.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Tools
        ...vendor.toolReceivables.map(
          (t) => buildReceivableCard(
            title: "Tools Purchase".tr,
            inventoryItem: t.inventoryItem,
            inventoryType: t.inventoryType,
            total: t.totalPurchaseAmount,
            paid: t.amountPaid,
            received: t.receivedAmount,
            toReceive: t.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: t.toolPurchaseId,
                type: t.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: t.toolPurchaseId,
                  type: t.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // repeat: Seed, Fertilizer, Pesticide, Vehicle, Machinery, Tools...
      ],
    );
  }

  Widget buildVendorPayables(VendorReceivable vendor) {
    final vendorAddController = Get.put(
      VendorAddController(repository: VendorAddRepository()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            vendor.vendorImage.isNotEmpty
                ? Image.network(
                  vendor.vendorImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
                : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 40),
                ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.vendorName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(vendor.businessName),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...vendor.fuelReceivables.map(
          (f) => buildReceivableCard(
            title: "Fuel Purchase (Payable)".tr,
            inventoryItem: f.inventoryItem,
            inventoryType: f.inventoryType,
            total: f.totalPurchaseAmount,
            paid: f.amountPaid,
            received: f.receivedAmount,
            toReceive: f.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: true,
                controller: vendorAddController,
                fuelPurchaseId: f.fuelPurchaseId,
                type: f.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: f.fuelPurchaseId,
                  type: f.inventoryType,
                  isPayable: true,
                ),
              );
            },
          ),
        ),

        // Seed
        ...vendor.seedReceivables.map(
          (s) => buildReceivableCard(
            title: "Seed Purchase".tr,
            inventoryItem: s.inventoryItem,
            inventoryType: s.inventoryType,
            total: s.totalPurchaseAmount,
            paid: s.amountPaid,
            received: s.receivedAmount,
            toReceive: s.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: s.seedPurchaseId,
                type: s.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: s.seedPurchaseId,
                  type: s.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Fertilizer
        ...vendor.fertilizerReceivables.map(
          (f) => buildReceivableCard(
            title: "Fertilizer Purchase".tr,
            inventoryItem: f.inventoryItem,
            inventoryType: f.inventoryType,
            total: f.totalPurchaseAmount,
            paid: f.amountPaid,
            received: f.receivedAmount,
            toReceive: f.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: f.fertilizerPurchaseId,
                type: f.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: f.fertilizerPurchaseId,
                  type: f.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Pesticide
        ...vendor.pesticideReceivables.map(
          (p) => buildReceivableCard(
            title: "Pesticide Purchase".tr,
            inventoryItem: p.inventoryItem,
            inventoryType: p.inventoryType,
            total: p.totalPurchaseAmount,
            paid: p.amountPaid,
            received: p.receivedAmount,
            toReceive: p.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: p.pesticidePurchaseId,
                type: p.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: p.pesticidePurchaseId,
                  type: p.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Vehicle
        ...vendor.vehicleReceivables.map(
          (v) => buildReceivableCard(
            title: "Vehicle Purchase".tr,
            inventoryItem: v.inventoryItem,
            inventoryType: v.inventoryType,
            total: v.totalPurchaseAmount,
            paid: v.amountPaid,
            received: v.receivedAmount,
            toReceive: v.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: v.vehiclePurchaseId,
                type: v.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: v.vehiclePurchaseId,
                  type: v.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Machinery
        ...vendor.machineryReceivables.map(
          (m) => buildReceivableCard(
            title: "Machinery Purchase".tr,
            inventoryItem: m.inventoryItem,
            inventoryType: m.inventoryType,
            total: m.totalPurchaseAmount,
            paid: m.amountPaid,
            received: m.receivedAmount,
            toReceive: m.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: m.machineryPurchaseId,
                type: m.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: m.machineryPurchaseId,
                  type: m.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),

        // Tools
        ...vendor.toolReceivables.map(
          (t) => buildReceivableCard(
            title: "Tools Purchase".tr,
            inventoryItem: t.inventoryItem,
            inventoryType: t.inventoryType,
            total: t.totalPurchaseAmount,
            paid: t.amountPaid,
            received: t.receivedAmount,
            toReceive: t.toReceiveAmount,
            onAddPayment: () {
              showAddVendorPaymentBottomSheet(
                context: Get.context!,
                vendorId: vendor.vendorId,
                isPayable: false,
                controller: vendorAddController,
                fuelPurchaseId: t.toolPurchaseId,
                type: t.inventoryType,
              );
            },
            onHistory: () {
              Get.to(
                () => VendorHistoryPage(
                  vendorId: vendor.vendorId,
                  purchaseId: t.toolPurchaseId,
                  type: t.inventoryType,
                  isPayable: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildReceivableCard({
    required String title,
    required String inventoryItem,
    required String inventoryType,
    required double total,
    required double paid,
    required double received,
    required double toReceive,
    required VoidCallback? onAddPayment,
    required VoidCallback? onHistory,
  }) => buildPremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$title:", style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.red),
                    onPressed: onAddPayment,
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.grey),
                    onPressed: onHistory,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(inventoryItem),
          const SizedBox(height: 8),
          Text(
            "${'Inventory:'.tr} $inventoryItem ($inventoryType)",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${'Total:'.tr} ₹$total",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "${'Paid:'.tr} ₹$paid",
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${'Received:'.tr} ₹$received",
                style: const TextStyle(color: Colors.blue),
              ),
              Text(
                "${'To Receive:'.tr} ₹$toReceive",
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );

  Widget buildSalesreceivableList(
    List<Sale> sales,
    int customerId,
    String customerName,
  ) {
    if (sales.isEmpty) return const SizedBox.shrink();
    final customerAddController = Get.put(
      CustomerAddController(repository: CustomerAddRepository()),
    );

    return Column(
      children:
          sales.map((sale) => buildPremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sales Date:".tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.blue),
                            onPressed: () {
                              showAddcustomerBottomSheet(
                                isPayable: false,
                                controller: customerAddController,
                                customerId: customerId,
                                customerName: customerName,
                                currentAmount: sale.totalSalesAmount,
                                salesId: sale.salesId,
                                context: Get.context!,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.history, color: Colors.grey),
                            onPressed: () {
                              Get.to(
                                () => HistoryDetailsPage(
                               
                                  customerId: customerId,
                                  saleId: sale.salesId,
                                  isPayable: false,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(sale.salesDate),
                  const SizedBox(height: 8),
                  Text(
                    "${'Crop:'.tr} ${sale.cropName}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${'Total:'.tr} ₹${sale.totalSalesAmount}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${'Paid:'.tr} ₹${sale.amountPaid}",
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${'Received:'.tr} ₹${sale.receivedAmount}",
                        style: const TextStyle(color: Colors.blue),
                      ),
                      Text(
                        "${'To Pay:'.tr} ₹${sale.toPayAmount}",
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ],
              ),
            )).toList(),
    );
  }

  Widget buildSalesPayableList(
    List<Sale> sales,
    int customerId,
    String customerName,
  ) {
    if (sales.isEmpty) return const SizedBox.shrink();
    final customerAddController = Get.put(
      CustomerAddController(repository: CustomerAddRepository()),
    );

    return Column(
      children:
          sales.map((sale) => buildPremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sales Date:".tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.red),
                            onPressed: () {
                              showAddcustomerBottomSheet(
                                isPayable: true,
                                controller: customerAddController,
                                customerId: customerId,
                                customerName: customerName,
                                currentAmount: sale.totalSalesAmount,
                                salesId: sale.salesId,
                                context: Get.context!,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.history, color: Colors.grey),
                            onPressed: () {
                              Get.to(
                                () => HistoryDetailsPage(
                            
                                  customerId: customerId,
                                  saleId: sale.salesId,
                                  isPayable: true,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(sale.salesDate),
                  const SizedBox(height: 8),
                  Text(
                    "${'Crop:'.tr} ${sale.cropName}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${'Total:'.tr} ₹${sale.totalSalesAmount}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${'Paid:'.tr} ₹${sale.amountPaid}",
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${'Received:'.tr} ₹${sale.receivedAmount}",
                        style: const TextStyle(color: Colors.blue),
                      ),
                      Text(
                        "${'To Pay:'.tr} ₹${sale.toPayAmount}",
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ],
              ),
            )).toList(),
    );
  }
}

/*void showAddVendorPaymentBottomSheet({
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
  final now = DateTime.now();
  dateController.text =
      "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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

              // Date
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date",
                  hintText: "DD-MM-YYYY",
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
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
                  prefixIcon: const Icon(Icons.money, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
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
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),

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
                        description: desc,
                        type: type,
                      );
                    } else {
                      controller.addVendorReceivable(
                        vendorId: vendorId,
                        fuelPurchaseId: fuelPurchaseId,
                        date: date,
                        amount: amount,
                        description: desc,
                        type: type,
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

void showAddcustomerBottomSheet({
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
                    prefixIcon: const Icon(Icons.money, color: Colors.black54),
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
                          Navigator.pop(ctx);

                          // Go to Customer → Payables tab
                          Get.to(
                            () => const PayablesReceivablesPage(
                              initialTab: 2,
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
                          Navigator.pop(ctx);

                          // Go to both → Payables tab
                          Get.to(
                            () => const PayablesReceivablesPage(
                              initialTab: 2,
                              initialsubtab: 1,
                            ),
                          );
                        }
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
  final now = DateTime.now();
  dateController.text =
      "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) => Padding(
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
                isPayable
                    ? "Add Vendor Payable".tr
                    : "Add Vendor Receivable".tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Date
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date".tr,
                  hintText: "DD-MM-YYYY".tr,
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
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
                  labelText: "Payment Amount".tr,
                  prefixIcon: const Icon(Icons.money, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
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
                  labelText: "Description".tr,
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final date = dateController.text;
                    final amount = double.tryParse(amountController.text) ?? 0;
                    final desc = descController.text;

                    if (date.isEmpty || amount == 0 || desc.isEmpty) {
                      Get.snackbar(
                        "Error".tr,
                        "All fields are required".tr,
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
                        description: desc,
                        type: type,
                      );
                    } else {
                      controller.addVendorReceivable(
                        vendorId: vendorId,
                        fuelPurchaseId: fuelPurchaseId,
                        date: date,
                        amount: amount,
                        description: desc,
                        type: type,
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
                  child: Text(
                    "Submit".tr,
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
}

void showAddcustomerBottomSheet({
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
    builder: (BuildContext ctx) => Padding(
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
                      ? "${"Add Payable to".tr} $customerName"
                      : "${"Add Receivable from".tr} $customerName",
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
                      ? "${"Current Payable".tr}: ₹${currentAmount.toStringAsFixed(2)}"
                      : "${"Current Receivable".tr}: ₹${currentAmount.toStringAsFixed(2)}",
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
                    labelText: "Date".tr,
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
                      builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
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
                        ),
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
                    labelText: "Payment Amount".tr,
                    labelStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(Icons.money, color: Colors.black54),
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
                    labelText: "Description".tr,
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
                    label: Text("Upload Document".tr),
                  ),
                  const SizedBox(height: 5),
                  Obx(
                    () => Column(
                      children:
                          controller.base64Files
                              .map(
                                (f) => ListTile(
                                  leading: const Icon(Icons.insert_drive_file),
                                  title: Text(f["fileName"] ?? "Document".tr),
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
                          "Error".tr,
                          "Please fill all required fields".tr,
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
                              initialTab: 2,
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

                          // Go to both → Payables tab
                          Get.to(
                            () => const PayablesReceivablesPage(
                              initialTab: 2,
                              initialsubtab: 1,
                            ),
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          "Error".tr,
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
                      "Submit".tr,
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
  );
}
