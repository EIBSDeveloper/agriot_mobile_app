import 'dart:convert';

import 'package:argiot/src/app/modules/employee/model/model.dart';
import 'package:argiot/src/app/modules/employee/repository/update_employee_payouts_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../controller/app_controller.dart';
import '../../../routes/app_routes.dart';
import '../../manager/model/dropdown_model.dart';

class UpdateEmployeePayoutsController extends GetxController {
  final UpdateEmployeePayoutsRepository _repository =
      UpdateEmployeePayoutsRepository();

  final AppDataController appDeta = Get.put(AppDataController());

  final RxBool isLoading = false.obs;
  final RxBool employeeDataIsLoading = false.obs;
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

  final  payoutType =  Rxn<DrapDown>();
  var selectedEmployeeType = Rxn<DrapDown>();
  var selectedWorkType = Rxn<DrapDown>();
  var selectedEmoployee = Rxn<DrapDown>();
  var selectedManager = Rxn<DrapDown>();

  var employeeTypes = <DrapDown>[].obs;
  var workTypes = <DrapDown>[].obs;
  var managers = <DrapDown>[].obs;
  var employee = <DrapDown>[].obs;
   final RxList<DrapDown> payoutTypes = [
    DrapDown(id: 1, name: 'advance'),
    DrapDown(id: 2, name: 'regular_payouts'),
  ].obs;


  @override
  void onInit() {
    super.onInit();
    fetchDropdownData();
    payoutType.value = payoutTypes.first;
  }

  Future<void> loadEmployeeData() async {
    try {
      employeeDataIsLoading.value = true;
      errorMessage.value = '';

      final employeeId = selectedEmoployee.value!.id;
      final response = await _repository.getEmployeePayoutsData(employeeId);

      if (response != null) {
        employeeData.value = response;
      } else {
        // errorMessage.value = response.message;
        // Fluttertoast.showToast(msg: response.message);
        errorMessage.value = 'Failed to load employee data';
        Fluttertoast.showToast(msg: 'Failed to load employee data');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load employee data';
      Fluttertoast.showToast(msg: 'Failed to load employee data');
    } finally {
      employeeDataIsLoading.value = false;
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
      await getEmployeeType();

      //fetch worktypes
      await getworkType();
    } catch (e) {
      print("Error fetching dropdown data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getEmployeeType() async {
    final empRes = await http.get(
      Uri.parse("${appDeta.baseUrl.value}/employee_types"),
    );
    if (empRes.statusCode == 200) {
      final List data = jsonDecode(empRes.body);
      employeeTypes.value = data.map((e) => DrapDown.fromJson(e)).toList();
    }
  }

  Future<void> getworkType() async {
    final worktypeRes = await http.get(
      Uri.parse("${appDeta.baseUrl.value}/work_type"),
    );
    if (worktypeRes.statusCode == 200) {
      final List data = jsonDecode(worktypeRes.body);
      workTypes.value = data.map((e) => DrapDown.fromJson(e)).toList();
    }
  }

  Future<void> getEmployee() async {
    final worktypeRes = await http.get(
      Uri.parse(
        "${appDeta.baseUrl.value}/employee_by_fermer/${appDeta.farmerId.value}?employee_type=${selectedEmployeeType.value!.id}&work_type=${selectedWorkType.value!.id}",
      ),
    );
    if (worktypeRes.statusCode == 200) {
      final List data = jsonDecode(worktypeRes.body);
      employee.value = data.map((e) => DrapDown.fromJson(e)).toList();
    }
  }

  Future<void> updatePayouts() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      var totelAdvance =
          ((employeeData.value?.advanceAmount ?? 0) +
                  (int.tryParse(payoutsAmount.value) ?? 0))
              .toString();
      final request = UpdatePayoutsRequest(
        id: null,
        advanceAmount: totelAdvance,
        balanceAdvance: "",
        paidSalary: "0",
        payoutAmount: "0",
        previousAdvanceAmount: employeeData.value!.advanceAmount.toString(),
        unpaidSalary: "0",
        employeeId: selectedEmoployee.value!.id,
        employeeWorkType: selectedWorkType.value!.id,
        dateOfPayouts: dateOfPayouts.value,
        deductionAdvanceAmount: double.parse(deductionAdvanceAmount.value),
        payoutsAmount: double.parse(payoutsAmount.value),
        toPay: toPay.isNotEmpty ? double.parse(toPay.value) : null,
        description: description.value.isEmpty ? null : description.value,
      );

      final response = await _repository.updateEmployeePayouts(request);

      if (response != null) {
        Fluttertoast.showToast(msg: 'payouts_updated_success'.tr);

        Get.back(result: true);
        Get.toNamed(
          Routes.employeeDetails,
          arguments: {'employeeId': response, 'isManager': false},
        );
      } else {
        Fluttertoast.showToast(msg: "Try again");
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
