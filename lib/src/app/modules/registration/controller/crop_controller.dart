import 'dart:convert';

import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http show Response;
import 'package:intl/intl.dart';

import '../../../bindings/app_binding.dart';
import '../../../controller/app_controller.dart';
import '../../near_me/model/models.dart';
import '../model/crop_model.dart';
import '../model/dropdown_item.dart';
import '../repostrory/crop_service.dart';
import '../repostrory/land_service.dart';
import '../view/screen/location_picker_view.dart';
import 'resgister_controller.dart';

class RegCropController extends GetxController {
  final LandService _landService = Get.find();
  final CropService _cropService = Get.find();
  final AppDataController appData = Get.find();
  // Form controllers
  final measurementController = TextEditingController();

  // Dropdown values
  final RxList<AppDropdownItem> cropTypes = <AppDropdownItem>[].obs;
  final RxList<AppDropdownItem> crops = <AppDropdownItem>[].obs;
  final RxList<AppDropdownItem> harvestFrequencies = <AppDropdownItem>[].obs;
  final RxList<AppDropdownItem> landUnits = <AppDropdownItem>[].obs;

  // for test-Bala
  var selectedLand = Land(id: 0, name: '').obs;
  var lands = <Land>[].obs;

  var selectedSurvey = RxList<CropSurveyDetail>();
  var surveyList = <CropSurveyDetail>[].obs;

  // Selected values
  final Rx<DateTime?> plantationDate = Rx<DateTime?>(null);
  final Rx<AppDropdownItem?> selectedCropType = Rx<AppDropdownItem?>(null);
  final Rx<AppDropdownItem?> selectedCrop = Rx<AppDropdownItem?>(null);
  final Rx<AppDropdownItem?> selectedHarvestFrequency = Rx<AppDropdownItem?>(
    null,
  );
  // final Rx<LandWithSurvey?> selectedLand = Rx<LandWithSurvey?>(null);
  // final Rx<SurveyDetail?> selectedSurvey = Rx<SurveyDetail?>(null);
  final Rx<AppDropdownItem?> selectedMeasurementUnit = Rx<AppDropdownItem?>(
    null,
  );

  var polylinePoints = <LatLng>[].obs;
  final locationController = TextEditingController();
  final RxList<LatLng?> landCoordinates = <LatLng>[].obs;
  final RxList<LatLng?> cropCoordinates = <LatLng>[].obs;
  final RxList geoMarks = [].obs;
  // Loading states
  final RxBool isLoadingCropTypes = false.obs;
  final RxBool isLoadingCrops = false.obs;
  final RxBool isLoadingHarvestFrequencies = false.obs;
  final RxBool isLoadingLands = false.obs;
  final RxBool isSubmitting = false.obs;

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    plantationDate.value = DateTime.now();
    ever(selectedCropType, (_) => _loadCrops());
    // ever(selectedLand, (_) => _updateSurveys());
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      loadCropTypes(),
      loadHarvestFrequencies(),
      // loadLands(),
      fetchLands(),
      loadLandUnits(),
    ]);
  }

  Future<void> loadLandUnits() async {
    try {
      final result = await _landService.getLandUnits();
      landUnits.assignAll(result);
      selectedMeasurementUnit.value = result.firstOrNull;
    } catch (e) {
      showError('Failed to load land units');
    }
  }

  void changeLand(Land landId) {
    selectedLand.value = landId;
    loadSurveyDetails(landId.id);
  }

  Future<void> loadCropTypes() async {
    try {
      isLoadingCropTypes(true);
      final result = await _cropService.getCropTypes();
      cropTypes.assignAll(result);
    } finally {
      isLoadingCropTypes(false);
    }
  }

  Future<void> _loadCrops() async {
    if (selectedCropType.value == null) return;
    try {
      isLoadingCrops(true);
      final result = await _cropService.getCrops(selectedCropType.value!.id);
      crops.assignAll(result);
      selectedCrop.value = null;
    } finally {
      isLoadingCrops(false);
    }
  }

  Future<void> pickLocation() async {
    try {
      final location = await Get.to(
        const LandPickerView(),
        arguments: {
          'land': landCoordinates,
          if (cropCoordinates.isNotEmpty) 'crop': cropCoordinates,
        },
        binding: LandPickerViewerBinding(),
      );
      if (location != null) {
        locationController.text = location.toString();
        geoMarks.value = location;
        cropCoordinates.value = parseLatLngListFromString(
          location ?? [],
        ).toList();
      }     
        // measurementController.text = calculatePolygonAreaAcre(
        //   points: landCoordinates,
        // ).toString();
    } catch (e) {
      showError('Failed to pick location');
    }
  }

  Future<void> loadHarvestFrequencies() async {
    try {
      isLoadingHarvestFrequencies(true);
      final result = await _cropService.getHarvestFrequencies();
      harvestFrequencies.assignAll(result);
    } finally {
      isLoadingHarvestFrequencies(false);
    }
  }

  Future<void> fetchLands() async {
    try {
      isLoadingLands(true);
      final landList = await _landService.getLands();

      lands.assignAll(landList.lands);

      if (lands.isNotEmpty) {
        selectedLand.value = lands.first;
        loadSurveyDetails(lands.first.id);
      }
    } finally {
      isLoadingLands(false);
    }
  }

  Future<void> loadSurveyDetails(int landId) async {
    final data = await _cropService.getSurveyDetails(landId: landId);
    surveyList.value = data[0];
    landCoordinates.value = data[1];
    if (data.isNotEmpty) {
      var first = data.first;
      selectedSurvey.value = first;
    }
  }

  Future<void> selectPlantationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      plantationDate.value = picked;
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting(true);
      final formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(plantationDate.value!);
      final request = {
        "farmer": appData.farmerId.value,
        "crop_type": selectedCropType.value!.id,
        "crop": selectedCrop.value!.id,
        "harvesting_type": selectedHarvestFrequency.value!.id,
        "plantation_date": formattedDate,
        "land": selectedLand.value.id,
        if (selectedSurvey.isNotEmpty)
          "survey_details": [...selectedSurvey.map((e) => e.id)],
        "taluk": 1,
        "village": 1,
        "description": "",
        "measurement_value": measurementController.text.trim(),
        "measurement_unit": selectedMeasurementUnit.value!.id,
        "geo_marks": convertLatLngListToMap(cropCoordinates),
      };

      final http.Response response = await _cropService.addCrop(request);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Get.back();
        ResgisterController registerController = Get.find();
        registerController.moveNextPage();
        showSuccess('Success');
      } else {
        showError(json.decode(response.body)["message"]);
      }

      // // Navigate to next screen or back
    } catch (e) {
      showError('Error');
    } finally {
      isSubmitting(false);
    }
  }

  @override
  void onClose() {
    measurementController.dispose();
    super.onClose();
  }
}
