class TotalPayments {
  final double payables;
  final double receivables;

  TotalPayments({required this.payables, required this.receivables});

  factory TotalPayments.fromJson(Map<String, dynamic> json) => TotalPayments(
    payables: json['payables']?.toDouble() ?? 0.0,
    receivables: json['receivables']?.toDouble() ?? 0.0,
  );
}
