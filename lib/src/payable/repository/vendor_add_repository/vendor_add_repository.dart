import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/controller/app_controller.dart';
import '../../model/vendor_add_model/vendor_add_model.dart';

final AppDataController appDeta = Get.put(AppDataController());

class VendorAddRepository {
  final String baseUrl = "http://147.93.19.253:5000/Api";
  final farmerId = appDeta.userId;
  /*  // Create Payable
  Future<VendorPaymentResponse?> createVendorPayable({
    required int vendorId,
    required int fuelPurchaseId,
    required String date,
    required double paymentAmount,
    required String description,
    required String type,
  }) async {
    final url = Uri.parse(
      "$baseUrl/vendor_purchase_Payables_outstanding/$farmerId/$vendorId/",
    );

    final body = {
      "action": "create_pay",
      "date": date,
      "purchase_type": type.toLowerCase(),
      if (type.toLowerCase() == "fuel") "fuel_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "pesticides")
        "pesticide_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "seed") "seed_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "vehicle")
        "vehicle_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "fertilizer")
        "fertilizer_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "machinery")
        "machinery_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "tools") "tool_purchase_id": fuelPurchaseId,
      "payment_amount": paymentAmount.toString(),
      "description": description,
    };

    final response = await http.post(
      url,
      body: json.encode(body),
      headers: {"Content-Type": "application/json"},
    );

    print("Payable HTTP Status: ${response.statusCode}");
    print("Payable HTTP Body: ${response.body}");

    if (response.statusCode == 200) {
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
  }) async {
    final url = Uri.parse(
      "$baseUrl/pay_purchase_outstanding/$farmerId/$vendorId/",
    );

    final body = {
      "action": "create_receive",
      "date": date,
      // "purchase_type": "fuel",
      // "fuel_purchase_id": fuelPurchaseId,
      "purchase_type": type.toLowerCase(),
      if (type.toLowerCase() == "fuel") "fuel_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "pesticides")
        "pesticide_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "seed") "seed_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "vehicle")
        "vehicle_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "fertilizer")
        "fertilizer_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "machinery")
        "machinery_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "tools") "tool_purchase_id": fuelPurchaseId,
      "payment_amount": paymentAmount.toString(),
      "description": description,
    };

    final response = await http.post(
      url,
      body: json.encode(body),
      headers: {"Content-Type": "application/json"},
    );

    print("Receivable HTTP Status: ${response.statusCode}");
    print("Receivable HTTP Body: ${response.body}");

    if (response.statusCode == 200) {
      return VendorReceiveResponse.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(
        error['detail'] ?? "Unknown error occurred while creating receivable",
      );
    }
  }*/

  // Create Payable
  Future<VendorPaymentResponse?> createVendorPayable({
    required int vendorId,
    required int fuelPurchaseId,
    required String date,
    required double paymentAmount,
    required String description,
    required String type,
  }) async {
    final url = Uri.parse(
      "$baseUrl/vendor_purchase_Payables_outstanding/$farmerId/$vendorId/",
    );

    final body = {
      "action": "create_pay",
      "date": date,
      "purchase_type": type.toLowerCase(),
      if (type.toLowerCase() == "fuel") "fuel_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "pesticides")
        "pesticide_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "seed") "seed_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "vehicle")
        "vehicle_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "fertilizer")
        "fertilizer_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "machinery")
        "machinery_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "tools") "tool_purchase_id": fuelPurchaseId,
      "payment_amount": paymentAmount, // send as number
      "description": description,
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
  }) async {
    final url = Uri.parse(
      "$baseUrl/pay_purchase_outstanding/$farmerId/$vendorId/",
    );

    final body = {
      "action": "create_receive",
      "date": date,
      "purchase_type": type.toLowerCase(),
      if (type.toLowerCase() == "fuel") "fuel_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "pesticides")
        "pesticide_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "seed") "seed_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "vehicle")
        "vehicle_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "fertilizer")
        "fertilizer_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "machinery")
        "machinery_purchase_id": fuelPurchaseId,
      if (type.toLowerCase() == "tools") "tool_purchase_id": fuelPurchaseId,
      "payment_amount": paymentAmount, // send as number
      "description": description,
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
