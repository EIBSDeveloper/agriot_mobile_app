import 'package:argiot/src/app/modules/employee/view/widget/manager_employee_group_item.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../../../widgets/loading.dart';
import '../../controller/employee_manager_list_controller.dart';

import '../widget/filter_section.dart';

class EmployeeManagerView extends GetView<EmployeeManagerListController> {
  const EmployeeManagerView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: CustomAppBar(title: 'employee_manager'.tr),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.loadInitialData();
        },
        child: Column(
          children: [
            // Filter Section
            FilterSection(controller: controller),

            Expanded(
              child: Obx(() {
                if (controller.filteredGroups.isEmpty &&
                    !controller.isLoading.value) {
                  return Center(child: Text('no_users_found'.tr));
                }

                return ListView.builder(
                  itemCount:
                      controller.filteredGroups.length +
                      (controller.hasMoreData.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Load more indicator
                    if (index == controller.filteredGroups.length) {
                      return controller.isLoading.value
                          ? const Padding(
                              padding: EdgeInsets.all(100.0),
                              child: Loading(),
                            )
                          : const SizedBox.shrink();
                    }

                    // final group = ;
                    return ManagerEmployeeGroupItem(
                      group: controller.filteredGroups[index],
                      controller: controller,
                      showEmployees: controller.selectedRole.value != 'Manager',
                    );
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
          Get.toNamed(Routes.employeeAdd)?.then((result) {
            controller.loadInitialData();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
}
