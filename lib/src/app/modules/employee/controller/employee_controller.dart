import 'dart:convert';

import 'package:argiot/src/app/bindings/app_binding.dart';
import 'package:argiot/src/app/modules/registration/view/screen/landpicker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../service/utils/pop_messages.dart';

class EmployeeController extends GetxController {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final locationController = TextEditingController();
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  final descriptionController = TextEditingController();

  var selectedEmployeeType = RxnString();
  var selectedWorkType = RxnString();
  var selectedManager = RxnString();

  final employeeTypes = ['Monthly Salaries', 'Daily Wages'];
  final workTypes = [
    'Planting work',
    'Cultivating work',
    'Harvesting work',
    'Irrigation',
    'Pest Control Work',
    'General Work',
    'Add New',
  ];
  final managers = ['John Doe', 'Jane Smith', 'Alice Johnson'];

  final formKey = GlobalKey<FormState>();

  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  // Image handling
  final RxString imagePath = ''.obs;
  final RxString base64Image = ''.obs;

  @override
  void onClose() {
    _clearControllers();
    super.onClose();
  }

  Future<void> pickImage() async {
    try {
      final source = await Get.bottomSheet<ImageSource>(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      );

      if (source != null) {
        final pickedFile = await ImagePicker().pickImage(source: source);
        if (pickedFile != null) {
          imagePath(pickedFile.path);
          final bytes = await pickedFile.readAsBytes();
          base64Image(base64Encode(bytes));
        }
      }
    } catch (e) {
      showError('Failed to pick image');
    }
  }

  void submitForm() {
    if (!formKey.currentState!.validate()) {
      return;
    }
    // Handle submission
    print('Name: ${nameController.text}');
    print('Mobile: ${mobileController.text}');
    print('Employee Type: ${selectedEmployeeType.value}');
    print('Work Type: ${selectedWorkType.value}');
    print('Location URL: ${locationController.text}');
    print('Address: ${addressController.text}');
    print('Pincode: ${pincodeController.text}');
    print('Manager: ${selectedManager.value}');
    print('Description: ${descriptionController.text}');
  }

  Future<void> pickLocation() async {
    try {
      final location = await Get.to(
        const LocationPickerView(),
        binding: LocationViewerBinding(),
      );
      if (location != null) {
        latitude.value = location['latitude'];
        longitude.value = location['longitude'];
        locationController.text = '${latitude.value}, ${longitude.value}';
      }
    } catch (e) {
      showError('Failed to pick location');
    }
  }

  void _clearControllers() {
    nameController.dispose();
    mobileController.dispose();
    locationController.dispose();
    addressController.dispose();
    pincodeController.dispose();
    descriptionController.dispose();
  }
}
