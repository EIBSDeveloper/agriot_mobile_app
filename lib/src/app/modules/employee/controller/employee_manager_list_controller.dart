import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/employee/model/user_model.dart';
import 'package:argiot/src/app/modules/employee/repository/employee_manager_repository.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class EmployeeManagerListController extends GetxController {
  final EmployeeManagerRepository _repository =
      Get.find<EmployeeManagerRepository>();
  
AppDataController  appDeta= Get.find();
  // Observables
  var isLoading = false.obs;
  var groupedData = <ManagerEmployeeGroup>[].obs;
  var filteredGroups = <ManagerEmployeeGroup>[].obs;
  var selectedRole = 'Employee'.obs;
  var searchQuery = ''.obs;
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      await loadGroupedData(reset: true);
    } catch (e) {
      
      Fluttertoast.showToast(msg: 'Failed to load data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGroupedData({
    bool reset = false,
    int? managerParam,
  }) async {
    try {
      if (reset) {
        currentPage.value = 1;
        groupedData.clear();
      }

      final response = await _repository.getGroupedEmployees(
        page: currentPage.value,
        searchQuery: searchQuery.value,
        managerParam: managerParam,
      );

      if (reset) {
        groupedData.value = response;
      } else {
        groupedData.addAll(response);
      }

      // Check if we have more data
      hasMoreData.value = response.isNotEmpty;

      _applyFilters();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadMoreData() async {
    if (!isLoading.value && hasMoreData.value) {
      currentPage.value++;
      await loadGroupedData(reset: false);
    }
  }

  void updateRoleFilter(String role) {
    selectedRole.value = role;
    _applyFilters();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    loadGroupedData(reset: true);
  }

  void _applyFilters() {
    if (selectedRole.value == 'All') {
      filteredGroups.value = List.from(groupedData);
    } else if (selectedRole.value == 'Manager') {
      filteredGroups.value = List.from(groupedData);
    } else if (selectedRole.value == 'Employee') {
      filteredGroups.value = groupedData
          .where((group) => group.employees.isNotEmpty)
          .toList();
    }
  }

  // Get all users for the current view (for compatibility)
  List<UserModel> getAllUsers() {
    final allUsers = <UserModel>[];
    
    for (var group in filteredGroups) {
      if (selectedRole.value == 'All' || selectedRole.value == 'Manager') {
        allUsers.add(group.manager.toUserModel());
      }
      if (selectedRole.value == 'All' || selectedRole.value == 'Employee') {
        allUsers.addAll(group.employees.map((e) => e.toUserModel()));
      }
    }
    
    return allUsers;
  }
void updateEmployeeStatus(int employeeId, int newStatus) {
  final updatedGroups = groupedData.map((group) {
    final updatedEmployees = group.employees.map((employee) {
      if (employee.id == employeeId) {
        return employee.copyWith(status: newStatus);
      }
      return employee;
    }).toList();

    return ManagerEmployeeGroup(
      manager: group.manager,
      employees: updatedEmployees,
    );
  }).toList();

  groupedData.value = updatedGroups;
  _applyFilters(); // refresh UI with updated data
}

  void initiateCall(String phoneNumber) {
    Fluttertoast.showToast(msg: 'Calling $phoneNumber');
    // You can use url_launcher here
  }

  Future<void> statusUpdate({required int id ,bool status=false}) async {
     await _repository.statusUpdate(id: id, scheduleStatus: status?0:1);
  }

  @override
  void onClose() {
    groupedData.close();
    filteredGroups.close();
    super.onClose();
  }
}