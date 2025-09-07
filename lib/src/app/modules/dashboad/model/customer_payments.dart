class CustomerPayments {
  final double payables;
  final double receivables;

  CustomerPayments({required this.payables, required this.receivables});

  factory CustomerPayments.fromJson(Map<String, dynamic> json) =>
      CustomerPayments(
        payables: json['payables']?.toDouble() ?? 0.0,
        receivables: json['receivables']?.toDouble() ?? 0.0,
      );
}
