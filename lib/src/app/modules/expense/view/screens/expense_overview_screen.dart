import 'package:argiot/src/app/modules/expense/controller/expense_controller.dart';
import 'package:argiot/src/app/modules/expense/model/expense.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../routes/app_routes.dart';
import '../../../../widgets/input_card_style.dart';
import '../../../../widgets/loading.dart';
import '../../../../widgets/title_text.dart';
import '../../../../widgets/toggle_bar.dart';
class ExpenseOverviewScreen extends GetView<ExpenseController> {
  const ExpenseOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () => controller.loadExpenseData(),
    child: Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Loading();
        }
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleText("Expenses and sales".tr),
              const SizedBox(height: 10),
              _buildSummarySection(),
              const SizedBox(height: 10),
              ToggleBar(
                onTap: (index) => controller.changeTab(index),
                activePageIndex: controller.selectedTab.value,
                buttonsList: ["all".tr, "expenses".tr, "sales".tr],
              ),
              const SizedBox(height: 10),
              _buildTransactionList(),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Get.theme.primaryColor,
        onPressed: () {
          Get.toNamed(Routes.purchaseItems)?.then((res) {
            if (res ?? false) {
              controller.loadExpenseData();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    ),
  );

  Widget _buildSummarySection() => Row(
    children: [
      Expanded(
        child: InputCardStyle(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Text(
              "${"total_expenses".tr}\n ${controller.totalExpense.value.toStringAsFixed(0)}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: InputCardStyle(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedPeriod.value,
              padding: const EdgeInsets.all(0),
              alignment: AlignmentDirectional.center,
              icon: const Icon(Icons.keyboard_arrow_down),
              isExpanded: true,
              items: ['week', 'month', 'year']
                  .map(
                    (period) =>
                        DropdownMenuItem(value: period, child: Text(period.tr)),
                  )
                  .toList(),
              onChanged: controller.changePeriod,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildTransactionList() {
    final groupedItems = controller.selectedTab.value == 0
        ? controller.allGroupedRecords
        : controller.selectedTab.value == 1
        ? controller.expenseGroupedRecords
        : controller.salesGroupedRecords;

    if (groupedItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 200),
          child: Text('no_transactions_found'.tr),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final groupedRecord = groupedItems[index];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text(
                _formatDisplayDate(groupedRecord.date),
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Get.theme.primaryColor,
                ),
              ),
            ),
            // Records for this date
            ...groupedRecord.records.map((record) => _buildTransactionItem(record)),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(ExpenseRecord record) => Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.item.name,
                  style: Get.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${record.amount.toStringAsFixed(2)}',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Get.theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (record.vendor?.name !=null)
              Text(
                '${record.vendor!.name}',
                style: Get.textTheme.bodySmall,
              ),
            if (record.quantity != null && record.quantity!.isNotEmpty)
              Text(
                'Quantity: ${record.quantity}',
                style: Get.textTheme.bodySmall,
              ),
            if (record.description.isNotEmpty)
              Text(
                record.description,
                style: Get.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );

  String _formatDisplayDate(String dateString) {
    try {
      final inputFormat = DateFormat("dd-MM-yyyy");
      final outputFormat = DateFormat("MMM dd, yyyy");
      final date = inputFormat.parse(dateString);
      return outputFormat.format(date);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }
}