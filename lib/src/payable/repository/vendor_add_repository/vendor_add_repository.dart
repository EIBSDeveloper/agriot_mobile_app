import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/controller/app_controller.dart';
import '../../model/vendor_add_model/vendor_add_model.dart';

final AppDataController appDeta = Get.put(AppDataController());

class VendorAddRepository {
  final String baseUrl = appDeta.baseUrl.value;
  final farmerId = appDeta.farmerId;
 
  // Create Payable
  Future<VendorPaymentResponse?> createVendorPayable({
    required int vendorId,
    required int fuelPurchaseId,
    required String date,
    required double paymentAmount,
    required String description,
    required String type,
    required List documentItems,
  }) async {
    final url = Uri.parse(
      "$baseUrl/add_vendor_outstanding/$farmerId/$vendorId/",
    );

    final body = {
      "action": "create_pay",
      "date": date,
    "expense_id":fuelPurchaseId,
      "payment_amount": paymentAmount, // send as number
      "description": description,
      "documents": documentItems.map((e) {
        var json = e.toJson();
        json['document'] = json['documents'][0];
        json['documents'] = [];
        return json;
      }).toList(),
    };

    final response = await http.post(
      url,
      body: json.encode(body),
      headers: {"Content-Type": "application/json"},
    );

    print("Payable HTTP Status: ${response.statusCode}");
    print("Payable HTTP Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return VendorPaymentResponse.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(
        error['detail'] ?? "Unknown error occurred while creating payable",
      );
    }
  }

  // Create Receivable
  Future<VendorReceiveResponse?> createVendorReceivable({
    required int vendorId,
    required int fuelPurchaseId,
    required String date,
    required double paymentAmount,
    required String description,
    required String type,
    required List documentItems,
  }) async {
    final url = Uri.parse(
      "$baseUrl/add_vendor_outstanding/$farmerId/$vendorId/",
    );

    final body = {
      "action": "create_receive",
      "date": date,
      "purchase_type": type.toLowerCase(),
     "expense_id":fuelPurchaseId,
      "payment_amount": paymentAmount, // send as number
      "description": description,
      //"documents": documentItems,
      "documents": documentItems.map((e) {
        var json = e.toJson();
        json['document'] = json['documents'][0];
        json['documents'] = [];
        return json;
      }).toList(),
    };

    final response = await http.post(
      url,
      body: json.encode(body),
      headers: {"Content-Type": "application/json"},
    );

    print("Receivable HTTP Status: ${response.statusCode}");
    print("Receivable HTTP Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return VendorReceiveResponse.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(
        error['detail'] ?? "Unknown error occurred while creating receivable",
      );
    }
  }
}
