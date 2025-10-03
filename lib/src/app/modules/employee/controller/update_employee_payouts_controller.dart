import 'dart:convert';

import 'package:argiot/src/app/modules/employee/model/model.dart';
import 'package:argiot/src/app/modules/employee/repository/update_employee_payouts_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../controller/app_controller.dart';
import '../../manager/model/dropdown_model.dart';

class UpdateEmployeePayoutsController extends GetxController {
  final UpdateEmployeePayoutsRepository _repository = UpdateEmployeePayoutsRepository();
  
final AppDataController appDeta = Get.put(AppDataController());

  final RxBool isLoading = false.obs;
  final Rx<EmployeePayoutsData?> employeeData = Rx<EmployeePayoutsData?>(null);
  final RxString errorMessage = ''.obs;
  
  // Form fields
  final RxString dateOfPayouts = ''.obs;
  final RxString deductionAdvanceAmount = '0'.obs;
  final RxString payoutsAmount = ''.obs;
  final RxString toPay = ''.obs;
  final RxString description = ''.obs;
  
  // Validation errors
  final RxString dateError = ''.obs;
  final RxString deductionError = ''.obs;
  final RxString payoutsError = ''.obs;
  final RxString toPayError = ''.obs;
  final RxString payoutType = 'Advance'.obs;

  var selectedEmployeeType = Rxn<EmployeeTypeModel>();
  var selectedWorkType = Rxn<WorkTypeModel>();
  var selectedManager = Rxn<AssignMangerModel>();

  var employeeTypes = <EmployeeTypeModel>[].obs;
  var workTypes = <WorkTypeModel>[].obs;
  var managers = <AssignMangerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
   fetchDropdownData() ;
  }


  Future<void> loadEmployeeData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final employeeId = Get.parameters['employeeId'] ?? '';
      final response = await _repository.getEmployeePayoutsData(employeeId);
      
      if (response.status) {
        employeeData.value = response.data;
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
    dateError.value = '';
    deductionError.value = '';
    payoutsError.value = '';
    toPayError.value = '';
    
    // Date validation
    if (dateOfPayouts.isEmpty) {
      dateError.value = 'date_required'.tr;
      isValid = false;
    }
    
    // Deduction amount validation
    if (deductionAdvanceAmount.isEmpty) {
      deductionError.value = 'deduction_required'.tr;
      isValid = false;
    } else if (double.tryParse(deductionAdvanceAmount.value) == null) {
      deductionError.value = 'valid_number_required'.tr;
      isValid = false;
    } else if (double.parse(deductionAdvanceAmount.value) < 0) {
      deductionError.value = 'positive_number_required'.tr;
      isValid = false;
    }
    
    // Payouts amount validation
    if (payoutsAmount.isEmpty) {
      payoutsError.value = 'payouts_required'.tr;
      isValid = false;
    } else if (double.tryParse(payoutsAmount.value) == null) {
      payoutsError.value = 'valid_number_required'.tr;
      isValid = false;
    } else if (double.parse(payoutsAmount.value) < 0) {
      payoutsError.value = 'positive_number_required'.tr;
      isValid = false;
    }
    
 
  
    // To Pay validation (optional)
    if (toPay.isNotEmpty && double.tryParse(toPay.value) == null) {
      toPayError.value = 'valid_number_required'.tr;
      isValid = false;
    }
    
    return isValid;
  }
 Future<void> fetchDropdownData() async {
    isLoading.value = true;

    try {
      /// Fetch employee types
      final empRes = await http.get(
        Uri.parse("${appDeta.baseUrl.value}/employee_types"),
      );
      if (empRes.statusCode == 200) {
        final List data = jsonDecode(empRes.body);
        employeeTypes.value = data
            .map((e) => EmployeeTypeModel.fromJson(e))
            .toList();
      }

     
    
      //fetch worktypes
      final worktypeRes = await http.get(
        Uri.parse("${appDeta.baseUrl.value}/work_type"),
      );
      if (worktypeRes.statusCode == 200) {
        final List data = jsonDecode(worktypeRes.body);
        workTypes.value = data.map((e) => WorkTypeModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching dropdown data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePayouts() async {
    if (!validateForm()) return;
    
    try {
      isLoading.value = true;
      
      final request = UpdatePayoutsRequest(
        employeeId: Get.parameters['employeeId'] ?? '',
        dateOfPayouts: dateOfPayouts.value,
        deductionAdvanceAmount: double.parse(deductionAdvanceAmount.value),
        payoutsAmount: double.parse(payoutsAmount.value),
        toPay: toPay.isNotEmpty ? double.parse(toPay.value) : null,
        description: description.value.isEmpty ? null : description.value,
      );
      
      final response = await _repository.updateEmployeePayouts(request);
      
      if (response.status) {
        Fluttertoast.showToast(msg: 'payouts_updated_success'.tr);
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
    dateOfPayouts.value = '';
    deductionAdvanceAmount.value = '';
    payoutsAmount.value = '';
    toPay.value = '';
    description.value = '';
    
    dateError.value = '';
    deductionError.value = '';
    payoutsError.value = '';
    toPayError.value = '';
  }

  void updateDate(String date) {
    dateOfPayouts.value = date;
    dateError.value = '';
  }

  void updateDeductionAmount(String value) {
    deductionAdvanceAmount.value = value;
    if (value.isNotEmpty) deductionError.value = '';
  }

  void updatePayoutsAmount(String value) {
    payoutsAmount.value = value;
    if (value.isNotEmpty) payoutsError.value = '';
  }

  void updateToPay(String value) {
    toPay.value = value;
    if (value.isNotEmpty) toPayError.value = '';
  }

  void updateDescription(String value) {
    description.value = value;
  }
}