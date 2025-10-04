import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/loading.dart';
import '../../controller/cunsumption_details_controller.dart';
import '../../model/cunsumption_detail_model.dart';

class ConsumptionDetails extends GetView<CunsumptionDetailsController> {
  const ConsumptionDetails({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: "Cunsumption  Details"),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Loading();
      }

      if (controller.error.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('error_loading_data'.tr),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.loadCunsumptionDetail,
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

  Widget _buildFuelDetailContent(CunsumptionDetailModel details) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  details.inventoryItems!.name,
                  style: Get.textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Basic Information
            _buildInfoRow('date'.tr, details.dateOfConsumption.toString()),
            _buildInfoRow('inventory_type'.tr, details.inventoryType!.name),
            _buildInfoRow('crop'.tr, details.cropName),
            _buildInfoRow('purchase_amount'.tr, '${details.quantity} '),
            _buildInfoRow(
              'quantity'.tr,
              '${details.quantity} ${details.usageHours}',
            ),

            const Divider(height: 32),

            // Uploaded Documents
            Text('documents'.tr, style: Get.textTheme.titleMedium),

            // const SizedBox(height: 16),
            // _buildDocumentsSection(details),
            const Divider(height: 32),

            // Description
            Text('description'.tr, style: Get.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(details.description ?? "", style: Get.textTheme.bodyLarge),
          ],
        ),
      );

  Widget _buildInfoRow(String label, String? value) => value != null
      ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Get.textTheme.bodyMedium),
              Text(value, style: Get.textTheme.titleMedium),
            ],
          ),
        )
      : const SizedBox.square();

  // Widget _buildDocumentsSection(PurchaseDetailModel fuel) {
  //   final allDocuments = fuel.documents
  //       .expand((category) => category.documents)
  //       .toList();

  //   if (allDocuments.isEmpty) {
  //     return Text('no_documents_available'.tr);
  //   }

  //   return Wrap(
  //     spacing: 16,
  //     runSpacing: 16,
  //     children: allDocuments
  //         .map(
  //           (document) => GestureDetector(
  //             onTap: () => controller.viewDocument(document.uploadDocument),
  //             child: Container(
  //               width: 100,
  //               height: 120,
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Get.theme.colorScheme.outline),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Column(
  //                 children: [
  //                   Expanded(
  //                     child: Icon(
  //                       Icons.picture_as_pdf,
  //                       size: 48,
  //                       color: Get.theme.colorScheme.primary,
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(8),
  //                     child: Text(
  //                       document.documentCategory.name,
  //                       style: Get.textTheme.labelSmall,
  //                       textAlign: TextAlign.center,
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         )
  //         .toList(),
  //   );
  // }
}
