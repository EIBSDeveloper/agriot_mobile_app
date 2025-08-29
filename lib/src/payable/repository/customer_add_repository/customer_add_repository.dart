import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;

import '../../../app/controller/app_controller.dart';

class CustomerAddRepository {
  final String baseUrl = "http://147.93.19.253:5000/Api";

  final AppDataController appDeta = Get.put(AppDataController());
  /// POST Payable API
  Future<Map<String, dynamic>> postPayable(
   
    int customerId,
    Map<String, dynamic> body,
  ) async {
    final farmerId = appDeta.userId;
    final url = Uri.parse(
      "$baseUrl/pay_sales_payables_outstanding/$farmerId/$customerId/",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("📤 Payable Response Status: ${response.statusCode}");
    print("📤 Payable Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Decode if possible, else return raw body
      try {
        return jsonDecode(response.body);
      } catch (_) {
        throw Exception("Failed to add payable: ${response.body}");
      }
    }
  }

  /// POST Receivable API
  Future<Map<String, dynamic>> postReceivable(
  
    int customerId,
    Map<String, dynamic> body,
  ) async {final farmerId = appDeta.userId;
    final url = Uri.parse(
      "$baseUrl/pay_sales_outstanding/$farmerId/$customerId/",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("📤 Receivable Response Status: ${response.statusCode}");
    print("📤 Receivable Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        return jsonDecode(response.body);
      } catch (_) {
        throw Exception("Failed to add receivable: ${response.body}");
      }
    }
  }
}
