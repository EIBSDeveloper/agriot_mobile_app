import 'dart:convert';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/employee/model/model.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

class UpdateEmployeePayoutsRepository {
  final HttpService _httpService = Get.find<HttpService>();

  final AppDataController appData = Get.find<AppDataController>();

  Future<EmployeePayoutsData?> getEmployeePayoutsData(int employeeId) async {
    try {
      final response = await _httpService.get(
        '/employee/payouts/details/$employeeId',
      );
      final data = json.decode(response.body);
      return EmployeePayoutsData.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future updateEmployeePayouts(UpdatePayoutsRequest request) async {
    try {
      final response = await _httpService.post(
        '/employee_advance/${appData.farmerId.value}',
        request.toJson(),
      );
      final data = json.decode(response.body);
      return data['id'];
    } catch (e) {
      rethrow;
    }
  }
}