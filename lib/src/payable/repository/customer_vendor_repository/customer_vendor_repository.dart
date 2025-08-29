// repository/customer_vendor_repository.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../model/customer_vendor_model/customer_vendor_model.dart';

class CustomerVendorRepository {
  final String baseUrl = "http://147.93.19.253:5000/Api";

  Future<CustomerVendorResponse<PayablesData>> fetchPayables(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/customer_vendor_payables_list/$id'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return CustomerVendorResponse.fromJson(
        jsonData,
        (data) => PayablesData.fromJson(data),
      );
    } else {
      throw Exception('Failed to load payables');
    }
  }

  Future<CustomerVendorResponse<ReceivablesData>> fetchReceivables(
    int id,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/customer_vendor_receivables_list/$id'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return CustomerVendorResponse.fromJson(
        jsonData,
        (data) => ReceivablesData.fromJson(data),
      );
    } else {
      throw Exception('Failed to load receivables');
    }
  }
}
