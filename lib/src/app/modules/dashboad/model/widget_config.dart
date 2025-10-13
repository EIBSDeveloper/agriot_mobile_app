

class WidgetConfig {
  late bool weatherAndPayments;
  late bool expensesSales;
  late bool marketPrice;
  late bool scheduleTask;
  late bool? guidelines;

  WidgetConfig({
    required this.weatherAndPayments,
    required this.expensesSales,
    required this.marketPrice,
    required this.scheduleTask,
    required this.guidelines,
  });

  factory WidgetConfig.fromJson(Map<String, dynamic> json) => WidgetConfig(
    weatherAndPayments: json['weather_date & receivables_payables'] ?? true,
    expensesSales: json['expenses_sales'] ?? true,
    marketPrice: json['near_by_market_price'] ?? true,
    scheduleTask: json['schedulr_task'] ?? true,
    guidelines: json['guidelines'] ?? true,
  );
   Map<String, dynamic> toJson() => {
    'weather_date': weatherAndPayments,
    'expenses_sales': expensesSales,
    'near_by_market_price': marketPrice,
    'schedulr_task': scheduleTask,
    'guideliness': guidelines,
  };
}
