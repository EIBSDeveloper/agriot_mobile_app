import 'package:argiot/src/app/modules/attendence/controller/attendence_controller.dart';
import 'package:argiot/src/app/modules/attendence/model/attendencemodel.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Attendancelistscreen extends GetView<AttendenceController> {
  const Attendancelistscreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Attendence List'),
    body: Obx(() {
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
  );
}

/*Widget employeeCard(EmployeeModel emp) => Card(
  margin: const EdgeInsets.symmetric(vertical: 6),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        CircleAvatar(radius: 25, child: Text(emp.name[0])),
        const SizedBox(width: 12),
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
              Text(
                emp.salaryType,
                style: const TextStyle(color: Colors.blue, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text("Salary: ${emp.salary ?? 0}"),
              Text("Hours: ${emp.hours ?? '-'}"),
            ],
          ),
        ),
        Text(
          emp.paidStatus == true ? "Paid" : "Unpaid",
          style: TextStyle(color: Get.theme.colorScheme.primary),
        ),
      ],
    ),
  ),
);*/
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
              Text("Login: ${emp.login ?? '-'}"),
              Text("Logout: ${emp.logout ?? '-'}"),
              Text("Hours: ${emp.hours ?? '-'}"),

              const SizedBox(height: 6),

              /// Salary Info
              Text("Salary: ${emp.salary?.toStringAsFixed(2) ?? '0'}"),

              /// Paid/Unpaid
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  emp.paidStatus == true ? "Paid" : "Unpaid",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: emp.paidStatus == true ? Colors.green : Colors.red,
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
