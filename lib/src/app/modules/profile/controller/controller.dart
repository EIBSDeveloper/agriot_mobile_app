// lib/app/modules/profile/repositories/profile_repository.dart

import 'dart:async';
import 'dart:convert';

import 'package:argiot/src/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../utils.dart';
import '../../../bindings/app_binding.dart';
import '../../../controller/app_controller.dart';
import '../../../utils/http/http_service.dart';
import '../../registration/view/screen/landpicker.dart';
import '../model/model.dart';

class ProfileRepository {
  final HttpService _httpService = Get.find();
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final farmerId = Get.find<AppDataController>().userId.value;
    final response = await _httpService.put('/edit_farmer/$farmerId', data);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<ProfileModel> getProfile() async {
    final farmerId = Get.find<AppDataController>().userId.value;
    final response = await _httpService.get('/get_farmer/$farmerId');
    if (response.statusCode == 200) {
      return ProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }
}

class ProfileController extends GetxController {
  final ProfileRepository _profileRepository = Get.find();
  final Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    fetchProfile();
    super.onInit();
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // final response = await _repository.logout();

      // if (response.success) {
      // Clear storage and navigate to login
      signOutFromGoogle();
      await GetStorage().erase();

      Get.offAllNamed(Routes.login);
      // } else {
      //   Fluttertoast.showToast();
      // }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to logout',
        backgroundColor: Colors.redAccent,
        // gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> signOutFromGoogle() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Disconnect and sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect(); // Optional: removes account
        await googleSignIn.signOut();
      }

