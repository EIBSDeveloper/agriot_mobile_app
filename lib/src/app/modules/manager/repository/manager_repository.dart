import 'dart:convert';

import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/manager/model/dropdown_model.dart';
import 'package:argiot/src/app/modules/manager/model/permission_model.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:get/get.dart';

import '../../../service/utils/utils.dart';
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

  Future<List<DrapDown>> fetchAssignManager() async {
    final userId = appDeta.farmerId;
    final response = await _httpService.get("/manager_by_fermer/$userId");

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => DrapDown.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load permissions: ${response.statusCode}');
    }
  }

  Future addRole({required String role}) async {
    final userId = appDeta.farmerId;
    final response = await _httpService.post("/role_add/$userId", {
      "name": role,
    });

    if (response.statusCode == 201) {
      showSuccess("New Role added");
      Get.back();
    } else {
      showError("failed");
    }
  }

  Future<Map<String, dynamic>> createEmployeeManager({
    int? id,
    required DrapDown? role,
    required String name,
    required String phone,
    String? profile,
    String? salary,
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
      "id": id,
      "farmer_id": farmerId,
      "role_id": role?.id ?? 0,
      "name": name,
      if (profile!.isNotEmpty) "img": "data:image/png;base64,$profile",
      // "img": profile,
      "salary": salary,
      "phone_number": phone,
      "mobile_no":
          phone,
      "email": email ?? '',
      "employee_type_id": employeeTypeId,
      "employee_type": employeeTypeId,
      "gender_id": genderId,
      "dob": dob,
      "doj": doj,
      "address": address,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "locations": generateGoogleMapsUrl(latitude, longitude),
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
