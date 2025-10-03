import 'package:argiot/src/app/modules/attendence/controller/attendence_controller.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*class AddAttendenceScreen extends GetView<AttendenceController> {
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
            InputCardStyle(
              child: HorizontalDatePicker(
                onDateSelected: controller.setSelectedDate,
              ),
            ),
            const SizedBox(height: 12),
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
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final query = controller.searchQuery.value;
              final filteredEmployees = controller.employees
                  .where((e) => e.name.toLowerCase().contains(query))
                  .toList();

              if (filteredEmployees.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("No employees found")),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredEmployees.length,
                itemBuilder: (context, index) {
                  final empIndex = controller.employees.indexOf(
                    filteredEmployees[index],
                  );
                  return AttendanceCard(index: empIndex);
                },
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
          onPressed: () async {
            await controller.addAttendance(employees: controller.employees);
            Get.toNamed(Routes.attendencelistscreen);
          },

          child: const Text('Submit'),
        ),
      ),
    ),
  );
}*/
class AddAttendenceScreen extends GetView<AttendenceController> {
  final ScrollController scrollController = ScrollController();

  AddAttendenceScreen({super.key}) {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !controller.isLoading.value) {
        controller.loadEmployees();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Add Attendence'),
    body: SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 16),

            /// Date field
            /* InputCardStyle(
                child: HorizontalDatePicker(
                  onDateSelected: controller.setSelectedDate,
                ),
              ),*/
            const SizedBox(height: 12),

            /// Search field
            InputCardStyle(
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

            const SizedBox(height: 12),

            /// Employee list
            Obx(() {
              if (controller.isLoading.value && controller.employees.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.employees.isEmpty) {
                return const Center(child: Text("No employees found"));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    controller.employees.length +
                    (controller.hasMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.employees.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return AttendanceCard(index: index);
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await controller.addAttendance(employees: controller.employees);
            Get.back();
            //Get.toNamed(Routes.attendencelistscreen);
          },
          child: const Text('Submit'),
        ),
      ),
    ),
  );
}

/// ---------------- Reusable Widget ----------------
/*class AttendanceCard extends GetView<AttendenceController> {
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
                      controller: TextEditingController(
                        text: emp.totalHour ?? '',
                      ),
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
              groupValue: emp.salaryStatus,
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
}*/

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
