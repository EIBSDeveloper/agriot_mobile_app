

class Chart {
  final String expensestype;
  final double totalAmount;
  final double percentage;

  Chart({
    required this.expensestype,
    required this.totalAmount,
    required this.percentage,
  });

  factory Chart.fromJson(Map<String, dynamic> json) => Chart(
      expensestype: json['type_expenses__name'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );

  Map<String, dynamic> toJson() => {
      'type_expenses__name': expensestype,
      'total_amount': totalAmount,
      'percentage': percentage,
    };
}








