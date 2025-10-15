import 'dart:convert';

import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/attendence/model/attendencemodel.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AttendanceRepository {
  final HttpService _httpService = Get.find<HttpService>();
  final AppDataController appDeta = Get.put(AppDataController());

  //Fetch Employees from API
  Future<List<EmployeeModel>> fetchEmployees({
    required String date,
    int page = 1,
    String search = '',
    bool? onlyUpdated,
    String? managerParam,
  }) async {
    final farmerId = appDeta.farmerId;

    String key = onlyUpdated != null && onlyUpdated == true
        ? "&onlyUpdated=True"
        : '';
    final isManager = appDeta.isManager.value;
    final managerId = managerParam ?? appDeta.managerID.value;
    String manager = isManager || managerParam != null
        ? "&manager_id=$managerId"
        : "";
    try {
      final response = await _httpService.get(
        "/attendance_list?date=$date&farmer_id=$farmerId&page=$page$key$manager&search=$search",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((e) => EmployeeModel.fromJson(e)).toList();
      } else {
        debugPrint("❌ Error fetching employees: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("⚠️ Exception fetching employees: $e");
      return [];
    }
  }

  /// Add Attendance for multiple employees at once
  Future<bool> addAttendance({
    required List<Map<String, dynamic>> employees,
  }) async {
    try {
      final response = await _httpService.post(
        "/attendance",
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
