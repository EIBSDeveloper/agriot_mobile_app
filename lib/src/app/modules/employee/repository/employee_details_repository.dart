import 'dart:convert';

import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/employee/model/employee_details_model.dart';
// import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

import '../../../service/http/http_service.dart';
import '../model/model.dart';

class EmployeeDetailsRepository extends GetxController {
  // final HttpService _httpService = Get.find<HttpService>();

  final AppDataController appData = Get.find();

  Future<EmployeeDetailsModel> getEmployeeDetails(int detailID) async {
    // final farmerId = appData.userId.value;
    try {
      // final response = await _httpService.get(
      //   '/get_employee_list/$farmerId/$detailID',
      // );
      // final data = json.decode(response.body);
  final data =  {
      "id": 12,
      "name": "Bala",
      "profile": "",
      "joing_date": "12-02-2025",
      "user_name": "ruv",
      "password": "tets",
      "gender": "male",
      "role": "Employee",
      "salary_type": "regular",
      "salary": 1000,
      "mobile_number": 8608080510,
      "alternative_mobile_number": 8608080510,
      "email_id": "bala00@gmail.com",
      "pincode": 121312,
      "discription": "Hardworking employee with 2 years of experience in farm management."
    };
      return EmployeeDetailsModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<EmployeeDetailsModel> getManagerDetails(int detailID) async {
    try {
      // final farmerId = appData.userId.value;
      // final response = await _httpService.get(
      //   '/get_manager_list/$farmerId/$detailID',
      // );
      // final data = json.decode(response.body);
      final data =  {
      "id": 12,
      "name": "Bala",
      "profile": "",
      "joing_date": "12-02-2025",
      "user_name": null,
      "password": null,
      "gender": "male",
      "role": "Manger",
      "salary_type": "regular",
      "salary": 1000,
      "mobile_number": 8608080510,
      "alternative_mobile_number": 8608080510,
      "email_id": "bala00@gmail.com",
      "pincode": 121312,
      "discription": "Hardworking employee with 2 years of experience in farm management."
    };

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

  Future<EmployeeAdvanceResponse> getEmployeeAdvanceData(String employeeId) async {
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

  Future<EmployeeAdvanceResponse> updateEmployeeAdvance(UpdateAdvanceRequest request) async {
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