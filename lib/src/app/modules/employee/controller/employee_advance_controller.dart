import 'package:argiot/src/app/modules/employee/model/model.dart';
import 'package:argiot/src/app/modules/employee/repository/employee_details_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class EmployeeAdvanceController extends GetxController {
  final EmployeeAdvanceRepository _repository = EmployeeAdvanceRepository();
  
  final RxBool isLoading = false.obs;
  final RxBool isLoadingEmployees = false.obs;
  final RxList<Employee> employees = <Employee>[].obs;
  final Rx<EmployeeAdvanceData?> employeeData = Rx<EmployeeAdvanceData?>(null);
  final RxString errorMessage = ''.obs;
  
  // Form fields
  final RxString selectedEmployeeType = ''.obs;
  final Rx<Employee?> selectedEmployee = Rx<Employee?>(null);
  final RxString advanceAmount = ''.obs;
  final RxString description = ''.obs;
  
  // Employee type options
  final List<String> employeeTypes = [
    'Monthly Salaries',
    'Hourly Work',
    'Contract'
  ];
  
  // Validation errors
  final RxString employeeTypeError = ''.obs;
  final RxString employeeError = ''.obs;
  final RxString advanceAmountError = ''.obs;

  // Computed total advance
  double get totalAdvance {
    final previous = employeeData.value?.previousAdvance ?? 0.0;
    final newAdvance = double.tryParse(advanceAmount.value) ?? 0.0;
    return previous + newAdvance;
  }

  @override
  void onInit() {
    super.onInit();
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    try {
      isLoadingEmployees.value = true;
      errorMessage.value = '';
      
      final employeesList = await _repository.getEmployees();
      employees.assignAll(employeesList);
    } catch (e) {
      errorMessage.value = 'Failed to load employees';
      Fluttertoast.showToast(msg: 'Failed to load employees');
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  Future<void> loadEmployeeData(String employeeId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _repository.getEmployeeAdvanceData(employeeId);
      
      if (response.status) {
        employeeData.value = response.data;
        // Pre-fill employee type if available
        if (response.data?.employeeType.isNotEmpty == true) {
          selectedEmployeeType.value = response.data!.employeeType;
        }
      } else {
        errorMessage.value = response.message;
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load employee data';
      Fluttertoast.showToast(msg: 'Failed to load employee data');
    } finally {
      isLoading.value = false;
    }
  }

  bool validateForm() {
    bool isValid = true;
    
    // Reset errors
    employeeTypeError.value = '';
    employeeError.value = '';
    advanceAmountError.value = '';
    
    // Employee type validation
    if (selectedEmployeeType.isEmpty) {
      employeeTypeError.value = 'employee_type_required'.tr;
      isValid = false;
    }
    
    // Employee validation
    if (selectedEmployee.value == null) {
      employeeError.value = 'employee_required'.tr;
      isValid = false;
    }
    
    // Advance amount validation
    if (advanceAmount.isEmpty) {
      advanceAmountError.value = 'advance_amount_required'.tr;
      isValid = false;
    } else if (double.tryParse(advanceAmount.value) == null) {
      advanceAmountError.value = 'valid_number_required'.tr;
      isValid = false;
    } else if (double.parse(advanceAmount.value) < 0) {
      advanceAmountError.value = 'positive_number_required'.tr;
      isValid = false;
    }
    
    return isValid;
  }

  Future<void> updateEmployeeAdvance() async {
    if (!validateForm()) return;
    
    try {
      isLoading.value = true;
      
      final request = UpdateAdvanceRequest(
        employeeId: selectedEmployee.value!.id,
        employeeType: selectedEmployeeType.value,
        advanceAmount: double.parse(advanceAmount.value),
        totalAdvance: totalAdvance,
        description: description.value.isEmpty ? null : description.value,
      );
      
      final response = await _repository.updateEmployeeAdvance(request);
      
      if (response.status) {
        Fluttertoast.showToast(msg: 'advance_updated_success'.tr);
        Get.back(result: true);
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'update_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void cancel() {
    clearForm();
    Get.back();
  }

  void clearForm() {
    selectedEmployeeType.value = '';
    selectedEmployee.value = null;
    advanceAmount.value = '';
    description.value = '';
    
    employeeTypeError.value = '';
    employeeError.value = '';
    advanceAmountError.value = '';
  }

  void updateEmployeeType(String? type) {
    if (type != null) {
      selectedEmployeeType.value = type;
      employeeTypeError.value = '';
    }
  }

  void updateEmployee(Employee? employee) {
    selectedEmployee.value = employee;
    employeeError.value = '';
    
    if (employee != null) {
      loadEmployeeData(employee.id);
    } else {
      employeeData.value = null;
    }
  }

  void updateAdvanceAmount(String value) {
    advanceAmount.value = value;
    if (value.isNotEmpty) advanceAmountError.value = '';
  }

  void updateDescription(String value) {
    description.value = value;
  }
}