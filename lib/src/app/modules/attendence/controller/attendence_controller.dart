import 'dart:convert';

import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/attendence/model/attendencemodel.dart';
import 'package:argiot/src/app/modules/attendence/repository/attendence_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final AppDataController appDeta = Get.put(AppDataController());

class AttendenceController extends GetxController {
  final AttendanceRepository repository = Get.find();
  TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;
  TextEditingController dateController = TextEditingController();
  var selectedDate = DateTime.now().obs;
  RxString currentMonthYear = DateFormat.yMMMM().format(DateTime.now()).obs;

  /* var employees = <EmployeeModel>[
    EmployeeModel(
      id: 1,
      name: "Raghu E",
      role: "Planting Work",
      salaryType: "Monthly Salaries",
      login: "6:00 AM",
      logout: "6:00 PM",
      salary: 20000,
      paidStatus: true,
    ),
    EmployeeModel(
      id: 2,
      name: "Suresh V",
      role: "Cultivating Work",
      salaryType: "Daily Wages",
      login: "7:00 AM",
      logout: "7:00 PM",
      paidStatus: false,
    ),
    EmployeeModel(
      id: 3,
      name: "Ramesh V",
      role: "Planting Work",
      salaryType: "Monthly Salaries",
      login: "6:00 AM",
      logout: "6:00 PM",
      salary: 20000,
      paidStatus: true,
    ),
    EmployeeModel(
      id: 4,
      name: "Kumaresh V",
      role: "Cultivating Work",
      salaryType: "Daily Wages",
      login: "7:00 AM",
      logout: "7:00 PM",
      salary: 10000,
      paidStatus: false,
    ),
  ].obs;*/
  var employees = <EmployeeModel>[].obs;

  // Persistent TextControllers for login/logout and salary
  var loginControllers = <int, TextEditingController>{}.obs;
  var logoutControllers = <int, TextEditingController>{}.obs;
  var salaryControllers = <int, TextEditingController>{}.obs;

  final DateFormat timeFormat = DateFormat("hh:mm a");

  @override
  void onInit() {
    super.onInit();
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    // 🚀 Call API to load employees
    loadEmployeeslist();

    for (int i = 0; i < employees.length; i++) {
      loginControllers[i] = TextEditingController(text: employees[i].login);
      logoutControllers[i] = TextEditingController(text: employees[i].logout);
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
        emp = emp.copyWith(login: formatted, logout: null, hours: null);
        loginControllers[index]?.text = formatted;
        logoutControllers[index]?.clear();
      } else {
        if (emp.login == null) {
          Fluttertoast.showToast(
            msg: "Please select Login Time first",
            backgroundColor: Get.theme.colorScheme.primary,
            textColor: Colors.white,
          );
          return;
        }
        emp = emp.copyWith(
          logout: formatted,
          hours: _calculateWorkingHours(emp.login!, formatted),
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
    final minutesWorked = diff.inMinutes.remainder(60);

    return "$hoursWorked h $minutesWorked m";
  }

  /// Set Paid/Unpaid
  void setStatus(int index, bool isPaid) {
    var emp = employees[index];
    emp = emp.copyWith(paidStatus: isPaid);
    employees[index] = emp;
    employees.refresh();
  }

  /// Submit attendance (all or single)
  void submitAttendance({int? singleIndex}) {
    final List<Map<String, dynamic>> attendanceList = singleIndex != null
        ? [employees[singleIndex].toJson()]
        : employees.map((e) => e.toJson()).toList();

    // Print JSON in console
    debugPrint("Attendance JSON: ${jsonEncode(attendanceList)}");
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
    dateController.text = DateFormat('dd/MM/yyyy').format(date);
  }

  void updateMonthYear(DateTime date) {
    currentMonthYear.value = DateFormat.yMMMM().format(date);
  }

  /// 🔥 Fetch Employees from API
  Future<void> loadEmployeeslist() async {
    final date = dateController.text; // current selected date
    final fetchedEmployees = await repository.fetchEmployees(date: date);

    employees.assignAll(fetchedEmployees);

    // Setup controllers
    loginControllers.clear();
    logoutControllers.clear();
    salaryControllers.clear();

    for (var i = 0; i < employees.length; i++) {
      loginControllers[i] = TextEditingController(text: employees[i].login);
      logoutControllers[i] = TextEditingController(text: employees[i].logout);
      salaryControllers[i] = TextEditingController(
        text: employees[i].salary?.toString() ?? '',
      );
    }
  }
}
