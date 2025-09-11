import 'package:argiot/src/app/modules/dashboad/view/widgets/chart_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BiPieChart extends StatelessWidget {
  final List<ChartData> chartData;

  const BiPieChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) => SfCircularChart(
      legend: const Legend(
        isVisible: false,
        position: LegendPosition.top,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData d, _) => d.label,
          yValueMapper: (ChartData d, _) => d.value,
          pointColorMapper: (ChartData d, _) => d.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: false,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
}
