import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/employee/model/user_model.dart';
import 'package:get/get.dart';

class EmployeeManagerRepository extends GetxController {
  // final HttpService _httpService = Get.find<HttpService>();

  final AppDataController appData = Get.find();

  Future<List<UserModel>> getEmployees({
    int page = 1,
    String searchQuery = '',
  }) async {
    try {
      // final farmerId = appData.userId.value;
      // String search = (searchQuery.isNotEmpty) ? "&'search'=$searchQuery" : '';
      // final response = await _httpService.get(
      //   "/get_employee_list/$farmerId? 'page'= ${page.toString()} $search",
      // );
      // final data = json.decode(response.body);
      final response = [
        {
          "id": 12,
          "name": "Bala",
          "role": "Employee",
          "number": 8608080510,
          "address": "123 Main Street, Chennai, Tamil Nadu",
          "profile": "https://example.com/profiles/bala.jpg",
        },
        {
          "id": 15,
          "name": "Priya Sharma",
          "role": "Employee",
          "number": 9876543210,
          "address": "456 Oak Avenue, Bangalore, Karnataka",
          "profile": "https://example.com/profiles/priya.jpg",
        },
        {
          "id": 18,
          "name": "Raj Kumar",
          "role": "Employee",
          "number": 8765432109,
          "address": "789 Pine Road, Mumbai, Maharashtra",
          "profile": "https://example.com/profiles/raj.jpg",
        },
        {
          "id": 22,
          "name": "Anita Patel",
          "role": "Employee",
          "number": 7654321098,
          "address": "321 Elm Street, Delhi, Delhi",
          "profile": "https://example.com/profiles/anita.jpg",
        },
        {
          "id": 25,
          "name": "Suresh Reddy",
          "role": "Employee",
          "number": 6543210987,
          "address": "654 Maple Lane, Hyderabad, Telangana",
          "profile": "https://example.com/profiles/suresh.jpg",
        },
      ];
      return response.map((item) => UserModel.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getManagers({
    int page = 1,
    String searchQuery = '',
  }) async {
    try {
      // final farmerId = appData.userId.value;
      // String search = (searchQuery.isNotEmpty) ? "&'search'=$searchQuery" : '';
      // final response = await _httpService.get(
      //   "/get_manager_list/$farmerId? 'page'= ${page.toString()} $search",
      // );
      // final data = json.decode(response.body);

      final response = [
        {
          "id": 5,
          "name": "Manager Arjun",
          "role": "Manager",
          "number": 8908080510,
          "address": "101 Corporate Tower, Chennai, Tamil Nadu",
          "profile": "https://example.com/profiles/arjun.jpg",
        },
        {
          "id": 8,
          "name": "Manager Sneha",
          "role": "Manager",
          "number": 9123456780,
          "address": "202 Business Park, Bangalore, Karnataka",
          "profile": "https://example.com/profiles/sneha.jpg",
        },
        {
          "id": 11,
          "name": "Manager Vikram",
          "role": "Manager",
          "number": 9234567891,
          "address": "303 Tech Park, Pune, Maharashtra",
          "profile": "https://example.com/profiles/vikram.jpg",
        },
      ];
      return response.map((item) => UserModel.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
