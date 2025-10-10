import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/attendence/model/attendencemodel.dart';
import 'package:argiot/src/app/modules/attendence/repository/attendence_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../service/utils/pop_messages.dart';

final AppDataController appDeta = Get.put(AppDataController());

class AttendenceController extends GetxController {
  final AttendanceRepository repository = Get.find();
  TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;
  var page = 1.obs;
  var hasMore = true.obs;
  TextEditingController dateController = TextEditingController();
  var selectedDate = DateTime.now().obs;
  RxString currentMonthYear = DateFormat.yMMMM().format(DateTime.now()).obs;

  var employees = <EmployeeModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());

    loadEmployees();
  }

  void updateMonthYear(DateTime date) {
    currentMonthYear.value = DateFormat.yMMMM().format(date);
  }

  /// Fetch Employees with pagination
  Future<void> loadEmployees({bool reset = false }) async {
    if (reset) {
      page.value = 1;
      hasMore.value = true;
      employees.clear();

      if (!hasMore.value) return;

      isLoading.value = true;
      try {
        final fetched = await repository.fetchEmployees(
          date: DateFormat('yyyy-MM-dd').format(selectedDate.value),
          page: page.value,
          search: searchQuery.value,
          onlyUpdated: true
          
        );

        if (fetched.length < 20) hasMore.value = false;

        // 🚀 Add new data without duplicates
        for (var emp in fetched) {
          if (!employees.any((e) => e.id == emp.id)) {
            employees.add(emp);
          }
        }

        page.value += 1;
      } catch (e) {
        debugPrint("⚠️ Error loading employees: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// Called when search text changes
  void onSearchChanged(String query) {
    searchQuery.value = query.toLowerCase();

    loadEmployees(reset: true);
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date; // update observable
    dateController.text = DateFormat('dd-MM-yyyy').format(date);
    loadEmployees(reset: true);
  }
}
