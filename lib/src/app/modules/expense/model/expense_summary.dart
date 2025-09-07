class ExpenseSummary {
  final String category;
  final double totalAmount;
  final double percentage;

  ExpenseSummary({
    required this.category,
    required this.totalAmount,
    required this.percentage,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) => ExpenseSummary(
      category: json['type_expenses__name'],
      totalAmount: json['total_amount'].toDouble(),
      percentage: json['percentage'].toDouble(),
    );
}
