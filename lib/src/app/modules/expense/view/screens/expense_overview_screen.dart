import 'package:argiot/src/app/modules/expense/controller/expense_controller.dart';
import 'package:argiot/src/app/modules/expense/model/expense.dart';
import 'package:argiot/src/app/modules/expense/model/purchase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../routes/app_routes.dart';
import '../../../../widgets/input_card_style.dart';
import '../../../../widgets/title_text.dart';
import '../../../../widgets/toggle_bar.dart';
import '../widgets/month_day_format.dart';

class ExpenseOverviewScreen extends GetView<ExpenseController> {
  const ExpenseOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () => controller.loadExpenseData(),

    child: Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleText("expenses".tr),
              const SizedBox(height: 10),
              _buildSummarySection(),
              const SizedBox(height: 10),

              // _buildPieChart(),
              // const SizedBox(height: 10),
              ToggleBar(
                onTap: (index) => controller.changeTab(index),
                activePageIndex: controller.selectedTab.value,
                buttonsList: ["all".tr, "general".tr, "inventory".tr],
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
          // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedPeriod.value,
              padding: const EdgeInsets.all(0),
              alignment: AlignmentDirectional.center,
              icon: const Icon(Icons.keyboard_arrow_down),
              isExpanded: true,
              items: ['week', '30days', 'year']
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
    final items = controller.selectedTab.value == 0
        ? [...controller.expenses, ...controller.purchases]
        : controller.selectedTab.value == 1
        ? controller.expenses
        : controller.purchases;

    if (items.isEmpty) {
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item is Expense) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MonthDayFormat(
                    date: DateFormat("dd-MM-yyyy").parse(item.createdDay),
                  ),
                  const SizedBox(width: 8),

                  /// Left section (title + subtitle)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.typeExpenses.name,
                          style: Get.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.myCrop.name,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '₹${item.amount.toStringAsFixed(2)}',
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (item is Purchase) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MonthDayFormat(
                    date: DateFormat(
                      "dd/MM/yyyy",
                    ).parse(item.dateOfConsumption),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          item.inventoryItems.name,
                          style: Get.textTheme.bodyLarge,
                        ),
                        if (item.availableQuans != null &&
                            item.inventorytype.id != 1 &&
                            item.inventorytype.id != 2) ...[
                          const SizedBox(height: 4),
                          Text(
                            'quantity'.trParams({
                              'quantity': item.availableQuans.toString(),
                            }),
                            style: Get.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  /// Right section (trailing price)
                  Text(
                    '₹${item.purchaseAmount}',
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
