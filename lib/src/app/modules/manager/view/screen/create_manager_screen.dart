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

class CreateManagerScreen extends GetView<ManagerController> {
  const CreateManagerScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Employee'),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Manager Photo
            _buildImagePicker(),
            const SizedBox(height: 16),

            /// Role Dropdown
            Obx(
              () => InputCardStyle(
                child: DropdownButtonFormField<RoleModel>(
                  initialValue: controller.selectedRoleType.value,
                  items: controller.roleTypes
                      .map(
                        (r) => DropdownMenuItem(value: r, child: Text(r.name)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      controller.selectedRoleType.value = value,
                  decoration: const InputDecoration(
                    labelText: 'Select Role *',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value == null ? 'Required field' : null,
                ),
              ),
            ),

            const SizedBox(height: 16),
            //Usersname
            InputCardStyle(
              child: TextFormField(
                controller: controller.usernameController,
                decoration: const InputDecoration(
                  labelText: ' Name *',
                  hintText: 'Enter Name',
                  border: InputBorder.none,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required field' : null,
              ),
            ),
            const SizedBox(height: 16),

            //Email
            InputCardStyle(
              child: TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  labelText: 'Email ID',
                  hintText: 'Enter Email ID',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mobile No
            InputCardStyle(
              child: TextFormField(
                controller: controller.mobileController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // only digits
                  LengthLimitingTextInputFormatter(10), // max 6 digits
                ],
                decoration: const InputDecoration(
                  labelText: 'Mobile No',
                  hintText: 'Enter Mobile No',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Gender Dropdown
            Obx(
              () => InputCardStyle(
                child: DropdownButtonFormField<GenderModel>(
                  initialValue: controller.selectedGenderType.value,
                  items: controller.genderTypes
                      .map(
                        (g) => DropdownMenuItem(value: g, child: Text(g.name)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      controller.selectedGenderType.value = value,
                  decoration: const InputDecoration(
                    labelText: 'Select Gender *',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value == null ? 'Required field' : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date of Joining
            InputCardStyle(
              child: TextFormField(
                controller: controller.dojcontroller,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of Joining ',
                  hintText: 'Select Date of Joining',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
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
            const SizedBox(height: 16),

            /// Employee Type Dropdown
            Obx(
              () => InputCardStyle(
                child: DropdownButtonFormField<EmployeeTypeModel>(
                  initialValue: controller.selectedEmployeeType.value,
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
            const SizedBox(height: 16),

            // Date of Birth
            InputCardStyle(
              child: TextFormField(
                controller: controller.dobcontroller,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth ',
                  hintText: 'Select Date of Birth',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
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
            const SizedBox(height: 16),

            // Location URL
            InputCardStyle(
              child: TextFormField(
                controller: controller.locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  hintText: 'Location',
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Required field'
                    : null,
                readOnly: true,
                onTap: controller.pickLocation,
              ),
            ),

            // Work Type
            Obx(
              () => controller.selectedRoleType.value!.id == 0
                  ? Column(
                      children: [
                        const SizedBox(height: 16),
                        InputCardStyle(
                          child: DropdownButtonFormField<String>(
                            initialValue: controller.selectedWorkType.value,
                            items: controller.workTypes
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
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
            const SizedBox(height: 16),

            // Assign Manager
            Obx(
              () => controller.selectedRoleType.value!.id == 0
                  ? Column(
                      children: [
                        InputCardStyle(
                          child: DropdownButtonFormField<String>(
                            initialValue: controller.selectedManager.value,
                            items: controller.managers
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                controller.selectedManager.value = value,
                            decoration: const InputDecoration(
                              labelText: 'Assign Manager *',
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
            const SizedBox(height: 16),

            // Address
            InputCardStyle(
              child: TextFormField(
                controller: controller.addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  hintText: 'Enter Address',
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Required field'
                    : null,
              ),
            ),

            const SizedBox(height: 16),
            // Description
            InputCardStyle(
              child: TextFormField(
                controller: controller.descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter Description',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---------------- Permissions Section ----------------
            const SizedBox(height: 16),
            InputCardStyle(
              child: SizedBox(
                height: 350, // fixed height with scrolling
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.permissions.isEmpty) {
                    return const Center(child: Text("No permissions found"));
                  }

                  return ListView(
                    children: controller.permissions.values
                        .map((item) => _buildPermissionItem(item, controller))
                        .toList(),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.submitForm,
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
  ) => ExpansionTile(
    key: PageStorageKey(item.name),
    title: Row(
      children: [
        Checkbox(
          value: item.status == 1,
          onChanged: (bool? value) {
            controller.toggleStatus(item, value!);
          },
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
  );
}
