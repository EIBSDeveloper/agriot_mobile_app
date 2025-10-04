import 'package:argiot/src/app/modules/employee/controller/employee_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/my_network_image.dart';

class ProfileHeader extends StatelessWidget {
  final EmployeeDetailsController controller;

  const ProfileHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => Obx(() => Row(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          child: controller.employeeDetails.value.profile.isNotEmpty
              ? ClipOval(
                  child: MyNetworkImage(
                    controller.employeeDetails.value.profile,
                    width: 90,
                    height: 90,
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
              controller.employeeDetails.value.name,
              style: Get.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.employeeDetails.value.mobileNumber,
              style: Get.theme.textTheme.titleMedium?.copyWith(
                color: Get.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    ));
}