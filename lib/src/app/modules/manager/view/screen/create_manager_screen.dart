import 'dart:io';

import 'package:argiot/src/app/modules/manager/controller/manager_controller.dart';
import 'package:argiot/src/app/modules/manager/model/dropdown_model.dart';
import 'package:argiot/src/app/modules/manager/model/permission_model.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../widgets/loading.dart';

class CreateManagerScreen extends GetView<ManagerController> {
  const CreateManagerScreen({super.key});
  final gap = const SizedBox(height: 14);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Employee'),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            gap,

            // Manager Photo
            _buildImagePicker(),
            gap,

            /// Role Dropdown
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => InputCardStyle(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonFormField<RoleModel>(
                        initialValue: controller.selectedRoleType.value,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: controller.roleTypes
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(r.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            controller.selectedRoleType.value = value,
                        decoration: const InputDecoration(
                          labelText: 'Select Role *',
                          border: InputBorder.none,
                        ),
                        validator: (value) =>
                            value == null ? 'Required field' : null,
                      ),
                    ),
                  ),
                ),
                Card(
                  color: Get.theme.primaryColor,
                  child: IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Get.toNamed(Routes.employeeAdd)?.then((result) {
                      //   controller.loadManagers();
                      // });
                    },
                    tooltip: 'Add Survey Detail',
                  ),
                ),
              ],
            ),

            gap,

            //Usersname
            InputCardStyle(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: controller.usernameController,
                decoration: const InputDecoration(
                  labelText: ' Name *',
                  border: InputBorder.none,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required field' : null,
              ),
            ),

            //Email
            Obx(
              () => controller.selectedRoleType.value?.id != 0
                  ? Column(
                      children: [
                        gap,
                        InputCardStyle(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: controller.emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email ID *',
                              border: InputBorder.none,
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required field'
                                : null,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
            gap,

            // Mobile No
            InputCardStyle(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: controller.mobileController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // only digits
                  LengthLimitingTextInputFormatter(10), // max 6 digits
                ],
                validator: (value) => value == null ? 'Required field' : null,
                decoration: const InputDecoration(
                  labelText: 'Mobile No *',
                  border: InputBorder.none,
                ),
              ),
            ),

            /// Gender Dropdown
            Obx(
              () => controller.selectedRoleType.value?.id != 0
                  ? Column(
                      children: [
                        gap,
                        InputCardStyle(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButtonFormField<GenderModel>(
                            initialValue: controller.selectedGenderType.value,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: controller.genderTypes
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                controller.selectedGenderType.value = value,
                            decoration: const InputDecoration(
                              labelText: 'Select Gender ',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
            // Date of Birth
            Obx(
              () => controller.selectedRoleType.value?.id != 0
                  ? Column(
                      children: [
                        gap,
                        InputCardStyle(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: controller.dobcontroller,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth ',
                              border: InputBorder.none,
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.grey,
                              ),
                            ),
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                controller.dobcontroller.text =
                                    "${picked.day}/${picked.month}/${picked.year}";
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
            // Date of Joining
            Obx(
              () => controller.selectedRoleType.value?.id != 0
                  ? Column(
                      children: [
                        gap,
                        InputCardStyle(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: controller.dojcontroller,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Date of Joining ',
                              border: InputBorder.none,
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.grey,
                              ),
                            ),
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1990),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                controller.dojcontroller.text =
                                    "${picked.day}/${picked.month}/${picked.year}";
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
            gap,

            /// Employee Type Dropdown
            Obx(
              () => InputCardStyle(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButtonFormField<EmployeeTypeModel>(
                  initialValue: controller.selectedEmployeeType.value,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: controller.employeeTypes
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      controller.selectedEmployeeType.value = value,
                  decoration: const InputDecoration(
                    labelText: 'Employee Type *',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value == null ? 'Required field' : null,
                ),
              ),
            ),

            // Work Type
            Obx(
              () => controller.selectedRoleType.value?.id == 0
                  ? Column(
                      children: [
                        gap,
                        InputCardStyle(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButtonFormField<WorkTypeModel>(
                            initialValue: controller.selectedWorkType.value,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: controller.workTypes
                                .map(
                                  (e) => DropdownMenuItem<WorkTypeModel>(
                                    value: e,
                                    child: Text(e.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                controller.selectedWorkType.value = value,
                            decoration: const InputDecoration(
                              labelText: 'Work Type *',
                              border: InputBorder.none,
                            ),
                            validator: (value) =>
                                value == null ? 'Required field' : null,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),

            // Assign Manager
            Obx(() {
              if (controller.selectedRoleType.value?.id == 0) {
                if (controller.isLoadingManager.value) {
                  return const Loading();
                }
                return Column(
                  children: [
                    gap,
                    InputCardStyle(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonFormField<AssignMangerModel>(
                        initialValue: controller.selectedManager.value,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: controller.managers
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            controller.selectedManager.value = value,
                        decoration: const InputDecoration(
                          labelText: 'Assign Manager',
                          border: InputBorder.none,
                        ),
                        // validator: (value) =>
                        //     value == null ? 'Required field' : null,
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox();
              }
            }),
            // //pincode
            gap,
            InputCardStyle(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: controller.pincodeController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  labelText: 'Pincode *',
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Required field'
                    : null,
              ),
            ),

            gap,

            // Location URL
            InputCardStyle(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: controller.locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Required field'
                    : null,
                readOnly: true,
                onTap: controller.pickLocation,
              ),
            ),

            gap,

            // Address
            InputCardStyle(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                maxLines: 3,
                controller: controller.addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Required field'
                    : null,
              ),
            ),

            gap,

            // Description
            InputCardStyle(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: controller.descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: InputBorder.none,
                ),
              ),
            ),
            gap,

            // ---------------- Permissions Section ----------------
            Obx(
              () => controller.selectedRoleType.value?.id != 0
                  ? InputCardStyle(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: Loading());
                        }

                        if (controller.permissions.isEmpty) {
                          return const Center(
                            child: Text("No permissions found"),
                          );
                        }

                        return Column(
                          children: controller.permissions.values
                              .map(
                                (item) =>
                                    _buildPermissionItem(item, controller),
                              )
                              .toList(),
                        );
                      }),
                    )
                  : const SizedBox(),
            ),
            gap,

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.submitForm, // ✅ no parentheses
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildImagePicker() => Center(
    child: Stack(
      children: [
        Obx(() {
          if (controller.imagePath.isNotEmpty) {
            return CircleAvatar(
              radius: 50,
              backgroundImage: controller.imagePath.startsWith('http')
                  ? CachedNetworkImageProvider(controller.imagePath.value)
                  : FileImage(File(controller.imagePath.value))
                        as ImageProvider,
            );
          }
          return const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 40),
          );
        }),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: controller.pickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPermissionItem(
    PermissionItem item,
    ManagerController controller,
  ) => GetBuilder<ManagerController>(
    builder: (_) => ExpansionTile(
      title: Row(
        children: [
          Checkbox(
            value: item.status == 1,
            onChanged: (val) => controller.toggleStatus(item, val ?? false),
          ),
          Text(item.name),
        ],
      ),
      children: item.children.values
          .map(
            (child) => Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: _buildPermissionItem(child, controller),
            ),
          )
          .toList(),
    ),
  );
}
