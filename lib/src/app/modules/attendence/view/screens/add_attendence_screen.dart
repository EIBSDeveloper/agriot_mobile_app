import 'package:argiot/src/app/modules/attendence/controller/attendence_controller.dart';
import 'package:argiot/src/app/modules/attendence/view/widget/attendance_card.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/loading.dart';

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
                return const Loading();
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
                      child: Loading(),
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
