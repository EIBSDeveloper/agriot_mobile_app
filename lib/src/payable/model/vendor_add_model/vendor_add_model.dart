class VendorPaymentResponse {
  final double totalPaid;
  final double toPay;
  final double paymentAmount;

  VendorPaymentResponse({
    required this.totalPaid,
    required this.toPay,
    required this.paymentAmount,
  });

  factory VendorPaymentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return VendorPaymentResponse(
      totalPaid: (data['total_paid'] ?? 0).toDouble(),
      toPay: (data['to_pay'] ?? 0).toDouble(),
      paymentAmount: (data['payment_amount'] ?? 0).toDouble(),
    );
  }
}

class VendorReceiveResponse {
  final double totalReceived;
  final double toReceive;
  final double paymentAmount;

  VendorReceiveResponse({
    required this.totalReceived,
    required this.toReceive,
    required this.paymentAmount,
  });

  factory VendorReceiveResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return VendorReceiveResponse(
      totalReceived: (data['total_received'] ?? 0).toDouble(),
      toReceive: (data['to_receive'] ?? 0).toDouble(),
      paymentAmount: (data['payment_amount'] ?? 0).toDouble(),
    );
  }
}
