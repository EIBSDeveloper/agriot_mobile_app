// lib/repositories/customer_sales_repository.dart
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/controller/app_controller.dart';
import '../../model/customer/customer_sales_model.dart';
import '../../model/customer_history/customer_sales_history.dart';

final AppDataController appDeta = Get.put(AppDataController());

class CustomerSalesRepository {
  final String baseUrl = appDeta.baseUrl.value;
  final farmerId = appDeta.farmerId.value;
  Future<List<CustomerPayable>> fetchCustomerPayables(int customerId) async {
    final url = Uri.parse(
      "$baseUrl/customer_sales_payables_list/$farmerId?customer_id=$customerId",
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      return CustomerSalesModel.fromJson(jsonData).payables;
    } else {
      throw Exception('Failed to fetch payables');
    }
  }

  Future<List<CustomerReceivable>> fetchCustomerReceivables(
    int customerId,
  ) async {
    final url = Uri.parse(
      "$baseUrl/customer_sales_receivables_list/$farmerId?customer_id=$customerId",
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      return CustomerSalesModel.fromJson(jsonData).receivables;
    } else {
      throw Exception('Failed to fetch receivables');
    }
  }

  // Fetch Payables History
  Future<List<PayableHistorymodel>> fetchPayablesHistory({
    required int customerId,
    required int saleId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/get_sales_payables_outstanding_history/$farmerId/?customer_id=$customerId&sale_id=$saleId",
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      return (jsonData['data'] as List)
          .map((e) => PayableHistorymodel.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to fetch payables history');
    }
  }

  // Fetch Payable History Details
  Future<PayableHistorymodel> fetchPayableDetail({
    required int customerId,
    required int saleId,
    required int outstandingId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/get_sales_payables_outstanding_history/$farmerId/?customer_id=$customerId&sale_id=$saleId&outstanding_id=$outstandingId",
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      return PayableHistorymodel.fromJson(jsonData['data'][0]);
    } else {
      throw Exception('Failed to fetch payable detail');
    }
  }

  // Fetch Receivables History
  Future<List<ReceivableHistorymodel>> fetchReceivablesHistory({
    required int customerId,
    required int saleId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/customer_sales_receivables_outstanding_history/$farmerId/?customer_id=$customerId&sale_id=$saleId",
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      return (jsonData['data'] as List)
          .map((e) => ReceivableHistorymodel.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to fetch receivables history');
    }
  }

  // Fetch Receivable History Details

  Future<ReceivableHistorymodel?> fetchReceivableDetail({
    required int customerId,
    required int saleId,
    required int outstandingId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/customer_sales_receivables_outstanding_history/"
      "$farmerId/?customer_id=$customerId&sale_id=$saleId&outstanding_id=$outstandingId",
    );

    print("🔗 API URL: $url");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      print("📥 API Response: $jsonData");

      final data = jsonData['data'];
      if (data != null && data is List && data.isNotEmpty) {
        return ReceivableHistorymodel.fromJson(data[0]);
      }
      return null; // no data
    } else {
      throw Exception('Failed to fetch receivable detail [${res.statusCode}]');
    }
  }
}
