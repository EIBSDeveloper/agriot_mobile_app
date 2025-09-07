class DailyData {
  final String day;
  final double amount;

  DailyData({required this.day, required this.amount});

  factory DailyData.fromJson(Map<String, dynamic> json) =>
      DailyData(day: json['day'], amount: json['amount']?.toDouble() ?? 0.0);
}
