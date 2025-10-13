import 'dart:convert';

import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/employee/model/user_model.dart';
import 'package:get/get.dart';

import '../../../service/http/http_service.dart';

class EmployeeManagerRepository extends GetxController {
  final HttpService _httpService = Get.find<HttpService>();
  final AppDataController appDeta = Get.find();

  Future<List<ManagerEmployeeGroup>> getGroupedEmployees({
    int page = 1,
    String searchQuery = '',
    int? managerParam,
  }) async {
    try {
      final farmerId = appDeta.farmerId.value;

      // Build query parameters

      var search = searchQuery.isNotEmpty ? 'search=$searchQuery' : '';
      // var manager = managerParam != null
      //     ? '& Manager_param= $managerParam'
      //     : '';
      final isManager = appDeta.isManager.value;
      final managerId = managerParam ?? appDeta.managerID.value;
      String manager = isManager || managerParam != null
          ? "&manager_id=$managerId"
          : "";
      final response = await _httpService.get(
        "/employee_grouped/$farmerId?page=$page$search$manager",
      );

      final data = json.decode(response.body) as List;

      return data.map((item) => ManagerEmployeeGroup.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> statusUpdate({
    required int id,
    required int scheduleStatus,
  }) async {
    try {
      final response = await _httpService.post('/employees/status/$id/', {
        'status': scheduleStatus,
      });
      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  // Keep old methods for backward compatibility if needed
  Future<List<UserModel>> getEmployees({
    int page = 1,
    String searchQuery = '',
  }) async {
    final groups = await getGroupedEmployees(
      page: page,
      searchQuery: searchQuery,
    );

    // Extract all employees from all groups
    final allEmployees = <UserModel>[];
    for (var group in groups) {
      allEmployees.addAll(group.employees.map((e) => e.toUserModel()));
    }

    return allEmployees;
  }

  Future<List<UserModel>> getManagers({
    int page = 1,
    String searchQuery = '',
  }) async {
    final groups = await getGroupedEmployees(
      page: page,
      searchQuery: searchQuery,
    );

    // Extract all managers
    return groups.map((group) => group.manager.toUserModel()).toList();
  }
}
