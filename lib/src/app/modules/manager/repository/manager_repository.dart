import 'dart:convert';

import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/manager/model/dropdown_model.dart';
import 'package:argiot/src/app/modules/manager/model/permission_model.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

import '../controller/manager_controller.dart';

class ManagerRepository {
  final AppDataController appDeta = Get.find();
  final HttpService _httpService = Get.find();

  Future<Map<String, dynamic>> fetchPermissions() async {
    // _httpService.get should return a Response
    final response = await _httpService.get('/permissions_list');

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load permissions');
    }
  }

  Future<List<AssignMangerModel>> fetchAssignManager() async {
    final userId = appDeta.farmerId;
    final response = await _httpService.get("/manager_by_fermer/$userId");

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => AssignMangerModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load permissions: ${response.statusCode}');
    }
  }

  /*  /// Create Employee / Manager
  Future<Map<String, dynamic>> createEmployeeManager({
    required RoleModel? role,
    required String name,
    required String phone,
    String? email,
    int? employeeTypeId,
    int? genderId,
    String? dob,
    String? doj,
    required String address,
    required double latitude,
    required double longitude,
    Map<String, PermissionItem>? permissions,
    int? managerId,
    int? workTypeId,
    String? pincode,
    String? description,
  }) async {
    final farmerId = appDeta.farmerId.value;

    Map<String, dynamic> body;

    if (role?.id != 0) {
      // Manager
      body = {
        "farmer_id": farmerId,
        "role_id": role?.id ?? 0,
        "name": name,
        "phone_number": phone,
        "email": email ?? '',
        "employee_type_id": employeeTypeId,
        "gender_id": genderId,
        "dob": dob,
        "doj": doj,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "permissions": permissions != null
            ? flattenPermissions(permissions)
            : {},
      };
    } else {
      // Employee
      body = {
        "role_id": role?.id ?? 0,
        "farmer_id": farmerId,
        "manager_id": managerId,
        "name": name,
        "mobile_no": phone,
        "employee_type": employeeTypeId,
        "work_type": workTypeId,
        "locations": "$latitude,$longitude",
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "address": address, // used for both
        "pincode": pincode ?? '',
        "description": description ?? '',
      };
    }

    final response = await _httpService.post(
      '/employee-manager/',
      body,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to create employee/manager: ${response.statusCode} → ${response.body}',
      );
    }
  }*/
  Future<Map<String, dynamic>> createEmployeeManager({
    required RoleModel? role,
    required String name,
    required String phone,
    String? email,
    int? employeeTypeId,
    int? genderId,
    String? dob,
    String? doj,
    required String address,
    required double latitude,
    required double longitude,
    Map<String, PermissionItem>? permissions,
    int? managerId,
    int? workTypeId,
    String? pincode,
    String? description,
  }) async {
    final farmerId = appDeta.farmerId.value;

    // Single body for both Employee & Manager
    final body = {
      "farmer_id": farmerId,
      "role_id": role?.id ?? 0,
      "name": name,
      "phone_number": phone,
      "mobile_no":
          phone, // keep both keys, controller can send empty if not needed
      "email": email ?? '',
      "employee_type_id": employeeTypeId,
      "employee_type": employeeTypeId,
      "gender_id": genderId,
      "dob": dob,
      "doj": doj,
      "address": address,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "locations": "$latitude,$longitude",
      "permissions": permissions != null ? flattenPermissions(permissions) : {},
      "manager_id": managerId,
      "work_type": workTypeId,
      "pincode": pincode ?? '',
      "description": description ?? '',
    };

    final response = await _httpService.post(
      '/employee-manager/',
      body,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to create employee/manager: ${response.statusCode} → ${response.body}',
      );
    }
  }
}
