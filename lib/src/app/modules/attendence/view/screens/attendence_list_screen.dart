import 'package:argiot/src/app/modules/attendence/controller/attendence_controller.dart';
import 'package:argiot/src/app/modules/attendence/model/attendencemodel.dart';
import 'package:argiot/src/app/modules/attendence/view/widget/horizontal_calender_widget.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Attendancelistscreen extends GetView<AttendenceController> {
  const Attendancelistscreen({super.key});

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
    floatingActionButton: Obx(() {
      if (controller.appDeta.permission.value?.attendance?.add == 0) {
        return const SizedBox();
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selected = DateTime(
        controller.selectedDate.value.year,
        controller.selectedDate.value.month,
        controller.selectedDate.value.day,
      );

      return selected == today
          ? FloatingActionButton(
              onPressed: () {
                Get.toNamed(Routes.addAttendence)?.then((result) {
                  controller.loadEmployees(reset: true);
                });
              },
              backgroundColor: Get.theme.colorScheme.primary,
              child: const Icon(Icons.add),
            )
          : const SizedBox();
    }),
  );
}

Widget employeeCard(EmployeeModel emp) => Card(
  elevation: 1,
  child: Padding(
    padding: const EdgeInsets.all(10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Profile Image
        emp.image != null
            ? CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(emp.image!),
              )
            : CircleAvatar(
                radius: 25,
                backgroundColor: Get.theme.colorScheme.primary.withAlpha(80),
                child: Text(
                  emp.name.isNotEmpty ? emp.name[0].toUpperCase() : "?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ),

        const SizedBox(width: 16),

        /// Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Name + Role
              Row(
                children: [
                  Text(
                    capitalizeFirstLetter(emp.name),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (emp.workType != null) ...[
                    const SizedBox(height: 4),
                    Text(emp.workType!, style: const TextStyle(fontSize: 10)),
                  ],
                ],
              ),

              const SizedBox(height: 6),

              /// Attendance Row
              Row(
                children: [
                  // Icon(
                  //   Icons.login,
                  //   size: 23,
                  //   color: Get.theme.colorScheme.primary,
                  // ),
                  const SizedBox(width: 4),
                  Text(
                    "${emp.loginTime?.split(":")[0] ?? '-'}:${emp.loginTime?.split(":")[1] ?? '-'}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 10),
                  // Icon(
                  //   Icons.logout,
                  //   size: 23,
                  //   color: Get.theme.colorScheme.primary,
                  // ),
                  const Text("to"),
                  const SizedBox(width: 10),
                  Text(
                    "${emp.logoutTime?.split(":")[0] ?? '-'}:${emp.logoutTime?.split(":")[1] ?? '-'}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  // Text(
                  //   emp.logoutTime ?? '-',
                  //   style: const TextStyle(fontSize: 13),
                  // ),
                ],
              ),

              const SizedBox(height: 4),
              if (emp.totalHour != null)
                Row(
                  children: [
                    const Text("Working Hours"),
                    const SizedBox(width: 4),
                    Text(
                      emp.totalHour ?? '-',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),

              const SizedBox(height: 4),

              /// Salary & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text("Salary "),
                      const SizedBox(width: 4),
                      Text(
                        emp.salary ?? '0',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:
                          (emp.salaryStatus == true
                                  ? Get.theme.colorScheme.primary
                                  : Colors.red)
                              .withAlpha(100),
                    ),
                    child: Text(
                      emp.salaryStatus == true ? "Paid" : "Unpaid",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: emp.salaryStatus == true
                            ? Get.theme.colorScheme.primary
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
