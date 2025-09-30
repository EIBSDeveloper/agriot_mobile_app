import 'package:argiot/src/app/modules/attendence/controller/attendence_controller.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAttendenceScreen extends GetView<AttendenceController> {
  const AddAttendenceScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Add Attendence'),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            /// Date field (Month-Year + horizontal date picker)
            /*InputCardStyle(
                child: HorizontalDatePicker(
                  onDateSelected: controller.setSelectedDate,
                ),
              ),
              const SizedBox(height: 12),*/
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InputCardStyle(
                child: TextField(
                  controller: controller.searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      size: 22,
                      color: Colors.grey,
                    ),
                    hintText: "Search employee...",
                    border: InputBorder.none,
                    isDense: true, // ✅ keeps everything tight
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                    ), // ✅ vertical center
                  ),
                  onChanged: (value) {
                    controller.searchQuery.value = value.toLowerCase();
                  },
                ),
              ),
            ),

            /// Employee list
            Obx(() {
              final query = controller.searchQuery.value;
              final filteredEntries = controller.employees
                  .asMap()
                  .entries
                  .where(
                    (entry) => entry.value.name.toLowerCase().contains(query),
                  )
                  .toList();

              return Column(
                children: filteredEntries
                    .map((entry) => AttendanceCard(index: entry.key))
                    .toList(),
              );
            }),

            const SizedBox(height: 20),

            /// Submit button
          ],
        ),
      ),
    ),
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            controller.submitAttendance(); // still prints JSON
            Get.toNamed(Routes.attendencelistscreen);
          },
          child: const Text('Submit'),
        ),
      ),
    ),
  );
}

/// ---------------- Reusable Widget ----------------
class AttendanceCard extends GetView<AttendenceController> {
  final int index;
  const AttendanceCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) => Obx(() {
    final emp = controller.employees[index];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                      emp.role,
                      style: const TextStyle(color: Colors.black54),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Login Time", // Label
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller
                                          .loginControllers[index]
                                          ?.text
                                          .isNotEmpty ==
                                      true
                                  ? controller.loginControllers[index]!.text
                                  : "Select Login Time", // Hint
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    controller
                                            .loginControllers[index]
                                            ?.text
                                            .isNotEmpty ==
                                        true
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
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Logout Time", // Label
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller
                                          .logoutControllers[index]
                                          ?.text
                                          .isNotEmpty ==
                                      true
                                  ? controller.logoutControllers[index]!.text
                                  : "Select Logout Time", // Hint
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    controller
                                            .logoutControllers[index]
                                            ?.text
                                            .isNotEmpty ==
                                        true
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
                    child: TextField(
                      readOnly: true,
                      controller: TextEditingController(text: emp.hours ?? ''),
                      decoration: const InputDecoration(
                        labelText: "Working Hours",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InputCardStyle(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: controller.salaryControllers[index],
                      onChanged: (val) {
                        final salary = int.tryParse(val);
                        controller.employees[index] = emp.copyWith(
                          salary: salary,
                        );
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
              groupValue: emp.paidStatus,
              onChanged: (val) => controller.setStatus(index, val ?? true),
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
