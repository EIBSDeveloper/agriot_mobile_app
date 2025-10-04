import 'package:argiot/src/app/modules/attendence/controller/attendence_controller.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttendanceCard extends GetView<AttendenceController> {
  final int index;

  const AttendanceCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) => Obx(() {
    final emp = controller.employees[index];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    // Text(
                    //   emp.role,
                    //   style: const TextStyle(color: Colors.black54),
                    // ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          // vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Login Time",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          // vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Logout Time",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
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
                /*Expanded(
                  child: InputCardStyle(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 17,
                      ),
                      child: Text(
                        emp.totalHour ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),*/
                Expanded(
                  child: InputCardStyle(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Text(
                        (emp.totalHour == null || emp.totalHour!.isEmpty)
                            ? 'Working hrs' // 🔥 placeholder
                            : emp.totalHour!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors
                              .black54, // optional lighter color for placeholder
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
                        controller.employees[index] = emp.copyWith(salary: val);
                        controller.employees.refresh();
                      },
                      decoration: const InputDecoration(
                        labelText: "Salary",
                        border: InputBorder.none,
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
