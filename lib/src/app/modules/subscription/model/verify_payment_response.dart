class VerifyPaymentResponse {
  final String status;
  final String message;

  VerifyPaymentResponse({required this.status, required this.message});

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json) => VerifyPaymentResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
}
