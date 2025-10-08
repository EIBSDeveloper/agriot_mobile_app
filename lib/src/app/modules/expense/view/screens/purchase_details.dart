import 'package:argiot/src/app/modules/expense/controller/purchase_details_controller.dart';
import 'package:argiot/src/app/modules/expense/model/fuel_inventory_model.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/loading.dart';
class PurchaseDetails extends GetView<InventoryDetailsController> {
  const PurchaseDetails({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const CustomAppBar(title: "Purchase Details"),
        body: Obx(() {
          if (controller.isLoading.value) return const Loading();
          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('error_loading_data'.tr),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadFuelInventoryDetail,
                    child: Text('retry'.tr),
                  ),
                ],
              ),
            );
          }

          final details = controller.fuelInventory.value;
          if (details == null) {
            return Center(child: Text('no_data_available'.tr));
          }

          return _buildFuelDetailContent(details);
        }),
      );

  Widget _buildFuelDetailContent(PurchaseDetailModel d) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(d.inventoryItems?.name ?? "No Item",
                style: Get.textTheme.headlineSmall),
            const SizedBox(height: 16),

            // --- BASIC INFO ---
            _sectionTitle("Details"),
            _buildInfoRow("Date", _formatDate(d.dateOfConsumption)),
            _buildInfoRow("Inventory Type", d.inventoryType?.name),
            _buildInfoRow("Vendor", d.vendor?.name),
            _buildInfoRow("Purchase Amount", d.purchaseAmount),
            _buildInfoRow("Quantity", d.quantity != null? "${d.quantity ?? ""} ${d.unitType ?? ""}":null),


            // --- VEHICLE INFO ---
            // _sectionTitle("Vehicle Details"),
            _buildInfoRow("Register Number", d.registerNumber),
            _buildInfoRow("Owner Name", d.ownerName),
            _buildInfoRow("Date of Registration", d.dateOfRegistration),
            _buildInfoRow("Engine Number", d.engineNumber),
            _buildInfoRow("Chasis Number", d.chasisNumber),
            _buildInfoRow("Running Kilometer", d.runningKilometer?.toString()),
            _buildInfoRow("Average Mileage", d.averageMileage?.toString()),
            _buildInfoRow("Fuel Capacity", d.fuelCapacity?.toString()),

            // --- INSURANCE INFO ---
            // _sectionTitle("Insurance Details"),
           
            _buildInfoRow("Company Name", d.companyName),
            _buildInfoRow("Insurance No", d.insuranceNo),
            _buildInfoRow("Insurance Amount", d.insuranceAmount?.toString()),
            _buildInfoRow("Start Date", _formatDateStr(d.insuranceStartDate)),
            _buildInfoRow("End Date", _formatDateStr(d.insuranceEndDate)),
            _buildInfoRow("Renewal Date", _formatDateStr(d.insuranceRenewalDate)),


            // --- WARRANTY INFO ---
            // _sectionTitle("Warranty Details"),
            if (d.warrantyStartDate == null || (d.warrantyStartDate.toString().isEmpty) )
            ...[
            _buildInfoRow("Warranty Start", _formatDateStr(d.warrantyStartDate)),
            _buildInfoRow("Warranty End", _formatDateStr(d.warrantyEndDate)),

            const Divider(height: 32),],

            // --- DESCRIPTION ---
            _sectionTitle("Description"),
            Text(d.description ?? "-", style: Get.textTheme.bodyLarge),

            const Divider(height: 32),

            // --- DOCUMENTS ---
            _sectionTitle("Documents"),
            if (d.documents != null && d.documents!.isNotEmpty)
              Column(
                children: d.documents!
                    .map((doc) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file_outlined),
                              const SizedBox(width: 8),
                              Expanded(child: Text(doc.toString())),
                            ],
                          ),
                        ))
                    .toList(),
              )
            else
              const Text("No documents uploaded"),
          ],
        ),
      );

  // --- Helper Widgets ---
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 12),
        child: Text(title,
            style: Get.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            )),
      );

  Widget _buildInfoRow(String label, String? value) => value == null || value.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 2,
                  child: Text(label, style: Get.textTheme.bodyMedium)),
              Expanded(
                  flex: 3,
                  child: Text(value, style: Get.textTheme.titleMedium)),
            ],
          ),
        );

  String _formatDate(DateTime? date) =>
      date == null ? "-" : DateFormat('dd-MM-yyyy').format(date);

  String _formatDateStr(String? dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return "";
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(dateStr.toString()));
    } catch (_) {
      return dateStr.toString();
    }
  }
}
