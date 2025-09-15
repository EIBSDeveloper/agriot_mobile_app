// models/sales_model.dart

import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/my_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/new_sales_controller.dart';
import '../../model/sales_detail.dart';
import '../../../../widgets/title_text.dart';
import '../../../../routes/app_routes.dart';

class NewSalesDetailsView extends StatefulWidget {
  const NewSalesDetailsView({super.key});

  @override
  State<NewSalesDetailsView> createState() => _NewSalesDetailsViewState();
}

class _NewSalesDetailsViewState extends State<NewSalesDetailsView> {
  final NewSalesController controller = Get.find<NewSalesController>();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: 'Sales Details',
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Get.toNamed(
              Routes.newSales,
              arguments: {
                "id": controller.salesDetail.value?.salesId,
                "new": true,
              },
            );
          },
        ),
      ],
    ),

    body: Obx(() {
      final salesDetail = controller.salesDetail.value;
      if (salesDetail == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Header
            _buildProductHeader(salesDetail),
            const SizedBox(height: 10),

            // Sales Details Card
            _buildSalesDetailsCard(salesDetail),
            const SizedBox(height: 10),

            // Deductions Section
            if (salesDetail.deductions.isNotEmpty)
              _buildDeductionsSection(salesDetail),
            if (salesDetail.deductions.isNotEmpty) const SizedBox(height: 20),

            // Documents Section
            if (salesDetail.documents.isNotEmpty)
              _buildDocumentsSection(salesDetail),
            if (salesDetail.documents.isNotEmpty) const SizedBox(height: 20),

            // Description Section
            if (salesDetail.description != null &&
                salesDetail.description != '')
              _buildDescriptionSection(salesDetail),
          ],
        ),
      );
    }),
  );

  Widget _buildProductHeader(SalesDetail salesDetail) => Row(
    children: [
      MyNetworkImage(salesDetail.myCrop.img, width: 80, height: 80),
      const SizedBox(width: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText(salesDetail.myCrop.name),
          Text(salesDetail.myLand.name),
        ],
      ),
    ],
  );

  Widget _buildSalesDetailsCard(SalesDetail salesDetail) => Card(
    margin: EdgeInsets.zero,
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Date', salesDetail.datesOfSales),
          _buildDetailRow('Customer Name', salesDetail.myCustomer.name),
          _buildDetailRow('Gross Sales', '₹${salesDetail.salesAmount}'),
          // _buildDetailRow('Deduction', '₹${salesDetail.deductionAmount}'),
          _buildDetailRow('Net Sales', '₹${salesDetail.totalSalesAmount}'),
          _buildDetailRow('Amount Paid', '₹${salesDetail.amountPaid}'),
        ],
      ),
    ),
  );

  Widget _buildDetailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Get.textTheme.bodyMedium),
        Text(value, style: Get.textTheme.bodyLarge),
      ],
    ),
  );

  Widget _buildDeductionsSection(SalesDetail salesDetail) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const TitleText('Deductions'),
      const SizedBox(height: 8),
      ...salesDetail.deductions.map(
        (deduction) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          child: ListTile(
            title: Text(deduction.reason.name),
            subtitle: Text('${deduction.charges} ${deduction.rupee.name}'),
          ),
        ),
      ),
    ],
  );

  Widget _buildDocumentsSection(SalesDetail salesDetail) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Documents', style: Get.textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: salesDetail.documents
            .map(
              (document) => InkWell(
                onTap: () {
                  var list = document.documents.map((doc)=>doc.uploadDocument).toList();
                  Get.toNamed(Routes.docViewer, arguments: list);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(document.documents.first.documentCategory.name),
                    MyNetworkImage(
                      document.documents.first.uploadDocument,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    ],
  );

  Widget _buildDescriptionSection(SalesDetail salesDetail) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Description', style: Get.textTheme.titleMedium),
      const SizedBox(height: 8),
      Text(salesDetail.description ?? ''),
    ],
  );
}
