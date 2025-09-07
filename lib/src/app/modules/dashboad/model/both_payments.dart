class BothPayments {
  final double payables;
  final double receivables;

  BothPayments({required this.payables, required this.receivables});

  factory BothPayments.fromJson(Map<String, dynamic> json) => BothPayments(
    payables: json['payables']?.toDouble() ?? 0.0,
    receivables: json['receivables']?.toDouble() ?? 0.0,
  );
}
