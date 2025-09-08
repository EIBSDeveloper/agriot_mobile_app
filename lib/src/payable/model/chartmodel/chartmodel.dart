class Chart {
  final String typeExpensesName;
  final double totalAmount;
  final double percentage;

  Chart({
    required this.typeExpensesName,
    required this.totalAmount,
    required this.percentage,
  });

  factory Chart.fromJson(Map<String, dynamic> json) => Chart(
      typeExpensesName: json['type_expenses__name'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );

  Map<String, dynamic> toJson() => {
      'type_expenses__name': typeExpensesName,
      'total_amount': totalAmount,
      'percentage': percentage,
    };
}
