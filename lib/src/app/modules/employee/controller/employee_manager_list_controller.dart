import 'package:argiot/src/app/modules/employee/model/user_model.dart';
import 'package:argiot/src/app/modules/employee/repository/employee_manager_repository.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';



class EmployeeManagerListController extends GetxController {
  final EmployeeManagerRepository _repository =
      Get.find<EmployeeManagerRepository>();
  // Observables
  var isLoading = false.obs;
  var employees = <UserModel>[].obs;
  var managers = <UserModel>[].obs;
  var filteredUsers = <UserModel>[].obs;
  var selectedRole = 'Manager'.obs;
  var searchQuery = ''.obs;

  // Storage keys
  final String farmerIdKey = 'farmer_id';

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;

      await Future.wait([loadEmployees(), loadManagers()]);

      _applyFilters();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadEmployees() async {
    try {
      final response = await _repository.getEmployees(
        searchQuery: searchQuery.value,
      );
      employees.value = response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadManagers() async {
    try {
      final response = await _repository.getManagers(
        searchQuery: searchQuery.value,
      );
      managers.value = response;
    } catch (e) {
      rethrow;
    }
  }

  void updateRoleFilter(String role) {
    selectedRole.value = role;
    _applyFilters();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    List<UserModel> allUsers = [];

    if (selectedRole.value == 'All' || selectedRole.value == 'Employee') {
      allUsers.addAll(employees);
    }
    if (selectedRole.value == 'All' || selectedRole.value == 'Manager') {
      allUsers.addAll(managers);
    }

    if (searchQuery.value.isNotEmpty) {
      filteredUsers.value = allUsers
          .where(
            (user) => user.name.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    } else {
      filteredUsers.value = allUsers;
    }
  }

  void initiateCall(String phoneNumber) {
    // Implementation for phone call
    Fluttertoast.showToast(msg: 'Calling $phoneNumber');
    // You can use url_launcher here
  }

  @override
  void onClose() {
    employees.close();
    managers.close();
    filteredUsers.close();
    super.onClose();
  }
}
