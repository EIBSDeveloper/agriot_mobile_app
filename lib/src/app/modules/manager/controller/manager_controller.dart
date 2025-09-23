import 'dart:convert';

import 'package:argiot/src/app/bindings/app_binding.dart';
import 'package:argiot/src/app/modules/manager/model/permission_model.dart';
import 'package:argiot/src/app/modules/registration/view/screen/landpicker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../service/utils/pop_messages.dart';

class ManagerController extends GetxController {
  final usernameController = TextEditingController();
  final dobcontroller = TextEditingController();
  final dojcontroller = TextEditingController();
  final mobileController = TextEditingController();
  final alternativemobileController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  final addressController = TextEditingController();

  var selectedEmployeeType = RxnString();
  var selectedGenderType = RxnString();
  var selectedRoleType = RxnString();

  final employeeTypes = ['Monthly Salaries', 'Daily Wages'];
  final genderTypes = ['Male', 'Female', 'TransGender'];
  final roleTypes = ['Sub Admin', 'Manager'];

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
    print('Name: ${usernameController.text}');
    print('Mobile: ${mobileController.text}');
    print('Employee Type: ${selectedEmployeeType.value}');
    print('Location URL: ${locationController.text}');
    print('Address: ${addressController.text}');
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
    usernameController.dispose();
    mobileController.dispose();
    locationController.dispose();
    addressController.dispose();
    alternativemobileController.dispose();
    dobcontroller.dispose();
    dojcontroller.dispose();
    emailController.dispose();
  }

  // JSON directly in controller
  final Map<String, dynamic> rawPermissions = {
    "Dashboard": {
      "status": 0,
      "actions": {
        "view": {"status": 0},
      },
    },
    "My Farms": {
      "status": 0,
      "modules": {
        "my_land": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "edit": {"status": 0},
            "view": {"status": 0},
            "delete": {"status": 0},
            "view_location": {"status": 0},
          },
        },
        "my_crop": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "edit": {"status": 0},
            "view": {"status": 0},
            "delete": {"status": 0},
            "create_schedule": {"status": 0},
            "update_schedule": {"status": 0},
          },
        },
        "my_schedule": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "edit": {"status": 0},
            "view": {"status": 0},
            "delete": {"status": 0},
          },
        },
        "best_practice_schedule": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "view": {"status": 0},
          },
        },
      },
    },
    "My Expense": {
      "status": 0,
      "modules": {
        "my_expense": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "edit": {"status": 0},
            "view": {"status": 0},
            "delete": {"status": 0},
            "view_location": {"status": 0},
          },
        },
        "my_vendor": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "edit": {"status": 0},
            "view": {"status": 0},
            "delete": {"status": 0},
            "create_schedule": {"status": 0},
            "update_schedule": {"status": 0},
          },
        },
      },
    },
    "My Sales": {
      "status": 0,
      "modules": {
        "my_sales": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "edit": {"status": 0},
            "view": {"status": 0},
            "delete": {"status": 0},
            "view_location": {"status": 0},
          },
        },
        "my_customer": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "edit": {"status": 0},
            "view": {"status": 0},
            "delete": {"status": 0},
            "create_schedule": {"status": 0},
            "update_schedule": {"status": 0},
          },
        },
      },
    },
    "My Inventory": {
      "status": 0,
      "modules": {
        "fuel": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "consumption": {"status": 0},
            "view": {"status": 0},
          },
        },
        "vehicle": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "consumption": {"status": 0},
            "view": {"status": 0},
          },
        },
        "machinery": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "consumption": {"status": 0},
            "view": {"status": 0},
          },
        },
        "tools": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "consumption": {"status": 0},
            "view": {"status": 0},
          },
        },
        "pesticides": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "consumption": {"status": 0},
            "view": {"status": 0},
          },
        },
        "fertilizers": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "consumption": {"status": 0},
            "view": {"status": 0},
          },
        },
        "seeds": {
          "status": 0,
          "actions": {
            "list": {"status": 0},
            "add": {"status": 0},
            "consumption": {"status": 0},
            "view": {"status": 0},
          },
        },
      },
    },
  };

  var permissions = <String, PermissionItem>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPermissions();
  }

  void _loadPermissions() {
    permissions.value = rawPermissions.map(
      (key, value) => MapEntry(key, PermissionItem.fromJson(key, value)),
    );
  }

  void toggleStatus(PermissionItem item, bool value) {
    item.status = value ? 1 : 0;
    item.children.forEach((_, child) => toggleStatus(child, value));
    update();
  }

  String getUpdatedJson() {
    final updated = permissions.map((k, v) => MapEntry(k, v.toJson()));
    return updated.toString();
  }
}
