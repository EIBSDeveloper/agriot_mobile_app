import 'dart:math';
import 'package:argiot/src/app/modules/dashboad/model/daily_data.dart';
import 'package:argiot/src/app/modules/dashboad/model/finance_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FinanceLineChart extends StatelessWidget {
  final FinanceData financeData;

  const FinanceLineChart({super.key, required this.financeData});

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) =>
      SideTitleWidget(
        meta: meta,
        space: 8,
        child: Text(
          value.toInt().toString(),
          style: TextStyle(
            fontSize: min(12, 12 * chartWidth / 300),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );

  Widget leftTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: min(14, 14 * chartWidth / 300),
    );
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: FittedBox(child: Text(value.toInt().toString(), style: style)),
    );
  }

  LineChartBarData _buildLine(List<DailyData> data, Color color) =>
      LineChartBarData(
        spots: data.map((d) => FlSpot(double.parse(d.day), d.amount)).toList(),
        isCurved: true,
        color: color,
        barWidth: 2.5,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        isStrokeCapRound: true,
      );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(5),
    child: AspectRatio(
      aspectRatio: 1.8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final allAmounts = [
            ...financeData.sales.map((e) => e.amount),
            ...financeData.expenses.map((e) => e.amount),
          ];
          final minY = allAmounts.isEmpty ? 0.0 : allAmounts.reduce(min);
          final maxY = allAmounts.isEmpty ? 1.0 : allAmounts.reduce(max);

          return LineChart(
            LineChartData(
              minY: minY * 0.95,
              maxY: maxY * 1.05,
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBorderRadius: BorderRadius.circular(8),
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  maxContentWidth: 150,
                  getTooltipColor: (spot) => Colors.white,
                  getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                    final style = TextStyle(
                      color: spot.bar.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    );
                    return LineTooltipItem(
                      '${spot.y.round()} in day ${spot.x.toInt()}',
                      style,
                    );
                  }).toList(),
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      if (value == financeData.sales.length.toDouble()) {
                        return const SizedBox.shrink();
                      }
                      return bottomTitleWidgets(
                        value,
                        meta,
                        constraints.maxWidth,
                      );
                    },
                  ),
                  axisNameWidget: const Text('Days'),
                  axisNameSize: 20,
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: (maxY - minY) / 5,
                    getTitlesWidget: (value, meta) {
                      if (value > maxY) {
                        return const SizedBox.shrink();
                      }
                      return leftTitleWidgets(
                        value,
                        meta,
                        constraints.maxWidth,
                      );
                    },
                  ),
                  axisNameWidget: const Text(
                    'Amount', 
                  ),
                  axisNameSize: 20,
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                  drawBelowEverything: false,
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withAlpha(150), width: 1),
              ),
              lineBarsData: [
                _buildLine(financeData.sales, Colors.green),
                _buildLine(financeData.expenses, Colors.red),
              ],
            ),
          );
        },
      ),
    ),
  );
}
