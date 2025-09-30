// lib/repository/vendor_purchase_repository.dart
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/controller/app_controller.dart';
import '../../model/vendor/vendor_history_model.dart';
import '../../model/vendor/vendor_purchase_model.dart';

final AppDataController appDeta = Get.put(AppDataController());

class VendorPurchaseRepository {
  final farmerId = appDeta.farmerId;
  final baseURl = appDeta.baseUrl;

  Future<Vendormodel> fetchVendorPayables(int vendorId) async {
    final url = '$baseURl/vendor_payables/$vendorId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Vendormodel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load vendor payables');
    }
  }

  Future<Vendormodel> fetchVendorReceivables(int vendorId) async {
    final url = '$baseURl/vendors_receivables/$vendorId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Vendormodel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load vendor receivables');
    }
  }

  // Payables History
  Future<List<VendorHistoryModel>> fetchVendorPayablesHistory(
    int expenseId,
  ) async {
    final url = Uri.parse('$baseURl/vendors_outstaing_history/$expenseId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data =
            json.decode(response.body) as List<dynamic>; // <-- cast to List
        return data
            .map((e) => VendorHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList(); // <-- convert Iterable to List
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  //Receivables History
  Future<List<VendorHistoryModel>> fetchVendorReceivablesHistory(
    int expenseId,
  ) async {
    final url = Uri.parse('$baseURl/vendors_outstaing_history/$expenseId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data =
            json.decode(response.body) as List<dynamic>; // <-- cast to List
        return data
            .map((e) => VendorHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList(); // <-- convert Iterable to List
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
