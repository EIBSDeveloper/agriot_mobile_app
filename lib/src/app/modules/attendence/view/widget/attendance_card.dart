import 'package:argiot/src/app/modules/attendence/controller/attendence_controller.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/attendence_add_controller.dart';



class AttendanceCard extends GetView<AttendenceAddController> {
  final int index;

  const AttendanceCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) => Obx(() {
    final emp = controller.employees[index];

    // Calculate salary if totalHour & salaryPerHour are available
    int workingHours = 0;
    if (emp.totalHour != null && emp.totalHour!.isNotEmpty) {
      final parts = emp.totalHour!.split(" "); // "8 hrs"
      workingHours = int.tryParse(parts[0]) ?? 0;
    }

    final calculatedSalary =
        workingHours * (int.tryParse(emp.salary ?? '0') ?? 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Employee Info
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage("assets/avatar.png"),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      emp.salaryType,
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// Login / Logout
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => controller.pickTime(index, true, context),
                    child: InputCardStyle(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*const Text(
                              "Login Time",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),*/
                            const SizedBox(height: 4),
                            Text(
                              emp.loginTime?.isNotEmpty == true
                                  ? emp.loginTime!
                                  : "Select Login Time",
                              style: TextStyle(
                                fontSize: 14,
                                color: emp.loginTime?.isNotEmpty == true
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => controller.pickTime(index, false, context),
                    child: InputCardStyle(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              emp.logoutTime?.isNotEmpty == true
                                  ? emp.logoutTime!
                                  : "Select Logout Time",
                              style: TextStyle(
                                fontSize: 14,
                                color: emp.logoutTime?.isNotEmpty == true
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            /// Working Hours & Salary
            Row(
              children: [
                Expanded(
                  child: InputCardStyle(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Text(
                        emp.totalHour?.isNotEmpty == true
                            ? emp.totalHour!
                            : 'Working hrs',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InputCardStyle(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: controller.salaryControllers[index],
                      onChanged: (val) {
                        final updatedEmp = emp.copyWith(
                          salary: val,
                          salaryStatus: val.isNotEmpty
                              ? true
                              : emp.salaryStatus,
                          isEdited: true,
                        );
                        controller.employees[index] = updatedEmp;
                        controller.employees.refresh();
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: calculatedSalary.toString(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            /// Paid/Unpaid Status
            RadioGroup<bool>(
              groupValue: emp.salaryStatus,
              onChanged: (val) {
                controller.employees[index] = emp.copyWith(
                  salaryStatus: val ?? true,
                  isEdited: true,
                );
                controller.employees.refresh();
              },
              child: const Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      dense: true,
                      title: Text("Paid"),
                      value: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      dense: true,
                      title: Text("Unpaid"),
                      value: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  });
}
