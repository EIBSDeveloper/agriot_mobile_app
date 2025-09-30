import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/controller/app_controller.dart';
import '../../model/customer_history/customer_sales_history.dart';
import '../../model/customer_vendor_model/customer_vendor_model.dart';

class CustomerVendorRepository {  
  final AppDataController appDeta = Get.put(AppDataController());

  /// Fetch payables list for a given user ID
  Future<VendorCustomerResponse> fetchPayables() async {
    final url = Uri.parse('${appDeta.baseUrl.value}/customer_vendor_payables_list/${appDeta.farmerId.value}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return VendorCustomerResponse.fromJson(jsonData);
    } else {
      throw Exception(
        'Failed to fetch payables (status: ${response.statusCode})',
      );
    }
  }

  /// Fetch receivables list for a given user ID
  Future<VendorCustomerResponse> fetchReceivables() async {
    final url = Uri.parse('${appDeta.baseUrl.value}/customer_vendor_receivables_list/${appDeta.farmerId.value}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return VendorCustomerResponse.fromJson(jsonData);
    } else {
      throw Exception(
        'Failed to fetch receivables (status: ${response.statusCode})',
      );
    }
  }

  /// Fetch full receivable history for a sale
  Future<List<ReceivableHistorymodel>> fetchReceivableHistory(
  
    int customerId,
    int saleId,
  ) async {
    final url = Uri.parse(
      "${appDeta.baseUrl.value}/get_farmer_both_receivables_outstanding_history/${appDeta.farmerId.value}/"
      "?customer_id=$customerId&sale_id=$saleId",
    );
    print("📡 Fetching history: $url");

    final response = await http.get(url);
    print("🔵 Response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['data'] is List) {
        final List data = body['data'];
        return data.map((e) => ReceivableHistorymodel.fromJson(e)).toList();
      } else {
        print("⚠️ Unexpected data format: ${body['data']}");
        return [];
      }
    } else {
      throw Exception(
        "Failed to load receivable history (status: ${response.statusCode})",
      );
    }
  }

  /// Fetch single receivable history record
  Future<ReceivableHistorymodel> fetchReceivableSingleHistory(
  
    int customerId,
    int saleId,
    int outstandingId,
  ) async {
    final url = Uri.parse(
      "${appDeta.baseUrl.value}/get_farmer_both_receivables_outstanding_history/${appDeta.farmerId.value}/"
      "?customer_id=$customerId&sale_id=$saleId&outstanding_id=$outstandingId",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List data = body['data'];
      if (data.isNotEmpty) {
        return ReceivableHistorymodel.fromJson(data.first);
      } else {
        throw Exception("No history found for this outstanding ID");
      }
    } else {
      throw Exception(
        "Failed to fetch single history (status: ${response.statusCode})",
      );
    }
  }

  /// Fetch full payable history for a sale
  Future<List<PayableHistorymodel>> fetchpayablehistory(
   
    int customerId,
    int saleId,
  ) async {
    final url = Uri.parse(
      "${appDeta.baseUrl.value}/get_farmer_both_payables_outstanding_history/${appDeta.farmerId.value}/"
      "?customer_id=$customerId&sale_id=$saleId",
    );
    print("📡 Fetching history: $url");

    final response = await http.get(url);
    print("🔵 Response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['data'] is List) {
        final List data = body['data'];
        return data.map((e) => PayableHistorymodel.fromJson(e)).toList();
      } else {
        print("⚠️ Unexpected data format: ${body['data']}");
        return [];
      }
    } else {
      throw Exception(
        "Failed to load receivable history (status: ${response.statusCode})",
      );
    }
  }

  /// Fetch single payable history record
  Future<PayableHistorymodel> fetchpayablesinglehistory(

    int customerId,
    int saleId,
    int outstandingId,
  ) async {
    final url = Uri.parse(
      "${appDeta.baseUrl.value}/get_farmer_both_payables_outstanding_history/${appDeta.farmerId.value}/"
      "?customer_id=$customerId&sale_id=$saleId&outstanding_id=$outstandingId",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List data = body['data'];
      if (data.isNotEmpty) {
        return PayableHistorymodel.fromJson(data.first);
      } else {
        throw Exception("No history found for this outstanding ID");
      }
    } else {
      throw Exception(
        "Failed to fetch single history (status: ${response.statusCode})",
      );
    }
  }
}
