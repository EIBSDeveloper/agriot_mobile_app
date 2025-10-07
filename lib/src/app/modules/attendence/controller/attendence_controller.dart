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

  // Persistent TextControllers for login/logout and salary
  var loginControllers = <int, TextEditingController>{}.obs;
  var logoutControllers = <int, TextEditingController>{}.obs;
  var salaryControllers = <int, TextEditingController>{}.obs;

  //final DateFormat timeFormat = DateFormat("hh:mm a");
  final DateFormat timeFormat = DateFormat("HH:mm:ss"); // 24-hour format
  @override
  void onInit() {
    super.onInit();
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    // 🚀 Call API to load employees
    loadEmployees();

    for (int i = 0; i < employees.length; i++) {
      loginControllers[i] = TextEditingController(text: employees[i].loginTime);
      logoutControllers[i] = TextEditingController(
        text: employees[i].logoutTime,
      );
      salaryControllers[i] = TextEditingController(
        text: employees[i].salary?.toString() ?? '',
      );
    }
  }

  /// Pick login/logout time
  Future<void> pickTime(int index, bool isLogin, BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      final formatted = timeFormat.format(
        DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
      );

      var emp = employees[index];

      if (isLogin) {
        emp = emp.copyWith(
          loginTime: formatted,
          logoutTime: null,
          totalHour: null,
        );
        loginControllers[index]?.text = formatted;
        logoutControllers[index]?.clear();
      } else {
        if (emp.loginTime == null) {
          Fluttertoast.showToast(
            msg: "Please select Login Time first",
            backgroundColor: Get.theme.colorScheme.primary,
            textColor: Colors.white,
          );
          return;
        }
        emp = emp.copyWith(
          logoutTime: formatted,
          totalHour: _calculateWorkingHours(emp.loginTime!, formatted),
        );
        logoutControllers[index]?.text = formatted;
      }

      employees[index] = emp;
      employees.refresh();
    }
  }

  String _calculateWorkingHours(String login, String logout) {
    final loginTime = timeFormat.parse(login);
    var logoutTime = timeFormat.parse(logout);

    if (logoutTime.isBefore(loginTime)) {
      logoutTime = logoutTime.add(const Duration(days: 1));
    }

    final diff = logoutTime.difference(loginTime);
    final hoursWorked = diff.inHours;

    return "$hoursWorked hrs";
  }

  /// Set Paid/Unpaid
  void setStatus(int index, bool isPaid) {
    var emp = employees[index];
    emp = emp.copyWith(salaryStatus: isPaid);
    employees[index] = emp;
    employees.refresh();
  }

  void updateMonthYear(DateTime date) {
    currentMonthYear.value = DateFormat.yMMMM().format(date);
  }

  /// Fetch Employees with pagination
  Future<void> loadEmployees({bool reset = false}) async {
    if (reset) {
      page.value = 1;
      hasMore.value = true;
      employees.clear();
      loginControllers.clear();
      logoutControllers.clear();
      salaryControllers.clear();
    }

    if (!hasMore.value) return;

    isLoading.value = true;
    try {
      final fetched = await repository.fetchEmployees(
        date: DateFormat('yyyy-MM-dd').format(selectedDate.value),
        page: page.value,
        search: searchQuery.value,
      );

      if (fetched.length < 20) hasMore.value = false;

      // 🚀 Add new data without duplicates
      for (var emp in fetched) {
        if (!employees.any((e) => e.id == emp.id)) {
          employees.add(emp);
        }
      }

      // Initialize controllers
      for (var i = 0; i < employees.length; i++) {
        loginControllers[i] ??= TextEditingController(
          text: employees[i].loginTime ?? '',
        );
        logoutControllers[i] ??= TextEditingController(
          text: employees[i].logoutTime ?? '',
        );
        salaryControllers[i] ??= TextEditingController(
          text: employees[i].salary?.toString() ?? '',
        );
      }

      page.value += 1;
    } catch (e) {
      debugPrint("⚠️ Error loading employees: $e");
    } finally {
      isLoading.value = false;
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

  Future<void> addAttendance({required List<EmployeeModel> employees}) async {
    final employeeList = employees
        .where((e) => e.isEdited == true)
        .map((e) => e.toJson())
        .toList(); // call toJson()

    bool success = await repository.addAttendance(employees: employeeList);

    if (success) {
      showSuccess('Attendence Added successfully');
      await loadEmployees(); // refresh list
    } else {
      showError('Failed to submit');
    }
  }
}
