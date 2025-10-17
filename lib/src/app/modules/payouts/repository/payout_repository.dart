import 'dart:convert';

import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/payouts/model/payoutmodel.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class PayoutRepository {
  final HttpService _httpService = Get.find<HttpService>();
  final AppDataController appDeta = Get.put(AppDataController());

  //Fetch Employees from API
  Future<List<PayoutModel>> fetchAdvanceList({
    int page = 1,
    String search = '',
    String? managerParam,
  }) async {
    final farmerId = appDeta.farmerId;
  
    final isManager = appDeta.isManager.value;
    final managerId = managerParam ?? appDeta.managerID.value;
    String manager = isManager || managerParam != null
        ? "&manager_id=$managerId"
        : "";
    String searchParam = managerParam != null && search.isNotEmpty
        ? "&search=$search"
        : "";
    String param = "page=$page$searchParam$manager";
    try {
      final response = await _httpService.get(
        "/advances_list/$farmerId?$param",
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((e) => PayoutModel.fromJson(e)).toList();
      } else {
        debugPrint("❌ Error fetching payouts: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("⚠️ Exception fetching payouts: $e");
      return [];
    }
  }

  //Fetch Employees from API
  Future<List<PayoutModel>> fetchAdvanceListOnlyPaied({
    int page = 1,
    String search = '',
    String? managerParam,
  }) async {
    final farmerId = appDeta.farmerId;

    final isManager = appDeta.isManager.value;
    final managerId = managerParam ?? appDeta.managerID.value;
    String manager = isManager || managerParam != null
        ? "&manager_id=$managerId"
        : "";
    String searchParam = managerParam != null && search.isNotEmpty
        ? "&search=$search"
        : "";
    String updateFiledOnly = "&onlyUpdated=True";
    String param = "page=$page$searchParam$updateFiledOnly$manager";
    try {
      final response = await _httpService.get(
        "/advances_list/$farmerId?$param",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((e) => PayoutModel.fromJson(e)).toList();
      } else {
        debugPrint("❌ Error fetching payouts: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("⚠️ Exception fetching payouts: $e");
      return [];
    }
  }

  /// Add Attendance for multiple employees at once
  Future<bool> addPayouts({
    required List<Map<String, dynamic>> employees,
  }) async {
    final farmerId = appDeta.farmerId;
    try {
      final response = await _httpService.post(
        "/employee_payout_list/${farmerId.value}",
        employees, // send as JSON list
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint("✅ Attendance added successfully: ${response.body}");
        return true;
      } else {
        debugPrint("❌ Error adding attendance: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("⚠️ Exception adding attendance: $e");
      return false;
    }
  }
}
