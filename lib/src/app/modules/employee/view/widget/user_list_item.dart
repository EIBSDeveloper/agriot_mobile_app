import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../controller/employee_manager_list_controller.dart';
import '../../model/user_model.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final EmployeeManagerListController controller;

  const UserListItem({super.key, required this.user, required this.controller});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 1,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: ListTile(
      leading: const Icon(Icons.person, size: 40),
      title: Text(user.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.role.tr),
          Text(user.address, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      onTap: () {
        Get.toNamed(
          Routes.employeeDetails,
          arguments: {'employeeId': user.id, 'isManager':  user.role=="Employee"?false:true},
        );
      },
      trailing: IconButton(
        icon: const Icon(Icons.phone, color: Colors.green),
        onPressed: () => controller.initiateCall(user.number),
      ),
    ),
  );
}
