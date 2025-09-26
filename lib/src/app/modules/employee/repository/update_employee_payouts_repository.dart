import 'dart:convert';
import 'package:argiot/src/app/modules/employee/model/model.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

class UpdateEmployeePayoutsRepository {
  final HttpService _httpService = Get.find<HttpService>();

  Future<EmployeePayoutsResponse> getEmployeePayoutsData(String employeeId) async {
    try {
      final response = await _httpService.get(
        '/employee/payouts/details/$employeeId',
      );
      final data = json.decode(response.body);
      return EmployeePayoutsResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<EmployeePayoutsResponse> updateEmployeePayouts(UpdatePayoutsRequest request) async {
    try {
      final response = await _httpService.post(
        '/employee/payouts/update',
        request.toJson(),
      );
      final data = json.decode(response.body);
      return EmployeePayoutsResponse.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}