import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/loading.dart';
import '../../../../widgets/my_network_image.dart';
import '../../controller/employee_details_controller.dart';
import '../widget/detail_row.dart';

class EmployeeDetailsView extends GetView<EmployeeDetailsController> {
  const EmployeeDetailsView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: controller.isManager.value
          ? 'manager_details'.tr
          : 'employee_details'.tr,
    ),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Loading();
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Obx(
              () => Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Get.theme.colorScheme.primaryContainer,
                    child: controller.employeeDetails.value!.name.isNotEmpty
                        ? ClipOval(
                            child: MyNetworkImage(
                              controller.employeeDetails.value!.name,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.employeeDetails.value!.name,
                        style: Get.theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // const SizedBox(height: 8),
                      Text(
                        controller.employeeDetails.value!.mobileNo,
                        style: Get.theme.textTheme.titleMedium?.copyWith(
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // Details Section
            Column(
              children: [
                // Role
                DetailRow(
                  label: 'role',
                  value: controller.employeeDetails.value?.role.name ?? "",
                  isImportant: true,
                ),
                const Divider(),

                // Salary Type
                DetailRow(
                  label: 'salary_type',
                  value:
                      controller.employeeDetails.value?.employeeType.name ?? "",
                ),
                // const Divider(),

                // // Work Type (using role as work type)
                // DetailRow(
                //   label: 'work_type',
                //   value: controller.employeeDetails.value?.w.name??"",
                // ),
                const Divider(),

                // Joining Date
                DetailRow(
                  label: 'joining_date',
                  value: controller.employeeDetails.value?.doj ?? "",
                ),
                const Divider(),

                // Gender
                DetailRow(
                  label: 'gender',
                  value: controller.employeeDetails.value?.gender.name ?? "",
                ),
                const Divider(),

                // Alternative Mobile Number
                DetailRow(
                  label: 'mobile',
                  value: "${controller.employeeDetails.value?.mobileNo ?? ""} ${controller.employeeDetails.value?.AlternativeMobile ?? ""}",
                ),
                const Divider(),

                // Email ID
                DetailRow(
                  label: 'email_id',
                  value: controller.employeeDetails.value?.email??"",
                ),
                const Divider(),

                // Salary
                DetailRow(
                  label: 'salary',
                  value: controller.employeeDetails.value?.employeeType.name ?? "",
                  isImportant: true,
                ),
                const Divider(),

                // Pincode
                DetailRow(
                  label: 'pincode',
                  value: controller.employeeDetails.value!.pincode,
                ),

                // // Manager-specific fields
                // if (controller.employeeDetails.value!.name != null) ...[
                //   const Divider(),
                //   DetailRow(
                //     label: 'user_id',
                //     value: controller.employeeDetails.value!.name!,
                //   ),
                // ],

                // if (controller.employeeDetails.value.password != null) ...[
                //   const Divider(),
                //   DetailRow(
                //     label: 'password',
                //     value: controller.employeeDetails.value.password!,
                //   ),
                // ],
                const Divider(),
              ],
            ),

            // Address Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'address'.tr,
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.employeeDetails.value!.description.isNotEmpty
                        ? controller.employeeDetails.value!.description
                        : 'address_not_provided'.tr,
                    style: Get.theme.textTheme.bodyMedium?.copyWith(
                      fontStyle:
                          controller.employeeDetails.value!.description.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                      color: Get.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }),
  );
}