      debugPrint('✅ Successfully signed out from Google and Firebase');
    } catch (e) {
      debugPrint('🔥 Sign-out failed: $e');
    }
  }
  Future<void> fetchProfile() async {
    try {
      isLoading(true);

      final profileData = await _profileRepository.getProfile();
      profile(profileData);
    } catch (e) {
      showError('Failed to fetch profile');
    } finally {
      isLoading(false);
    }
  }
}

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

  // Dropdown data
  // final RxList<CountryModel> countries = <CountryModel>[].obs;
  // final RxList<StateModel> states = <StateModel>[].obs;
  // final RxList<CityModel> cities = <CityModel>[].obs;
  // final RxList<TalukModel> taluks = <TalukModel>[].obs;
  // final RxList<VillageModel> villages = <VillageModel>[].obs;

  // Selected values
  // final Rx<CountryModel?> selectedCountry = Rx<CountryModel?>(null);
  // final Rx<StateModel?> selectedState = Rx<StateModel?>(null);
  // final Rx<CityModel?> selectedCity = Rx<CityModel?>(null);
  // final Rx<TalukModel?> selectedTaluk = Rx<TalukModel?>(null);
  // final Rx<VillageModel?> selectedVillage = Rx<VillageModel?>(null);

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

  // void _setupDropdownListeners() {
  //   ever(selectedCountry, (_) => _onCountryChanged());
  //   ever(selectedState, (_) => _onStateChanged());
  //   ever(selectedCity, (_) => _onCityChanged());
  //   ever(selectedTaluk, (_) => _onTalukChanged());
  // }

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
      await Future.wait([ _loadProfileData()]);
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

    // Address fields
    doorNoController.text = profile.doorNo;
    pincodeController.text = profile.pincode.toString();
    locationController.text = profile.location.toString();
    // Set dropdown values if they exist
    // _setInitialAddressValues(
    //   countryId: profile.countryId,
    //   stateId: profile.stateId,
    //   cityId: profile.cityId,
    //   talukId: profile.talukId,
    //   villageId: profile.villageId,
    // );
  }

  // Future<void> _setInitialAddressValues({
  //   int? countryId,
  //   int? stateId,
  //   int? cityId,
  //   int? talukId,
  //   int? villageId,
  // }) async {
  //   // Set country if exists
  //   if (countryId != null) {
  //     final country = countries.firstWhereOrNull((c) => c.id == countryId);
  //     if (country != null) {
  //       selectedCountry(country);
  //       await loadStates(countryId);

  //       // Set state if exists
  //       if (stateId != null) {
  //         final state = states.firstWhereOrNull((s) => s.id == stateId);
  //         if (state != null) {
  //           selectedState(state);
  //           await loadCities(stateId);

  //           // Set city if exists
  //           if (cityId != null) {
  //             final city = cities.firstWhereOrNull((c) => c.id == cityId);
  //             if (city != null) {
  //               selectedCity(city);
  //               await loadTaluks(cityId);

  //               // Set taluk if exists
  //               if (talukId != null) {
  //                 final taluk = taluks.firstWhereOrNull((t) => t.id == talukId);
  //                 if (taluk != null) {
  //                   selectedTaluk(taluk);
  //                   await loadVillages(talukId);

  //                   // Set village if exists
  //                   if (villageId != null) {
  //                     final village = villages.firstWhereOrNull(
  //                       (v) => v.id == villageId,
  //                     );
  //                     if (village != null) {
  //                       selectedVillage(village);
  //                     }
  //                   }
  //                 }
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }
  //   } else {}
  // }

  // void _onCountryChanged() {
  //   selectedState.value = null;
  //   selectedCity.value = null;
  //   selectedTaluk.value = null;
  //   selectedVillage.value = null;

  //   if (selectedCountry.value != null) {
  //     loadStates(selectedCountry.value!.id!);
  //   } else {
  //     states.clear();
  //     cities.clear();
  //     taluks.clear();
  //     villages.clear();
  //   }
  // }

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
      Get.snackbar('Error', 'Failed to pick location');
    }
  }

  // void _onStateChanged() {
  //   selectedCity.value = null;
  //   selectedTaluk.value = null;
  //   selectedVillage.value = null;

  //   if (selectedState.value != null) {
  //     loadCities(selectedState.value!.id!);
  //   } else {
  //     cities.clear();
  //     taluks.clear();
  //     villages.clear();
  //   }
  // }

  // void _onCityChanged() {
  //   selectedTaluk.value = null;
  //   selectedVillage.value = null;

  //   if (selectedCity.value != null) {
  //     loadTaluks(selectedCity.value!.id!);
  //   } else {
  //     taluks.clear();
  //     villages.clear();
  //   }
  // }

  // void _onTalukChanged() {
  //   selectedVillage.value = null;

  //   if (selectedTaluk.value != null) {
  //     loadVillages(selectedTaluk.value!.id!);
  //   } else {
  //     villages.clear();
  //   }
  // }

  // Future<void> loadCountries() async {
  //   try {
  //     isLoadingCountries(true);
  //     final result = await _addressService.getCountries();
  //     countries.assignAll(result);
  //   } catch (e) {
  //     showError('Failed to load countries');
  //   } finally {
  //     isLoadingCountries(false);
  //   }
  // }

  // Future<void> loadStates(int countryId) async {
  //   try {
  //     isLoadingStates(true);
  //     final result = await _addressService.getStates(countryId);
  //     states.assignAll(result);
  //   } catch (e) {
  //     showError('Failed to load states');
  //   } finally {
  //     isLoadingStates(false);
  //   }
  // }

  // Future<void> loadCities(int stateId) async {
  //   try {
  //     isLoadingCities(true);
  //     final result = await _addressService.getCities(stateId);
  //     cities.assignAll(result);
  //   } catch (e) {
  //     showError('Failed to load cities');
  //   } finally {
  //     isLoadingCities(false);
  //   }
  // }

  // Future<void> loadTaluks(int cityId) async {
  //   try {
  //     isLoadingTaluks(true);
  //     final result = await _addressService.getTaluks(cityId);
  //     taluks.assignAll(result);
  //   } catch (e) {
  //     showError('Failed to load taluks');
  //   } finally {
  //     isLoadingTaluks(false);
  //   }
  // }

  // Future<void> loadVillages(int talukId) async {
  //   try {
  //     isLoadingVillages(true);
  //     final result = await _addressService.getVillages(talukId);
  //     villages.assignAll(result);
  //   } catch (e) {
  //     showError('Failed to load villages');
  //   } finally {
  //     isLoadingVillages(false);
  //   }
  // }



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
