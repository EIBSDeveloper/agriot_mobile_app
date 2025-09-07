class CreateOrderResponse {
  final String orderId;
  final String keyId;

  CreateOrderResponse({required this.orderId, required this.keyId});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) => CreateOrderResponse(
      orderId: json['order_id'] ?? '',
      keyId: json['key_id'] ?? '',
    );
}
