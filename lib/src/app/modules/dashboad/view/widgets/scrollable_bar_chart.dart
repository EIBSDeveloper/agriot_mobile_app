import 'package:argiot/src/app/modules/dashboad/model/land_v_s_crop_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';class ScrollableBarChart extends StatelessWidget {
  final LandVSCropModel data;

  const ScrollableBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final labels = data.labels;
    final values = data.data;

    return Container(
      height: 250, // increased for labels
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (values.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBorderRadius: BorderRadius.circular(6),
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipColor: (group) => Get.theme.primaryColor,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final value = rod.toY;
                return BarTooltipItem(
                  value.round().toString(),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 1 != 0) return Container();
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
                interval: 1,
              ),
              axisNameWidget: const Text(
                'Crops', // Y-axis label
                // style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              axisNameSize: 20,
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) return Container();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(labels[index], style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
              axisNameWidget: const Text(
                'Land', // X-axis label
                // style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              axisNameSize: 20,
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(labels.length, (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index].toDouble(),
                  color: Get.theme.primaryColor,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            )),
        ),
      ),
    );
  }
}
