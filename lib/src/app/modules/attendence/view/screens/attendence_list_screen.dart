import 'package:argiot/src/app/modules/attendence/controller/attendence_controller.dart';
import 'package:argiot/src/app/modules/attendence/model/attendencemodel.dart';
import 'package:argiot/src/app/modules/attendence/view/widget/horizontal_calender_widget.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Attendancelistscreen extends GetView<AttendenceController> {
  const Attendancelistscreen({super.key});

  @override
  /*  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Attendence List'),
    */
  /* body: Obx(() {
      final employees = controller.employees;
      return employees.isEmpty
          ? const Center(child: Text("No employees found"))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final emp = employees[index];
                return employeeCard(emp);
              },
            );
    }),*/
  /*
    body: Obx(() {
      final employees = controller.employees;

      return RefreshIndicator(
        onRefresh: () async {
          // Call your API to reload the list
          await controller.loadEmployees(reset: true);
        },
        child: employees.isEmpty
            ? const Center(child: Text("No employees found"))
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final emp = employees[index];
                  return employeeCard(emp);
                },
              ),
      );
    }),
    // ✅ Floating Action Button
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        // Navigate to Add Attendance screen
        Get.toNamed(Routes.addAttendence);
      },
      backgroundColor: Get.theme.colorScheme.primary,
      child: const Icon(Icons.add), // attendance icon
    ),
  );*/
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Attendence List'),
    body: Column(
      children: [
        // 🚀 Calendar just below AppBar
        InputCardStyle(
          child: HorizontalDatePicker(
            onDateSelected: controller.setSelectedDate,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: InputCardStyle(
            child: TextField(
              controller: controller.searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, size: 22, color: Colors.grey),
                hintText: "Search employee...",
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: controller.onSearchChanged,
            ),
          ),
        ),

        // 🚀 Employee List
        Expanded(
          child: Obx(() {
            final employees = controller.employees;

            return RefreshIndicator(
              onRefresh: () async {
                await controller.loadEmployees(reset: true);
              },
              child: employees.isEmpty
                  ? const Center(child: Text("No employees found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final emp = employees[index];
                        return employeeCard(emp);
                      },
                    ),
            );
          }),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Get.toNamed(Routes.addAttendence);
      },
      backgroundColor: Get.theme.colorScheme.primary,
      child: const Icon(Icons.add),
    ),
  );
}

Widget employeeCard(EmployeeModel emp) => Card(
  margin: const EdgeInsets.symmetric(vertical: 6),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Profile Image or First Letter
        emp.image != null
            ? CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(emp.image!),
              )
            : CircleAvatar(
                radius: 25,
                child: Text(emp.name.isNotEmpty ? emp.name[0] : "?"),
              ),
        const SizedBox(width: 12),

        /// Employee Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emp.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(emp.role, style: const TextStyle(color: Colors.grey)),

              if (emp.workType != null)
                Text(
                  "Work Type: ${emp.workType}",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),

              Text(
                emp.salaryType,
                style: const TextStyle(color: Colors.blue, fontSize: 12),
              ),

              const SizedBox(height: 6),

              /// Attendance Details
              Text("Login: ${emp.loginTime ?? '-'}"),
              Text("Logout: ${emp.logoutTime ?? '-'}"),
              Text("Hours: ${emp.totalHour ?? '-'}"),

              const SizedBox(height: 6),

              /// Salary Info
              Text("Salary: ${emp.salary?.toStringAsFixed(2) ?? '0'}"),

              /// Paid/Unpaid
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  emp.salaryStatus == true ? "Paid" : "Unpaid",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: emp.salaryStatus == true ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
