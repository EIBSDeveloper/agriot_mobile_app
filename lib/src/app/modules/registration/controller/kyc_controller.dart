import 'package:argiot/src/sercis/address_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils.dart';
import '../../../bindings/app_binding.dart';
import '../../../controller/app_controller.dart';
import '../model/address_model.dart';
import '../repostrory/address_service.dart';
import '../view/screen/landpicker.dart';
import 'resgister_controller.dart';

class KycController extends GetxController {
  final AddressService _addressService = AddressService();

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final companyController = TextEditingController();
  final taxNoController = TextEditingController();
  final doorNoController = TextEditingController();
  final pincodeController = TextEditingController();

  // Dropdown values
  final RxList<CountryModel> countries = <CountryModel>[].obs;
  final RxList<StateModel> states = <StateModel>[].obs;
  final RxList<CityModel> cities = <CityModel>[].obs;
  final RxList<TalukModel> taluks = <TalukModel>[].obs;
  final RxList<VillageModel> villages = <VillageModel>[].obs;

  // Selected values
  final Rx<CountryModel?> selectedCountry = Rx<CountryModel?>(null);
  final Rx<StateModel?> selectedState = Rx<StateModel?>(null);
  final Rx<CityModel?> selectedCity = Rx<CityModel?>(null);
  final Rx<TalukModel?> selectedTaluk = Rx<TalukModel?>(null);
  final Rx<VillageModel?> selectedVillage = Rx<VillageModel?>(null);

  // Loading states
  final RxBool isLoadingCountries = false.obs;
  final RxBool isLoadingStates = false.obs;
  final RxBool isLoadingCities = false.obs;
  final RxBool isLoadingTaluks = false.obs;
  final RxBool isLoadingVillages = false.obs;
  final RxBool isSubmitting = false.obs;

  final formKey = GlobalKey<FormState>();
  final locationController = TextEditingController();
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCountries();

    setupDropdownListeners();
  }

  void setupDropdownListeners() {
    ever(selectedCountry, (_) {
      selectedState.value = null;
      selectedCity.value = null;
      selectedTaluk.value = null;
      selectedVillage.value = null;
      if (selectedCountry.value != null) {
        loadStates(selectedCountry.value!.id!);
      } else {
        states.clear();
        cities.clear();
        taluks.clear();
        villages.clear();
      }
    });

    ever(selectedState, (_) {
      selectedCity.value = null;
      selectedTaluk.value = null;
      selectedVillage.value = null;
      if (selectedState.value != null) {
        loadCities(selectedState.value!.id!);
      } else {
        cities.clear();
        taluks.clear();
        villages.clear();
      }
    });

    ever(selectedCity, (_) {
      selectedTaluk.value = null;
      selectedVillage.value = null;
      if (selectedCity.value != null) {
        loadTaluks(selectedCity.value!.id!);
      } else {
        taluks.clear();
        villages.clear();
      }
    });

    ever(selectedTaluk, (_) {
      selectedVillage.value = null;
      if (selectedTaluk.value != null) {
        loadVillages(selectedTaluk.value!.id!);
      } else {
        villages.clear();
      }
    });
  }

  Future<void> loadCountries() async {
    AppDataController appData = Get.put(AppDataController());
    emailController.text = appData.emailId.value;
    nameController.text = appData.username.value;
    try {
      isLoadingCountries(true);
      final result = await _addressService.getCountries();
      countries.assignAll(result);
    } finally {
      isLoadingCountries(false);
    }
  }

  Future<void> loadStates(int countryId) async {
    try {
      isLoadingStates(true);
      final result = await _addressService.getStates(countryId);
      states.assignAll(result);
    } finally {
      isLoadingStates(false);
    }
  }

  Future<void> loadCities(int stateId) async {
    try {
      isLoadingCities(true);
      final result = await _addressService.getCities(stateId);
      cities.assignAll(result);
    } finally {
      isLoadingCities(false);
    }
  }

  Future<void> loadTaluks(int cityId) async {
    try {
      isLoadingTaluks(true);
      final result = await _addressService.getTaluks(cityId);
      taluks.assignAll(result);
    } finally {
      isLoadingTaluks(false);
    }
  }

  Future<void> loadVillages(int talukId) async {
    try {
      isLoadingVillages(true);
      final result = await _addressService.getVillages(talukId);
      villages.assignAll(result);
    } finally {
      isLoadingVillages(false);
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting(true);

      final farmerRepository = Get.put(FarmerRepository());
      // Call API (replace with your actual endpoint)
      Map? response = await farmerRepository.editFarmer(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        country: selectedCountry.value?.id ?? 1,
        state: selectedState.value?.id ?? 1,
        city: selectedCity.value?.id ?? 1,
        taluk: selectedTaluk.value?.id ?? 1,
        village: selectedVillage.value?.id ?? 1,
        doorNo: doorNoController.text.trim(),
        pincode: pincodeController.text.trim(),
        latitude: latitude.value,
        longitude: longitude.value,
        companyName: companyController.text.trim(),
        taxNo: taxNoController.text.trim(),
      );
      if (response != null) {
        showSuccess('KYC submitted successfully');

        // Navigate to next screen
        ResgisterController resgisterController = Get.find();
        resgisterController.moveNextPage();
      } else {
        showError('Failed');
      }
    } catch (e) {
      showError('Failed');
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> pickLocation() async {
    try {
      final location = await Get.to(
        LocationPickerView(),
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

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    companyController.dispose();
    taxNoController.dispose();
    doorNoController.dispose();
    pincodeController.dispose();
    super.onClose();
  }
}
