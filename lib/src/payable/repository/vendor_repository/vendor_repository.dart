// lib/repository/vendor_purchase_repository.dart
import 'dart:convert';


import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/controller/app_controller.dart';
import '../../model/vendor/vendor_history_model.dart';
import '../../model/vendor/vendor_purchase_model.dart';

  final AppDataController appDeta = Get.put(AppDataController());
class VendorPurchaseRepository {
  final farmerId = appDeta.userId;
  Future<VendorPurchaseResponse> fetchVendorPayables(
  
    int vendorId,
  ) async {
    final url =
        'http://147.93.19.253:5000/Api/vendor_purchase_payables_list/$farmerId?vendor_id=$vendorId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return VendorPurchaseResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load vendor payables');
    }
  }

  Future<VendorPurchaseResponse> fetchVendorReceivables(
  
    int vendorId,
  ) async {
    final url =
        'http://147.93.19.253:5000/Api/vendor_purchase_receivables_list/$farmerId?vendor_id=$vendorId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return VendorPurchaseResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load vendor receivables');
    }
  }

  // Payables History
  Future<List<VendorPayableHistoryModel>?> fetchVendorPayablesHistory({
   
    required int vendorId,
    required int fuelId,
    required String type,
  }) async {
    final url = Uri.parse(
      'http://147.93.19.253:5000/Api/vendor_purchase_payables_outstanding_history/$farmerId/?vendor_id=$vendorId&id=$fuelId&type=$type',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final data = jsonBody['data'] as List;
        return data.map((e) => VendorPayableHistoryModel.fromJson(e)).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //Receivables History
  Future<List<VendorReceivableHistoryModel>?> fetchVendorReceivablesHistory({
   
    required int vendorId,
    required int fuelId,
    required String type,
  }) async {
    final url = Uri.parse(
      'http://147.93.19.253:5000/Api/vendor_purchase_receivables_outstanding_history/$farmerId/?vendor_id=$vendorId&id=$fuelId&type=$type',
    );
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final data = jsonBody['data'] as List;
        return data
            .map((e) => VendorReceivableHistoryModel.fromJson(e))
            .toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
