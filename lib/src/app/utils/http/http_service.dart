// lib/app/services/http_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controller/app_controller.dart';

class MultipartBody {
  final Map<String, String> fields;
  final List<http.MultipartFile> files;

  MultipartBody({required this.fields, this.files = const []});
}

class HttpService extends GetxService {
  final AppDataController appData = Get.put(AppDataController());

  late final String baseUrl = appData.baseUrl.value;
  late final String baseUrlIWithodAPi = appData.baseUrlWithoutAPi.value;
  final int timeoutSeconds = 30;

  /// GET Request
  Future<http.Response> getWithodAPi(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(baseUrlIWithodAPi + endpoint),
            headers: _headers(headers),
          )
          .timeout(Duration(seconds: timeoutSeconds));
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET Request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final updatedEndpoint = endpoint.contains('?')
          ? '$endpoint&lang=ta'
          : '$endpoint?lang=ta';
      final response = await http
          .get(Uri.parse(baseUrl + updatedEndpoint), headers: _headers(headers))
          .timeout(Duration(seconds: timeoutSeconds));
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<http.Response> getRaw(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http
          .get(Uri.parse(endpoint), headers: _headers(headers))
          .timeout(Duration(seconds: timeoutSeconds));
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT Request — supports both JSON and Multipart
  Future<http.Response> put(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    try {
      final updatedEndpoint = endpoint.contains('?')
          ? '$endpoint&lang=ta'
          : '$endpoint?lang=ta';
      final url = Uri.parse(baseUrl + updatedEndpoint);

      if (body is MultipartBody) {
        final request = http.MultipartRequest('PUT', url);
        request.headers.addAll(_headers(headers));
        request.fields.addAll(body.fields);
        request.files.addAll(body.files);

        final streamedResponse = await request.send().timeout(
          Duration(seconds: timeoutSeconds),
        );
        return await http.Response.fromStream(streamedResponse);
      } else {
        final response = await http
            .put(url, headers: _headers(headers), body: jsonEncode(body))
            .timeout(Duration(seconds: timeoutSeconds));
        return _handleResponse(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Add this to your HttpService class in lib/app/services/http_service.dart

  /// POST Request — supports both JSON and Multipart
  Future<http.Response> post(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    try {
      final updatedEndpoint = endpoint.contains('?')
          ? '$endpoint&lang=ta'
          : '$endpoint?lang=ta';
      final url = Uri.parse(baseUrl + updatedEndpoint);

      if (body is MultipartBody) {
        final request = http.MultipartRequest('POST', url);
        request.headers.addAll(_headers(headers));
        request.fields.addAll(body.fields);
        request.files.addAll(body.files);

        final streamedResponse = await request.send().timeout(
          Duration(seconds: timeoutSeconds),
        );
        return await http.Response.fromStream(streamedResponse);
      } else {
        final response = await http
            .post(url, headers: _headers(headers), body: jsonEncode(body))
            .timeout(Duration(seconds: timeoutSeconds));
        return _handleResponse(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE Request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final url = Uri.parse(baseUrl + endpoint);
      final request = http.Request("DELETE", url);
      request.headers.addAll(_headers(headers));

      if (body != null) {
        request.body = jsonEncode(body);
      }

      final streamedResponse = await request.send().timeout(
        Duration(seconds: timeoutSeconds),
      );
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Headers
  Map<String, String> _headers(Map<String, String>? headers) {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    return defaultHeaders;
  }

  /// Handle successful response
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode <= 400) {
      return response;
    } else {
      throw HttpException(
        message: 'Error: ${response.statusCode} ${response.reasonPhrase}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Handle errors
  dynamic _handleError(dynamic error) {
    if (error is http.ClientException) {
      return HttpException(message: error.message);
    } else if (error is SocketException) {
      return HttpException(message: 'No internet connection.');
    } else {
      return HttpException(message: 'Unexpected error: $error');
    }
  }
}

/// Custom HTTP exception
class HttpException implements Exception {
  final String message;
  final int? statusCode;

  HttpException({required this.message, this.statusCode});

  @override
  String toString() => message;
}
