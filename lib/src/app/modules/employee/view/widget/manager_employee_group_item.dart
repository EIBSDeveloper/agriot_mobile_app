import 'package:argiot/src/app/modules/employee/controller/employee_manager_list_controller.dart';
import 'package:argiot/src/app/modules/employee/model/user_model.dart';
import 'package:argiot/src/app/modules/employee/view/widget/user_list_item.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManagerEmployeeGroupItem extends StatelessWidget {
  final ManagerEmployeeGroup group;
  final EmployeeManagerListController controller;
  final bool showEmployees;

  const ManagerEmployeeGroupItem({
    super.key,
    required this.group,
    required this.controller,
    required this.showEmployees,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Manager Item
         if ( !showEmployees)
        UserListItem(user: group.manager.toUserModel(), controller: controller)
        else  SizedBox(
          child: TitleText( group.manager.name),
        ),

        // Employees under this manager
        if (showEmployees && group.employees.isNotEmpty) ...[
          // const Divider(height: 1),
          // Padding(
          //   padding: const EdgeInsets.only(left: 16.0, top: 8.0),
          //   child: Text(
          //     'Employees (${group.employees.length})',
          //     style: Get.textTheme.titleSmall?.copyWith(
          //       fontWeight: FontWeight.bold,
          //       color: Get.theme.primaryColor,
          //     ),
          //   ),
          // ),
          ...group.employees.map(
            (employee) => Padding(
              padding: const EdgeInsets.only(left: 10,top: 8),
              child: UserListItem(
                user: employee.toUserModel(),
                controller: controller,
                // isIndented: true,
              ),
            ),
          ),
          const SizedBox(height: 10,),
          const Divider(height: 1),
        ] else if (showEmployees && group.employees.isEmpty) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No employees assigned',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
