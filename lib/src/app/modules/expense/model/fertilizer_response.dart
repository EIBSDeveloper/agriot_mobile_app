class FertilizerResponse {
  final bool success;
  final String message;

  FertilizerResponse({required this.success, required this.message});

  factory FertilizerResponse.fromJson(Map<String, dynamic> json) => FertilizerResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
}
