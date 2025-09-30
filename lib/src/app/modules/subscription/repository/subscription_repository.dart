import 'dart:convert';
import 'package:argiot/src/app/modules/subscription/model/create_order_response.dart';
import 'package:argiot/src/app/modules/subscription/model/farmer_usage_response.dart';
import 'package:argiot/src/app/modules/subscription/model/package_list_response.dart';
import 'package:argiot/src/app/modules/subscription/model/verify_payment_response.dart';

import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

class SubscriptionRepository {
  final HttpService _httpService = Get.find();
  final AppDataController appData = Get.find();
  Future<PackageListResponse> getPackages() async {
    final farmerId = appData.farmerId.value;
    try {
      final response = await _httpService.get(
        '/get_package_management/$farmerId',
      );
      return PackageListResponse.fromJson(json.decode(response.body));
    } catch (e) {
      throw Exception('Failed to load packages: ${e.toString()}');
    }
  }

  Future<FarmerUsageResponse> getFarmerUsage() async {
    final farmerId = appData.farmerId.value;
    try {
      final response = await _httpService.get('/get_farmer_usage/$farmerId/');
      return FarmerUsageResponse.fromJson(json.decode(response.body));
    } catch (e) {
      throw Exception('Failed to load farmer usage: ${e.toString()}');
    }
  }

  Future<CreateOrderResponse> createOrder(int amount) async {
    try {
      final response = await _httpService.getWithodAPi('/create_order?amount=$amount');
      return CreateOrderResponse.fromJson(json.decode(response.body));
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  Future<VerifyPaymentResponse> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    required int packageId,
  }) async {
    final farmerId = appData.farmerId.value;
    try {
      final response = await _httpService.post('/verify_payment_mobile/', {
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_signature': razorpaySignature,
        'package_id': packageId,
        'farmer_id': farmerId,
      });
      return VerifyPaymentResponse.fromJson(json.decode(response.body));
    } catch (e) {
      throw Exception('Failed to verify payment: ${e.toString()}');
    }
  }
}
