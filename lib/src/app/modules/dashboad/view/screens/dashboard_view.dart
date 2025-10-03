import 'package:argiot/src/app/modules/dashboad/model/product_price.dart';
import 'package:argiot/src/app/modules/dashboad/view/widgets/chart_data.dart';
import 'package:argiot/src/app/modules/dashboad/view/widgets/scrollable_bar_chart.dart';
import 'package:argiot/src/app/modules/dashboad/view/widgets/bi_pie_chart.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/land_dropdown.dart';
import 'package:argiot/src/app/widgets/finance_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../forming/view/widget/empty_land_card.dart';
import '../../../../../payable/pages/payables_receivables/payables_receivables_screen.dart';
import '../../../../routes/app_routes.dart';
import '../../../../service/utils/utils.dart';
import '../../../../widgets/title_text.dart';
import '../../../home/contoller/bottombar_contoller.dart';
import '../../../guideline/view/widget/guideline_card.dart';
import '../../../task/view/widget/task_card.dart';
import '../../controller/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchLands(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Land selection dropdown
            _buildLandDropdown(),
            const SizedBox(height: 5),
            Obx(
              () => EmptyLandCard(
                view: controller.lands.isEmpty,
                refresh: controller.fetchLands,
              ),
            ),
            // Widgets based on configuration
            if (controller.lands.isNotEmpty &&
                controller.widgetConfig.value.weatherAndPayments) ...[
              _buildWeatherAndPaymentsCard(),
              const SizedBox(height: 16),
            ],

            if (controller.lands.isNotEmpty &&
                controller.widgetConfig.value.expensesSales) ...[
              _buildFinanceGraphCard(),
              const SizedBox(height: 16),
            ],

            if (controller.lands.isNotEmpty &&
                controller.widgetConfig.value.guidelines!) ...[
              _buildGuidelinesCard(),
              const SizedBox(height: 16),
            ],

            if (controller.lands.isNotEmpty &&
                controller.widgetConfig.value.marketPrice) ...[
              _buildMarketPricesCard(),
              const SizedBox(height: 16),
            ],

            if (controller.lands.isNotEmpty &&
                controller.widgetConfig.value.scheduleTask) ...[
              _buildTasksCard(),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  });

  Widget _buildLandDropdown() => Row(
    children: [
      Expanded(
        child: Obx(
          () => LandDropdown(
            lands: controller.lands,
            color: Colors.transparent,
            selectedLand: controller.selectedLand.value,
            onChanged: (land) => controller.changeLand(land!),
          ),
        ),
      ),
      IconButton(
        color: Get.theme.primaryColor,
        iconSize: 40,
        icon: const Icon(Icons.widgets),
        onPressed: () => controller.showWidgetSettings(),
      ),
    ],
  );

  Widget _buildWeatherAndPaymentsCard() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (controller.weatherData.value != null) ...[
        Expanded(
          child: Card(
            color: Get.theme.colorScheme.primaryContainer,
            elevation: 0,
            child: Container(
              height: 150,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud, size: 60, color: Colors.white),
                        ],
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${kelvinToCelsius(controller.weatherData.value!.temperature).toStringAsFixed(1)}°C|°F'
                              .tr,
                          style: TextStyle(
                            fontSize: 20,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              controller.weatherData.value!.condition.tr,
                            ),
                          ),
                          const Text(" / "),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "${"humidity_percentage".tr}${controller.weatherData.value!.humidity.toString()}",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],

      // Payments section
      if (controller.paymentSummary.value != null) ...[
        Expanded(
          child: Card(
            color: Get.theme.primaryColor.withAlpha(80),
            elevation: 0,
            child: SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: BiPieChart(
                        chartData: [
                          ChartData(
                            'Receivables',
                            controller.paymentSummary.value!.total.receivables <
                                    0.0
                                ? 0
                                : controller
                                      .paymentSummary
                                      .value!
                                      .total
                                      .receivables,
                            const Color.fromARGB(255, 107, 151, 37),
                          ),
                          ChartData(
                            'Payables',
                            controller.paymentSummary.value!.total.payables <
                                    0.0
                                ? 0
                                : controller
                                      .paymentSummary
                                      .value!
                                      .total
                                      .payables,
                            const Color.fromARGB(255, 140, 103, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.to(const PayablesReceivablesPage());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPaymentItem(
                              'receivables'.tr,
                              controller
                                  .paymentSummary
                                  .value!
                                  .total
                                  .receivables,
                              const Color.fromARGB(255, 107, 151, 37),
                            ),
                            const Divider(),
                            _buildPaymentItem(
                              'payables'.tr,
                              controller.paymentSummary.value!.total.payables,
                              const Color.fromARGB(255, 140, 103, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ],
    ],
  );

  Widget _buildPaymentItem(String title, double amount, Color color) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      FittedBox(fit: BoxFit.fitWidth, child: Text(title)),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '${'currency_symbol'.tr}${amount.toInt()}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ),
    ],
  );

  Widget _buildExpenssItem(
    String title,
    double amount,
    Color color,
    Function()? onTap,
  ) => InkWell(
    onTap: onTap,
    child: Container(
      color: color.withAlpha(5),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(title.tr, style: const TextStyle()),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${'currency_symbol'.tr}${amount.toInt()}',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildFinanceGraphCard() =>
      (controller.financeData.value != null ||
          controller.landVSCropData.value != null)
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TitleText(
                    (controller.idlandVSCropGraph.value)
                        ? 'land_vs_crop'.tr
                        : 'monthly_based_graph'.tr,
                  ),
                ),

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        controller.idlandVSCropGraph.value =
                            !controller.idlandVSCropGraph.value;
                      },
                      iconSize: 30,
                      icon: Icon(
                        Icons.keyboard_arrow_left,
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.idlandVSCropGraph.value =
                            !controller.idlandVSCropGraph.value;
                      },
                      iconSize: 30,
                      icon: Icon(
                        Icons.keyboard_arrow_right,
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // if (controller.financeData.value?.totalExpenses == 0 &&   controller.financeData.value?.totalSales == 0)
                Expanded(
                  child: (controller.idlandVSCropGraph.value)
                      ? ScrollableBarChart(
                          data: controller.landVSCropData.value!,
                        )
                      : SizedBox(
                          // height: 300,
                          child: Column(
                            children: [
                              Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildExpenssItem(
                                          'sales : ',
                                          controller
                                              .financeData
                                              .value!
                                              .totalSales,
                                          Colors.green,
                                          () {
                                            Get.toNamed(Routes.sales);
                                          },
                                        ),
                                      ),
                                      const Divider(),
                                      Expanded(
                                        child: _buildExpenssItem(
                                          'expenses : ',
                                          controller
                                              .financeData
                                              .value!
                                              .totalExpenses,
                                          Colors.red,
                                          () {
                                            BottomBarContoller bconteroller =
                                                Get.find();
                                            bconteroller.selectedIndex.value =
                                                2;
                                            bconteroller.pageController
                                                .jumpToPage(2);
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (controller.financeData.value != null) ...[
                                    if ((controller
                                                .financeData
                                                .value
                                                ?.totalExpenses !=
                                            0 ||
                                        controller.financeData.value?.totalSales !=
                                            0))
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          height: 200,
                                          child:FinanceLineChart(financeData: controller.financeData.value!),
                                        ),
                                      ),
                                 
                                 
                                 
                                  ] else ...[
                                    Center(child: Text('no_finance_data'.tr)),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                ),

              ],
            ),
          ],
        )
      : const SizedBox();


  Widget _buildGuidelinesCard() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TitleText('guidelines'.tr),
          InkWell(
            onTap: () {
              Get.toNamed(Routes.guidelines);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'view_all'.tr,
                  style: TextStyle(
                    color: Get.theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          height: 100,
          child: Obx(() {
            if (controller.guidelines.isEmpty) {
              return Center(child: Text('no_guidelines'.tr));
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.guidelines.length,
              itemBuilder: (context, index) => SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GuidelineCard(guideline: controller.guidelines[index]),
                ),
              ),
            );
          }),
        ),
      ),
    ],
  );

  Widget _buildMarketPricesCard() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: TitleText('market_prices'.tr)),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                Get.toNamed(Routes.nearMe);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'view_all'.tr,
                    style: TextStyle(
                      color: Get.theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.marketError.isNotEmpty) {
            return Center(
              child: Text(
                "${'error_message'.tr} ${controller.marketError.value}",
              ),
            );
          }

          if (controller.marketPrices.isEmpty) {
            return Center(child: Text('no_data_available'.tr));
          }

          final markets = controller.marketPrices
              .map((r) => r.marketName)
              .toList();

          final Set<String> allProducts = {};
          for (var report in controller.marketPrices) {
            for (var price in report.prices) {
              allProducts.add(price.product);
            }
          }
          final productList = allProducts.toList();

          // Use max 4 markets to fit your columns
          final displayMarkets = markets.length > 4
              ? markets.sublist(0, 4)
              : markets;

          // Build header row widgets
          final headerCells = <Widget>[
            Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                'trending_crops'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            for (var market in displayMarkets)
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  market.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ];

          // Build data rows dynamically for each product
          final dataRows = productList.map((product) {
            final rowCells = <String>[product.tr];

            // For each market in displayMarkets, find price or show '-'
            for (var marketName in displayMarkets) {
              final market = controller.marketPrices.firstWhere(
                (m) => m.marketName == marketName,
              );
              final priceObj = market.prices.firstWhere(
                (p) => p.product == product,
                orElse: () => ProductPrice(product: product, price: 0),
              );

              rowCells.add('${'currency_symbol'.tr} ${priceObj.price}');
            }

            return _buildDataRow(rowCells);
          }).toList();

          return Table(
            border: TableBorder.all(color: const Color(0xFFD1D1D1)),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Get.theme.primaryColor),
                children: headerCells,
              ),
              ...dataRows,
            ],
          );
        }),
      ],
    ),
  );

  TableRow _buildDataRow(List<String> cells) => TableRow(
    decoration: const BoxDecoration(color: Colors.white),
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(cells[0], style: const TextStyle(color: Colors.black)),
        ),
      ),
      ...cells
          .sublist(1)
          .map(
            (text) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
    ],
  );

  Widget _buildTasksCard() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TitleText('tasks'.tr),
          InkWell(
            onTap: () {
              BottomBarContoller bconteroller = Get.find();
              bconteroller.selectedIndex.value = 4;
              bconteroller.pageController.jumpToPage(4);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'view_all'.tr,
                  style: TextStyle(
                    color: Get.theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Obx(() {
            if (controller.tasks.isEmpty) {
              return Center(child: Text('no_tasks_available'.tr));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.tasks.length,
              itemBuilder: (context, index) => TaskCard(
                task: controller.tasks[index],
                refresh: () {
                  controller.fetchTasks();
                },
              ),
            );
          }),
        ],
      ),
    ],
  );
}
