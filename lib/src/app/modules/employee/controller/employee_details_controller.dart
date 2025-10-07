import 'package:argiot/src/app/modules/employee/repository/employee_details_repository.dart';
import 'package:argiot/src/app/modules/employee/model/employee_details_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class EmployeeDetailsController extends GetxController {
  final EmployeeDetailsRepository _repository =
      Get.find<EmployeeDetailsRepository>();
  RxInt employeeId = 0.obs;
  RxBool isManager = false.obs;
  
  // Observables
  var isLoading = false.obs;
  var employeeDetails = Rx<EmployeeDetailsModel?>(null);

  // Storage keys
  final String farmerIdKey = 'farmer_id';
  @override
  void onInit() {
    super.onInit();
    employeeId.value = Get.arguments['employeeId'];
    isManager.value = Get.arguments['isManager'] ?? false;
    loadEmployeeDetails();
  }


  Future<void> loadEmployeeDetails() async {
    try {
      isLoading.value = true;

      EmployeeDetailsModel response;

      if (isManager.value) {
        response = await _repository.getManagerDetails(employeeId.value);
      } else {
        response = await _repository.getEmployeeDetails(employeeId.value);
      }

      // if (response.isNotEmpty) {
      employeeDetails.value = response;
      // } else {
      //   Fluttertoast.showToast(msg: 'Employee details not found'.tr);
      // }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load details: ${e.toString()}'.tr);
    } finally {
      isLoading.value = false;
    }
  }


  

  @override
  void onClose() {
    employeeDetails.close();
    super.onClose();
  }
}
