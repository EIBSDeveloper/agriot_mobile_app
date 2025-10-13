import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../../../service/utils/utils.dart';
import '../../controller/employee_manager_list_controller.dart';
import '../../model/user_model.dart';

class UserListItem extends StatefulWidget {
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
  State<UserListItem> createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {
  bool _isSwitchedOn = false;
  @override
  void initState() {
    super.initState(); // Always call super.initState() first
    setState(() {
      _isSwitchedOn = widget.user.status != null
          ? widget.user.status == 0
                ? true
                : false
          : false;
    });
  }

  @override
  Widget build(BuildContext context) => widget.user.id == 0
      ? const SizedBox()
      : Card(
          elevation: 1,
          margin: EdgeInsets.only(left: widget.isIndented ? 20.0 : 0.0),
          child: InkWell(
            onTap: () {
              Get.toNamed(
                Routes.employeeDetails,
                arguments: {
                  'employeeId': widget.user.id,
                  'isManager': widget.user.role == "Employee" ? false : true,
                },
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Get.theme.primaryColor,
                child: Text(
                  widget.user.name.isNotEmpty
                      ? widget.user.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(capitalizeFirstLetter(widget.user.name)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(user.role),
                  Text(widget.user.address.toString(),maxLines: 1,overflow: TextOverflow.ellipsis,),
                  if (widget.user.status != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36,
                          height: 20,
                          child: Transform.scale(
                            scale: 0.7,
                            alignment: Alignment.center,
                            child: Switch.adaptive(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: _isSwitchedOn,
                              onChanged: (bool newValue) {
                                setState(() {
                                  _isSwitchedOn = newValue;
                                });
                                widget.controller.statusUpdate(
                                  id: widget.user.id,
                                  status: newValue,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSwitchedOn ? "Active" : "Inactive",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _isSwitchedOn
                                ? Get.theme.primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              trailing: IconButton(
                onPressed: () {
                  makePhoneCall(widget.user.number);
                },
                icon: Icon(Icons.call, color: Get.theme.primaryColor),
              ),
            ),
          ),
        );
}
