class Chart {
  final String type_expenses__name;
  final double total_amount;
  final double percentage;

  Chart({
    required this.type_expenses__name,
    required this.total_amount,
    required this.percentage,
  });

  factory Chart.fromJson(Map<String, dynamic> json) {
    return Chart(
      type_expenses__name: json['type_expenses__name'] ?? '',
      total_amount: (json['total_amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type_expenses__name': type_expenses__name,
      'total_amount': total_amount,
      'percentage': percentage,
    };
  }
}
