class VendorPayments {
  final double payables;
  final double receivables;

  VendorPayments({required this.payables, required this.receivables});

  factory VendorPayments.fromJson(Map<String, dynamic> json) => VendorPayments(
    payables: json['payables']?.toDouble() ?? 0.0,
    receivables: json['receivables']?.toDouble() ?? 0.0,
  );
}
