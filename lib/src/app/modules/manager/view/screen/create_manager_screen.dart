import 'dart:io';

import 'package:argiot/src/app/modules/manager/controller/manager_controller.dart';
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
      appBar: const CustomAppBar(title: 'Create Manager'),
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

              //Usersname
              InputCardStyle(
                child: TextFormField(
                  controller: controller.usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Users Name *',
                    hintText: 'Enter Users Name',
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

              //gender
              Obx(
                () => InputCardStyle(
                  child: DropdownButtonFormField<String>(
                    initialValue: controller.selectedGenderType.value,
                    items: controller.genderTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) =>
                        controller.selectedGenderType.value = value,
                    decoration: const InputDecoration(
                      labelText: 'Select Gender *',
                      border: InputBorder.none,
                    ),
                    validator: (value) =>
                        value == null ? 'Required field' : null,
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
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(), // 📌 current date shown
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

              //role
              Obx(
                () => InputCardStyle(
                  child: DropdownButtonFormField<String>(
                    initialValue: controller.selectedRoleType.value,
                    items: controller.roleTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                    ), // 🎂 DOB icon
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(), // 📌 current date shown
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
                    labelText: 'Mobile No *',
                    hintText: 'Enter Mobile No',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Required field'
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Employee Type
              Obx(
                () => InputCardStyle(
                  child: DropdownButtonFormField<String>(
                    initialValue: controller.selectedEmployeeType.value,
                    items: controller.employeeTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) =>
                        controller.selectedEmployeeType.value = value,
                    decoration: const InputDecoration(
                      labelText: 'Employee Type *',
                      border: InputBorder.none,
                    ),
                    validator: (value) =>
                        value == null ? 'Required field' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location URL
              InputCardStyle(
                child: TextFormField(
                  controller: controller.locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location Coordinates *',
                    hintText: 'Enter Location Coordinates',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Required field'
                      : null,
                ),
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

              // ---------------- Permissions Section ----------------
              const SizedBox(height: 16),
              InputCardStyle(
                child: SizedBox(
                  height: 350, // fixed height with scrolling
                  child: GetBuilder<ManagerController>(
                    init: ManagerController(),
                    builder: (ctrl) {
                      if (ctrl.permissions.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView(
                        children: ctrl.permissions.values
                            .map((item) => _buildPermissionItem(item, ctrl))
                            .toList(),
                      );
                    },
                  ),
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
