import 'dart:convert';

import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/employee/model/employee_details_model.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

import '../model/model.dart';

class EmployeeDetailsRepository extends GetxController {
  final HttpService _httpService = Get.find<HttpService>();

  final AppDataController appData = Get.find();

  Future<EmployeeDetailsModel> getEmployeeDetails(int detailID) async {
    // final farmerId = appData.farmerId.value;
    try {
      final response = await _httpService.get('/employee/$detailID');
      final data = json.decode(response.body);
     
      return EmployeeDetailsModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<EmployeeDetailsModel> getManagerDetails(int detailID) async {
    try {
      // final farmerId = appData.farmerId.value;
      final response = await _httpService.get('/manager/$detailID');
      final data = json.decode(response.body);
   

      return EmployeeDetailsModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}

class EmployeeAdvanceRepository {
  final HttpService _httpService = Get.find<HttpService>();

  Future<List<Employee>> getEmployees() async {
    try {
      final response = await _httpService.get('/employees');
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((e) => Employee.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<EmployeeAdvanceResponse> getEmployeeAdvanceData(
    String employeeId,
  ) async {
    try {
      final response = await _httpService.get(
        '/employee/advance/details/$employeeId',
      );
      final data = json.decode(response.body);
      return EmployeeAdvanceResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<EmployeeAdvanceResponse> updateEmployeeAdvance(
    UpdateAdvanceRequest request,
  ) async {
    try {
      final response = await _httpService.post(
        '/employee/advance/update',
        request.toJson(),
      );
      final data = json.decode(response.body);
      return EmployeeAdvanceResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
