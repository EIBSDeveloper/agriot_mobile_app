import 'dart:convert';

import 'package:argiot/src/app/bindings/app_binding.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/manager/model/dropdown_model.dart';
import 'package:argiot/src/app/modules/manager/model/permission_model.dart';
import 'package:argiot/src/app/modules/registration/view/screen/landpicker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../service/utils/pop_messages.dart';
import '../../employee/model/employee_details_model.dart';
import '../../employee/repository/employee_details_repository.dart';
import '../repository/manager_repository.dart';

final AppDataController appDeta = Get.put(AppDataController());

/// ----------------- Flatten Permissions Helper -----------------
Map<String, dynamic> flattenPermissions(Map<String, PermissionItem> perms) {
  final Map<String, dynamic> result = {};
  perms.forEach((key, value) {
    result[key] = value.toFlatJson();
  });
  return result;
}

class ManagerController extends GetxController {
  final ManagerRepository repository = Get.find();
  final EmployeeDetailsRepository _repository =
      Get.find<EmployeeDetailsRepository>();
  final RxInt id = 0.obs;
  final RxInt role = 0.obs;
  var employeeDetails = Rx<EmployeeDetailsModel?>(null);

  final usernameController = TextEditingController();
  final dobcontroller = TextEditingController();
  final dojcontroller = TextEditingController();
  final mobileController = TextEditingController();
  final alternativemobileController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final pincodeController = TextEditingController();

  /// Selected values
  var selectedEmployeeType = Rxn<EmployeeTypeModel>();
  var selectedGenderType = Rxn<GenderModel>();
  var selectedRoleType = Rxn<RoleModel>();
  var selectedWorkType = Rxn<WorkTypeModel>();
  var selectedManager = Rxn<AssignMangerModel>();

  /// Lists from API
  var employeeTypes = <EmployeeTypeModel>[].obs;
  var genderTypes = <GenderModel>[].obs;
  var roleTypes = <RoleModel>[].obs;
  var workTypes = <WorkTypeModel>[].obs;
  var managers = <AssignMangerModel>[].obs;
  var isLoadingManager = false.obs;
  final formKey = GlobalKey<FormState>();

  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  // Image handling
  final RxString imagePath = ''.obs;
  final RxString base64Image = ''.obs;

  @override
  void onInit() {
    super.onInit();
    var argument = Get.arguments;
    if (argument?['id'] != null) {
      id.value = argument['id'];
      role.value = argument['role'] ?? 0;
    }

    laod();
  }

  Future<void> laod() async {
    await loadPermissionsFromApi();
    await fetchDropdownData();
    await loadManagers();
    await loadEmployeeDetails();
  }

  @override
  void onClose() {
    _clearControllers();
    super.onClose();
  }

