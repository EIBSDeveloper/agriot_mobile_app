// lib/modules/expenses/models/expense_model.dart

import 'package:argiot/src/app/modules/expense/expense_controller.dart';
import 'package:argiot/src/app/modules/expense/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pie_chart/pie_chart.dart';

import '../../widgets/input_card_style.dart';
import '../../widgets/title_text.dart';

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
                TitleText("Expense".tr),
                const SizedBox(height: 10),
                _buildSummarySection(),
                const SizedBox(height: 10),
                _buildPieChart(),
                const SizedBox(height: 10),
                _buildTabBar(),
                const SizedBox(height: 10),
                _buildTransactionList(),
              ],
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Get.theme.primaryColor,
          onPressed: _showAddDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );

  void _showAddDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),
            ListTile(
              title: Text(
                "${'add_new'.tr} ${'Expense'.tr}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.back();

                Get.toNamed("/addExpense")?.then((res) {
                  controller.loadExpenseData();
                });
              },
            ),
            ListTile(
              title: Text(
                "${'add_new'.tr} ${'Purchase'.tr}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.back();

                Get.toNamed("/purchaseItems")?.then((res) {
                  controller.loadExpenseData();
                });
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSummarySection() => Row(
      children: [
        // const Text(
        //   "Expenses",
        //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        // ),
        Expanded(
          child: InputCardStyle(
            child: Text(
              "Total Expenses\n₹ ${controller.totalExpense.value.toStringAsFixed(0)}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                isExpanded: true,
                items: ['week', '30days', 'year']
                    .map(
                      (period) => DropdownMenuItem(
                        value: period,
                        child: Text(period.tr),
                      ),
                    )
                    .toList(),
                onChanged: controller.changePeriod,
              ),
            ),
          ),
        ),
      ],
    );

  Widget _buildPieChart() => Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.cardexpenses.isEmpty) {
        return const SizedBox();
      }
      Map<String, double> dataMap = {
        for (var item in controller.cardexpenses)
          item.expensestype: item.totalAmount,
      };

      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: PieChart(
                  dataMap: dataMap,
                  colorList: controller.colorList,
                  chartType: ChartType.disc,
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                    showChartValueBackground: false,
                    decimalPlaces: 0,
                    chartValueStyle: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  legendOptions: const LegendOptions(showLegends: false),
                  // chartRadius: MediaQuery.of(Get.context).size.width / 1,
                  initialAngleInDegree: 0,
                  centerText: "",
                  baseChartColor: Colors.white,
                  ringStrokeWidth: 32,
                ),
              ),

              // Legends
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: controller.cardexpenses.asMap().entries.map((
                      entry,
                    ) {
                      int index = entry.key;
                      var expense = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                expense.expensestype,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "₹ ${expense.totalAmount.toStringAsFixed(1)}k",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color:
                                    controller.colorList[index %
                                        controller.colorList.length],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

  Widget _buildTabBar() => Row(
      children: [
        _buildTabButton(0, 'All'),
        _buildTabButton(1, 'Expenses'),
        _buildTabButton(2, 'Purchases'),
      ],
    );

  Widget _buildTabButton(int index, String text) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: controller.selectedTab.value == index
                ? Get.theme.primaryColor
                : Colors.grey[200],
          ),
          onPressed: () => controller.changeTab(index),
          child: Text(
            text.tr,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: controller.selectedTab.value == index
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
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
          child: Text('No transactions found'.tr),
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
            child: ListTile(
              title: Text('${item.createdDay} - ${item.typeExpenses.name}'),
              subtitle: Text(item.myCrop.name),
              trailing: Text(
                '₹${item.amount.toStringAsFixed(2)}',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } else if (item is Purchase) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(
                '${item.dateOfConsumption} - ${item.inventoryItems.name}',
              ),
              subtitle: (item.availableQuans != null && item.inventorytype.id!= 1  && item.inventorytype.id!= 2 )
                  ? Text('Quantity: ${item.availableQuans}')
                  : null,
              trailing: Text(
                '₹${item.purchaseAmount}',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } else {
          return const SizedBox(); // Fallback for unexpected types
        }
      },
    );
  }

  // String _formatDate(String date) {
  //   try {
  //     return DateFormat('MMM dd').format(DateTime.parse(date));
  //   } catch (e) {
  //     return date;
  //   }
  // }
}
