import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/controller/app_controller.dart';
import '../../model/customer_history/customer_sales_history.dart';
  final AppDataController appDeta = Get.put(AppDataController());
class CustomerSalesHistoryRepository {
  final String baseUrl = appDeta.baseUrl.value;


  // Fetch Payables History
  Future<List<PayableHistorymodel>> fetchPayablesHistory({
    required int customerId,
    required int saleId,
  }) async {
    final farmerId = appDeta.farmerId;
    final url = Uri.parse(
      "${baseUrl}get_sales_payables_outstanding_history/$farmerId/?customer_id=$customerId&sale_id=$saleId",
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
    final farmerId = appDeta.farmerId;
    final url = Uri.parse(
      "${baseUrl}get_sales_payables_outstanding_history/$farmerId/?customer_id=$customerId&sale_id=$saleId&outstanding_id=$outstandingId",
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
    final farmerId = appDeta.farmerId;
    final url = Uri.parse(
      "${baseUrl}customer_sales_receivables_outstanding_history/$farmerId/?customer_id=$customerId&sale_id=$saleId",
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
  Future<ReceivableHistorymodel> fetchReceivableDetail({
    required int customerId,
    required int saleId,
    required int outstandingId,
  }) async {
    final farmerId = appDeta.farmerId;
    final url = Uri.parse(
      "${baseUrl}customer_sales_receivables_outstanding_history/$farmerId/?customer_id=$customerId&sale_id=$saleId&outstanding_id=$outstandingId",
    );
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);
      return ReceivableHistorymodel.fromJson(jsonData['data'][0]);
    } else {
      throw Exception('Failed to fetch receivable detail');
    }
  }
}
