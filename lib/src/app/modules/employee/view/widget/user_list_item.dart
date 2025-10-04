import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../controller/employee_manager_list_controller.dart';
import '../../model/user_model.dart';

// Add indentation option to your existing UserListItem
class UserListItem extends StatelessWidget {
  final UserModel user;
  final EmployeeManagerListController controller;
  final bool isIndented;

  const UserListItem({
    super.key,
    required this.user,
    required this.controller,
    this.isIndented = false,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: 1,
    margin: EdgeInsets.only(left: isIndented ? 20.0 : 0.0),
    child: InkWell(
      onTap: () {
        Get.toNamed(
          Routes.employeeDetails,
          arguments: {
            'employeeId': user.id,
            'isManager': user.role == "Employee" ? false : true,
          },
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Get.theme.primaryColor,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(user.role), 
          Text(user.address.toString())
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () => controller.initiateCall(user.number.toString()),
        ),
      ),
    ),
  );
}
