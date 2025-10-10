import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../bindings/app_binding.dart';
import '../../../controller/app_controller.dart';
import '../../../service/utils/utils.dart';
import '../repostrory/address_service.dart';
import '../view/screen/landpicker.dart';
import 'resgister_controller.dart';

class KycController extends GetxController {
  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  final companyController = TextEditingController();
  final taxNoController = TextEditingController();
  final doorNoController = TextEditingController();
  final pincodeController = TextEditingController();

  // Loading states
  final RxBool isEmailLogin = false.obs;
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
    loadData();
  }

  Future<void> loadData() async {
    AppDataController appData = Get.put(AppDataController());
    isEmailLogin.value = appData.emailId.value.isNotEmpty;
    emailController.text = appData.emailId.value;
    nameController.text = appData.username.value;
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting(true);

      final farmerRepository = Get.put(FarmerRepository());
      // Call API (replace with your actual endpoint)
      Map? response = await farmerRepository.editFarmer(
        name: nameController.text.trim(),
        phone: numberController.text.trim(),
        email: emailController.text.trim(),
        doorNo: doorNoController.text.trim(),
        pincode: pincodeController.text.trim(),
        latitude: latitude.value,
        longitude: longitude.value,
        companyName: companyController.text.trim(),
        taxNo: taxNoController.text.trim(),
      );
      if (response.isNotEmpty) {
        showSuccess('KYC submitted successfully');
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
        const LocationPickerView(),
        binding: LocationViewerBinding(),
      );
      if (location != null) {
        latitude.value = location['latitude'];
        longitude.value = location['longitude'];
        locationController.text = '${latitude.value}, ${longitude.value}';
        Map addressFromLatLng = await getAddressFromLatLng(
          latitude: location['latitude'],
          longitude: location['longitude'],
        );
        doorNoController.text = addressFromLatLng['address'] ?? '';
        pincodeController.text = addressFromLatLng['pincode'] ?? '';
      }
    } catch (e) {
      showError('Failed to pick location');
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
