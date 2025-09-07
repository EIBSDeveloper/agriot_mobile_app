import 'package:argiot/src/app/modules/dashboad/model/daily_data.dart';

class FinanceData {
  final double totalSales;
  final double totalExpenses;
  final List<DailyData> sales;
  final List<DailyData> expenses;

  FinanceData({
    required this.totalSales,
    required this.totalExpenses,
    required this.sales,
    required this.expenses,
  });

  factory FinanceData.fromJson(Map<String, dynamic> json) => FinanceData(
    totalSales: json['total_sales_amount']?.toDouble() ?? 0.0,
    totalExpenses: json['total_expenses_amount']?.toDouble() ?? 0.0,
    sales: List<DailyData>.from(
      json['sales']?.map((x) => DailyData.fromJson(x)) ?? [],
    ),
    expenses: List<DailyData>.from(
      json['expenses']?.map((x) => DailyData.fromJson(x)) ?? [],
    ),
  );
}
