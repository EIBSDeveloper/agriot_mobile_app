import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/input_card_style.dart';
import '../../controller/employee_manager_list_controller.dart';

class FilterSection extends StatelessWidget {
  final EmployeeManagerListController controller;

  const FilterSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Role Dropdown
        InputCardStyle( padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Obx(
            () => DropdownButtonFormField<String>(
              initialValue: controller.selectedRole.value,
              items: [ 'Employee','Manager',]
                  .map(
                    (String role) => DropdownMenuItem<String>(
                      value: role,
                      child: Text(role.tr),
                    ),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.updateRoleFilter(newValue);
                }
              },
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              decoration: InputDecoration(
                labelText: 'role'.tr,
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        // const SizedBox(height: 10),

        // Search Field
        // InputCardStyle( padding: const EdgeInsets.symmetric(horizontal: 8),
        //   child: TextFormField(
        //     onChanged: controller.updateSearchQuery,
        //     decoration: InputDecoration(
        //       labelText: 'search'.tr,
        //       // prefixIcon: const Icon(Icons.search),
        //       border: InputBorder.none,
        //     ),
        //   ),
        // ),
      ],
    ),
  );
}
