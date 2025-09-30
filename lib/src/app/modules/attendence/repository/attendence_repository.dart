// attendance_repository.dart
import 'dart:convert';

import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/attendence/model/attendencemodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

final AppDataController appDeta = Get.put(AppDataController());

class AttendanceRepository {
  /// 🔥 Fetch Employees from API
  Future<List<EmployeeModel>> fetchEmployees({required String date}) async {
    final farmerId = appDeta.farmerId;

    try {
      final url = Uri.parse(
        "${appDeta.baseUrl.value}/attendance_list?date=$date&farmer_id=$farmerId",
      );

      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data as List).map((e) => EmployeeModel.fromJson(e)).toList();
      } else {
        debugPrint("Error: ${res.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Exception fetching employees: $e");
      return [];
    }
  }
}