  Future<void> loadEmployeeDetails() async {
    if (id.value == 0) {
      return;
    }
    try {
      isLoading.value = true;

      EmployeeDetailsModel response;

      if (role.value != 0) {
        response = await _repository.getManagerDetails(id.value);
      } else {
        response = await _repository.getEmployeeDetails(id.value);
      }

      employeeDetails.value = response;
      usernameController.text = employeeDetails.value?.name ?? '';
      dobcontroller.text = employeeDetails.value?.dob ?? '';
      dojcontroller.text = employeeDetails.value?.doj ?? '';
      mobileController.text = employeeDetails.value?.mobileNo ?? '';
      alternativemobileController.text =
          employeeDetails.value?.alternativeMobile ?? '';
      emailController.text = employeeDetails.value?.email ?? '';
      pincodeController.text = employeeDetails.value?.pincode ?? '';
      descriptionController.text = employeeDetails.value?.description ?? '';
      if (employeeDetails.value?.employeeType.id != null) {
        selectedEmployeeType.value = employeeTypes.firstWhere(
          (empoloyee) => empoloyee.id == employeeDetails.value?.employeeType.id,
        );
      }
      if (employeeDetails.value?.gender?.id != null) {
        selectedGenderType.value = genderTypes.firstWhere(
          (gender) => gender.id == employeeDetails.value?.gender?.id,
        );
      }
      if (employeeDetails.value?.role.id != null) {
        int roleid = 0;
        if (role.value == 0) {
          roleid = 0;
        } else {
          roleid = employeeDetails.value?.employeeType.id ?? 0;
        }
        selectedRoleType.value = roleTypes.firstWhere(
          (empoloyee) => empoloyee.id == roleid,
        );
      }
      if (employeeDetails.value?.workType?.id != null) {
        selectedWorkType.value = workTypes.firstWhere(
          (workType) => workType.id == employeeDetails.value!.workType!.id,
        );
      }
      if (employeeDetails.value?.manager?.id != null) {
        selectedManager.value = managers.firstWhere(
          (manager) => manager.id == employeeDetails.value!.manager!.id,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load details: ${e.toString()}'.tr);
    } finally {
      isLoading.value = false;
    }
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

  void toggleStatus(PermissionItem item, bool value) {
    item.status = value ? 1 : 0;
    item.children.forEach((_, child) => toggleStatus(child, value));
    update();
  }

  Future<void> loadPermissionsFromApi() async {
    try {
      isLoading.value = true;
      final apiData = await repository.fetchPermissions();
      permissions.value = apiData.map(
        (key, value) => MapEntry(key, PermissionItem.fromApi(key, value)),
      );
    } catch (e) {
      print('Error fetching permissions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Loading flag
  var isLoading = false.obs;

  Future<void> fetchDropdownData() async {
    isLoading.value = true;

    try {
      /// Fetch employee types
      final empRes = await http.get(
        Uri.parse("${appDeta.baseUrl.value}/employee_types"),
      );
      if (empRes.statusCode == 200) {
        final List data = jsonDecode(empRes.body);
        employeeTypes.value = data
            .map((e) => EmployeeTypeModel.fromJson(e))
            .toList();
      }

      /// Fetch genders
      final genderRes = await http.get(
        Uri.parse("${appDeta.baseUrl.value}/genders"),
      );
      if (genderRes.statusCode == 200) {
        final List data = jsonDecode(genderRes.body);
        genderTypes.value = data.map((e) => GenderModel.fromJson(e)).toList();
      }

      /// Fetch roles
      final roleRes = await http.get(
        Uri.parse("${appDeta.baseUrl.value}/manager_roals"),
      );
      if (roleRes.statusCode == 200) {
        final List data = jsonDecode(roleRes.body);
        //roleTypes.value = data.map((e) => RoleModel.fromJson(e)).toList();
        roleTypes.value = [
          RoleModel(id: 0, name: "employee"),
          ...data.map((e) => RoleModel.fromJson(e)),
        ];
        if (selectedRoleType.value == null && roleTypes.isNotEmpty) {
          selectedRoleType.value =
              roleTypes.first; // first role will be selected
        }
      }

      //fetch worktypes
      final worktypeRes = await http.get(
        Uri.parse("${appDeta.baseUrl.value}/work_type"),
      );
      if (worktypeRes.statusCode == 200) {
        final List data = jsonDecode(worktypeRes.body);
        workTypes.value = data.map((e) => WorkTypeModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching dropdown data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadManagers() async {
    try {
      isLoadingManager.value = true;
      final data = await repository.fetchAssignManager();
      managers.value = data;
    } catch (e) {
      print('Error fetching managers: $e');
    } finally {
      isLoadingManager.value = false;
    }
  }

  // Submit Form
  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Determine role-specific fields
      final isEmployee = selectedRoleType.value?.id == 0;

      final response = await repository.createEmployeeManager(
        id: id.value,
        role: selectedRoleType.value,
        name: usernameController.text.trim(),
        phone: mobileController.text.trim(),
        email: isEmployee ? null : emailController.text.trim(),
        employeeTypeId: selectedEmployeeType.value?.id,
        genderId: isEmployee ? null : selectedGenderType.value?.id,
        dob: isEmployee ? null : formatDate(dobcontroller.text),
        doj: isEmployee ? null : formatDate(dojcontroller.text),
        address: addressController.text.trim(),
        latitude: latitude.value,
        longitude: longitude.value,
        permissions: isEmployee ? null : permissions,
        managerId: isEmployee ? selectedManager.value?.id : null,
        workTypeId: isEmployee ? selectedWorkType.value?.id : null,
        pincode: pincodeController.text.trim(),
        description: isEmployee ? descriptionController.text.trim() : null,
      );

      // Show success message
      final successMessage = isEmployee
          ? "Employee created successfully"
          : "Manager created successfully";
      showSuccess(successMessage);

      // Clear form fields
      _clearFormFields();

      // Go back after success
      Get.back();

      print("✅ API Response: $response");
    } catch (e) {
      showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper to clear all form fields
  void _clearFormFields() {
    usernameController.clear();
    mobileController.clear();
    emailController.clear();
    dobcontroller.clear();
    dojcontroller.clear();
    addressController.clear();
    pincodeController.clear();
    descriptionController.clear();
    locationController.clear();
    selectedEmployeeType.value = null;
    selectedGenderType.value = null;
    selectedRoleType.value = roleTypes.isNotEmpty ? roleTypes.first : null;
    selectedWorkType.value = null;
    selectedManager.value = null;
    latitude.value = 0.0;
    longitude.value = 0.0;
    imagePath.value = '';
    base64Image.value = '';
    permissions.clear();
  }

  /// Helper to format date to YYYY-MM-DD
  String? formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;

    try {
      final date = DateTime.parse(
        dateStr,
      ); // If your controller already has YYYY-MM-DD, this works
      return "${date.year.toString().padLeft(4, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.day.toString().padLeft(2, '0')}";
    } catch (_) {
      // If the user input is in dd/MM/yyyy, you can parse it like this:
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final date = DateTime(year, month, day);
        return "${date.year.toString().padLeft(4, '0')}-"
            "${date.month.toString().padLeft(2, '0')}-"
            "${date.day.toString().padLeft(2, '0')}";
      }
      return null; // fallback
    }
  }
}
