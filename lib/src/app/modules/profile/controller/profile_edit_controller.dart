// lib/app/modules/profile/repositories/profile_repository.dart

import 'dart:async';
import 'dart:convert';
import 'package:argiot/src/app/bindings/app_binding.dart';
import 'package:argiot/src/app/modules/profile/controller/profile_controller.dart';
import 'package:argiot/src/app/modules/profile/repository/profile_repository.dart';
import 'package:argiot/src/app/modules/profile/model/profile_model.dart';
import 'package:argiot/src/app/modules/registration/view/screen/landpicker.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../service/utils/utils.dart';

class ProfileEditController extends GetxController {
  // Services & Repositories
  final ProfileRepository _profileRepository = Get.find();
  // final AddressService _addressService = Get.find();

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final companyController = TextEditingController();
  final taxNoController = TextEditingController();
  final doorNoController = TextEditingController();
  final pincodeController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingCountries = false.obs;
  final RxBool isLoadingStates = false.obs;
  final RxBool isLoadingCities = false.obs;
  final RxBool isLoadingTaluks = false.obs;
  final RxBool isLoadingVillages = false.obs;

  // Image handling
  final RxString imagePath = ''.obs;
  final RxString base64Image = ''.obs;

  // Disposables
  final List<StreamSubscription> _subscriptions = [];

  @override
  void onInit() {
    super.onInit();
    // _setupDropdownListeners();
    _loadInitialData();
  }

  @override
  void onClose() {
    _clearControllers();
    _cancelSubscriptions();
    super.onClose();
  }

  void _cancelSubscriptions() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  void _clearControllers() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    taxNoController.dispose();
    doorNoController.dispose();
    pincodeController.dispose();
    descriptionController.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      isLoading(true);
      await Future.wait([_loadProfileData()]);
    } catch (e) {
      showError('Failed to load initial data');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _loadProfileData() async {
    final profile = await _profileRepository.getProfile();
    _populateForm(profile);
  }

  void _populateForm(ProfileModel profile) {
    // Basic info
    nameController.text = profile.name;
    emailController.text = profile.email;
    companyController.text = profile.companyName ?? '';
    taxNoController.text = profile.taxNo ?? '';
    descriptionController.text = profile.description ?? '';
    // Address fields
    doorNoController.text = profile.doorNo;
    pincodeController.text = profile.pincode.toString();
    locationController.text = profile.location.toString();
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

  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        imagePath(pickedFile.path);
        final bytes = await pickedFile.readAsBytes();
        base64Image(base64Encode(bytes));
      }
    } catch (e) {
      showError('Failed to pick image');
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting(true);

      final response = await _profileRepository.updateProfile({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "door_no": doorNoController.text.trim(),
        "pincode": pincodeController.text.trim(),
        "description": descriptionController.text.trim(),
        "company_name": companyController.text.trim(),
        "tax_no": taxNoController.text.trim(),
        "locations": generateGoogleMapsUrl(latitude.value, longitude.value),
        if (base64Image.isNotEmpty) "img": "data:image/png;base64,$base64Image",
      });

      if (response) {
        final details = Get.put(ProfileController());
        details.fetchProfile();
        Get.back();
        showSuccess('Profile updated successfully');
      }
    } catch (e) {
      showError('Failed to update profile');
    } finally {
      isSubmitting(false);
    }
  }
}
