import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../controller/employee_manager_list_controller.dart';
import '../widget/filter_section.dart';
import '../widget/user_list_item.dart';

class EmployeeManagerView extends StatelessWidget {
  const EmployeeManagerView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'employee_manager'.tr),
    body: GetBuilder<EmployeeManagerListController>(
      init: EmployeeManagerListController(),
      builder: (controller) => Column(
        children: [
          // Filter Section
          FilterSection(controller: controller),

          // Loading Indicator
          Obx(
            () => (controller.isLoading.value)
                ? const LinearProgressIndicator()
                : const SizedBox.shrink(),
          ),
          // User List
          Expanded(
            child: Obx(() {
              if (controller.filteredUsers.isEmpty &&
                  !controller.isLoading.value) {
                return Center(child: Text('no_users_found'.tr));
              }

              return ListView.builder(
                itemCount: controller.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.filteredUsers[index];
                  return UserListItem(user: user, controller: controller);
                },
              );
            }),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Get.theme.primaryColor,
      onPressed: () {
        Get.toNamed(Routes.employeeAdd);
      },
      child: const Icon(Icons.add),
    ),
  );
}
