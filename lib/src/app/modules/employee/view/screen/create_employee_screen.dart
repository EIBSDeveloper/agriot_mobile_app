import 'dart:io';

import 'package:argiot/src/app/modules/employee/controller/employee_controller.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CreateEmployeeScreen extends GetView<EmployeeController> {
  const CreateEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Create Employee'),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Employee Photo
            // _buildImagePicker(),
            const SizedBox(height: 16),

            //Employee name
            InputCardStyle(
              child: TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Employee Name *',
                  hintText: 'Enter Employee Name',
                  border: InputBorder.none,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required field' : null,
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
                  // LengthLimitingTextInputFormatter(10), // max 6 digits
                ],
                decoration: const InputDecoration(
                  labelText: 'Mobile No',
                  hintText: 'Enter Mobile No',
                  border: InputBorder.none,
                ),
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
                  validator: (value) => value == null ? 'Required field' : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Work Type
            Obx(
              () => InputCardStyle(
                child: DropdownButtonFormField<String>(
                  initialValue: controller.selectedWorkType.value,
                  items: controller.workTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) =>
                      controller.selectedWorkType.value = value,
                  decoration: const InputDecoration(
                    labelText: 'Work Type *',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value == null ? 'Required field' : null,
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
                  hintText: 'Location Coordinates',
                  border: InputBorder.none,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Required field'
                    : null,
                readOnly: true,
                onTap: controller.pickLocation,
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

            // Pincode
            InputCardStyle(
              child: TextFormField(
                controller: controller.pincodeController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  // FilteringTextInputFormatter.digitsOnly, // only digits
                  // LengthLimitingTextInputFormatter(6), // max 6 digits
                ],
                decoration: const InputDecoration(
                  labelText: 'Pincode *',
                  hintText: 'Enter Pincode',
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty 
                      ) {
                    return 'Required field';
                  }
                     if (value.length > 11) {
                      return 'Please enter a valid Pincode'.tr;
                    }

                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Assign Manager
            Obx(
              () => InputCardStyle(
                child: DropdownButtonFormField<String>(
                  initialValue: controller.selectedManager.value,
                  items: controller.managers
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) =>
                      controller.selectedManager.value = value,
                  decoration: const InputDecoration(
                    labelText: 'Assign Manager *',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value == null ? 'Required field' : null,
                ),
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
}
