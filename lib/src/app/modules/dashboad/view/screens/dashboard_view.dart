import 'package:argiot/src/app/modules/dashboad/model/product_price.dart';
import 'package:argiot/src/app/modules/dashboad/view/widgets/scrollable_bar_chart.dart';
import 'package:argiot/src/app/modules/dashboad/view/widgets/bi_pie_chart.dart';
import 'package:argiot/src/app/modules/task/model/task.dart';
import 'package:argiot/src/app/widgets/finance_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../guideline/model/guideline.dart';
import '../../../../../payable/pages/payables_receivables/payables_receivables_screen.dart';
import '../../../../routes/app_routes.dart';
import '../../../../service/utils/utils.dart';
import '../../../../widgets/title_text.dart';
import '../../../bottombar/contoller/bottombar_contoller.dart';
import '../../../near_me/views/widget/widgets.dart';
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

            // Widgets based on configuration
            if (controller.widgetConfig.value.weatherAndPayments) ...[
              _buildWeatherAndPaymentsCard(),
              const SizedBox(height: 16),
            ],

            if (controller.widgetConfig.value.expensesSales) ...[
              _buildFinanceGraphCard(),
              const SizedBox(height: 16),
            ],

            if (controller.widgetConfig.value.guidelines!) ...[
              _buildGuidelinesCard(),
              const SizedBox(height: 16),
            ],

            if (controller.widgetConfig.value.marketPrice) ...[
              _buildMarketPricesCard(),
              const SizedBox(height: 16),
            ],

            if (controller.widgetConfig.value.scheduleTask) ...[
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
        icon: const Icon(
          Icons.widgets_outlined,
          color: Color.fromARGB(199, 0, 0, 0),
        ),
        onPressed: () => _showWidgetSettings(),
      ),
    ],
  );

  Widget _buildWeatherAndPaymentsCard() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (controller.weatherData.value != null) ...[
        Expanded(
          child: Card(
            color: const Color.fromARGB(255, 242, 240, 232),
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
      child: Column(
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
                      icon: const Icon(Icons.keyboard_arrow_left),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.idlandVSCropGraph.value =
                            !controller.idlandVSCropGraph.value;
                      },
                      icon: const Icon(Icons.keyboard_arrow_right),
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
                          height: 200,
                          child: Row(
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
                                      child: _buildFinanceChart(),
                                    ),
                                  ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildExpenssItem(
                                          'sales',
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
                                          'expenses',
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
                                ),
                              ] else ...[
                                Center(child: Text('no_finance_data'.tr)),
                              ],
                            ],
                          ),
                        ),
                ),

                // if (controller.financeData.value?.totalExpenses == 0 &&    controller.financeData.value?.totalSales == 0)
              ],
            ),
          ],
        )
      : const SizedBox();

  Widget _buildFinanceChart() =>
      FinanceLineChart(financeData: controller.financeData.value!);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
              child: Obx(() {
                if (controller.guidelines.isEmpty) {
                  return Center(child: Text('no_guidelines'.tr));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.guidelines.length,
                  itemBuilder: (context, index) {
                    final guideline = controller.guidelines[index];

                    var guideline2 = Guideline(
                      id: guideline.id,
                      name: guideline.name,
                      guidelinestype: guideline.description,
                      guidelinescategory: null,
                      description: guideline.description,
                      status: 0,
                      mediaType: guideline.mediaType,
                    );
                    return _buildGuidelineCard(guideline2);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    ],
  );

  void _handleGuidelineTap(Guideline guideline) {
    if (guideline.mediaType == 'video' && guideline.videoUrl != null) {
      Get.toNamed('/video-player', arguments: guideline.videoUrl);
    } else if (guideline.mediaType == 'document' &&
        guideline.document != null) {
      Get.toNamed('/document-viewer', arguments: guideline.document);
    } else {
      showError('unable_to_open_content'.tr);
    }
  }

  Widget _buildThumbnail(Guideline guideline) => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(0, 238, 238, 238),
          borderRadius: BorderRadius.circular(8),
        ),
        child: guideline.mediaType == 'video'
            ? const Icon(Icons.videocam, size: 40, color: Colors.grey)
            : const Icon(Icons.insert_drive_file, size: 40, color: Colors.grey),
      ),
      if (guideline.mediaType == 'video')
        const Icon(Icons.play_circle_fill, size: 40, color: Colors.white),
    ],
  );

  Widget _buildGuidelineCard(Guideline guideline) => SizedBox(
    width: 300,
    child: Card(
      color: const Color.fromARGB(255, 242, 240, 232),
      elevation: 0,
      margin: const EdgeInsets.only(right: 16),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: InkWell(
          onTap: () => _handleGuidelineTap(guideline),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(guideline),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guideline.guidelinestype.tr,
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guideline.description.tr,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
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
                'error_message'.trParams({
                  'error': controller.marketError.value,
                }),
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
            _buildHeaderCell('trending_crops'.tr),
            for (var market in displayMarkets) _buildHeaderCell(market.tr),
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

  Widget _buildHeaderCell(String text) => Padding(
    padding: const EdgeInsets.all(5.0),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: const TextStyle(color: Colors.black),
      ),
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
              itemBuilder: (context, index) {
                final task = controller.tasks[index];

                return _buildTaskCard(
                  Task(
                    id: task.id,
                    cropImage: task.cropImage,
                    cropType: task.cropType,
                    description: task.description,
                  ),
                );
              },
            );
          }),
        ],
      ),
    ],
  );

  Widget _buildTaskCard(Task tas) {
    Task task = tas;
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.taskDetail, arguments: {'taskId': task.id});
      },
      child: Card(
        margin: const EdgeInsets.only(right: 10, bottom: 8),
        color: Colors.grey.withAlpha(30),
        elevation: 0,
        child: ListTile(
          title: Text(task.cropType.tr),
          subtitle: Text(
            task.description.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // IconButton(
              //   icon: Icon(Icons.delete, color: Get.theme.primaryColor),
              //   onPressed: () => controller.deleteTask(task.id),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWidgetSettings() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'widget_settings'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                children: [
                  _buildWidgetToggle(
                    'weather_payments'.tr,
                    controller.widgetConfig.value.weatherAndPayments,
                    (value) {
                      controller.widgetConfig.update((val) {
                        val?.weatherAndPayments = value;
                      });
                    },
                  ),
                  _buildWidgetToggle(
                    'finance_graph'.tr,
                    controller.widgetConfig.value.expensesSales,
                    (value) {
                      controller.widgetConfig.update((val) {
                        val?.expensesSales = value;
                      });
                    },
                  ),
                  _buildWidgetToggle(
                    'guidelines'.tr,
                    controller.widgetConfig.value.guidelines!,
                    (value) {
                      controller.widgetConfig.update((val) {
                        val?.guidelines = value;
                      });
                    },
                  ),
                  _buildWidgetToggle(
                    'market_prices'.tr,
                    controller.widgetConfig.value.marketPrice,
                    (value) {
                      controller.widgetConfig.update((val) {
                        val?.marketPrice = value;
                      });
                    },
                  ),
                  _buildWidgetToggle(
                    'tasks'.tr,
                    controller.widgetConfig.value.scheduleTask,
                    (value) {
                      controller.widgetConfig.update((val) {
                        val?.scheduleTask = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ElevatedButton(
                //   onPressed: () => Get.back(),
                //   child: FittedBox(
                //     fit: BoxFit.scaleDown,
                //     child: Text('close'.tr),
                //   ),
                // ),
                ElevatedButton(
                  onPressed: () {
                    controller.updateWidgetConfiguration(
                      controller.widgetConfig.value,
                    );
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('save'.tr),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetToggle(
    String title,
    bool value,
    Function(bool) onChanged,
  ) => SwitchListTile(
    title: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(title, textAlign: TextAlign.start),
    ),
    // activeThumbColor: Get.theme.primaryColor,
    inactiveThumbColor: Get.theme.primaryColor,
    activeTrackColor: Get.theme.primaryColor.withAlpha(150),
    value: value,
    onChanged: onChanged,
  );
}
