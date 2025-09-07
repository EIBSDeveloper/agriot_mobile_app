// lib/app/services/http_service.dart

/// Custom HTTP exception
class HttpException implements Exception {
  final String message;
  final int? statusCode;

  HttpException({required this.message, this.statusCode});

  @override
  String toString() => message;
}
