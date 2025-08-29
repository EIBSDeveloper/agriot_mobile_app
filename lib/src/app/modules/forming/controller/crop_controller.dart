import 'dart:convert';

import 'package:argiot/src/app/modules/forming/controller/forming_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http show Response;
import 'package:intl/intl.dart';

import '../../../../utils.dart';
import '../../../bindings/app_binding.dart';
import '../../../controller/app_controller.dart';
import '../../near_me/model/models.dart';
import '../../registration/model/crop_model.dart';
import '../../registration/model/dropdown_item.dart';
import '../../registration/repostrory/crop_service.dart';
import '../../registration/repostrory/land_service.dart';
import '../../registration/view/screen/location_picker_view.dart';

class CropController extends GetxController {
  final LandService _landService = Get.find();
  final CropService _cropService = Get.find();
  final AppDataController appData = Get.find();

  late final String baseUrl = appData.baseUrl.value;
  late final String baseUrlIWithodAPi = appData.baseUrlIWithodAPi.value;
  final measurementController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  final RxList<DropdownItem> cropTypes = <DropdownItem>[].obs;
  final RxList<DropdownItem> crops = <DropdownItem>[].obs;
  final RxList<DropdownItem> harvestFrequencies = <DropdownItem>[].obs;
  var lands = <Land>[].obs;

  var selectedLand = Land(id: 0, name: '').obs;
  var parameterLandID = 0.obs;
  var selectedSurvey = Rxn<CropSurveyDetail>();
  var surveyList = <CropSurveyDetail>[].obs;

  final Rx<DateTime?> plantationDate = Rx<DateTime?>(null);
  final Rx<DropdownItem?> selectedCropType = Rx<DropdownItem?>(null);
  final Rx<DropdownItem?> selectedCrop = Rx<DropdownItem?>(null);
  final Rx<DropdownItem?> selectedHarvestFrequency = Rx<DropdownItem?>(null);
  final RxList<DropdownItem> landUnits = <DropdownItem>[].obs;
  final Rx<DropdownItem?> selectedMeasurementUnit = Rx<DropdownItem?>(null);

  final RxBool isLoadingCropTypes = false.obs;
  final RxBool isLoadingCrops = false.obs;
  final RxBool isLoadingHarvestFrequencies = false.obs;
  final RxBool isLoadingLands = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxList<LatLng?> landCoordinates = <LatLng>[].obs;
  final RxList<LatLng?> cropCoordinates = <LatLng>[].obs;
  final RxList geoMarks = [].obs;
  final formKey = GlobalKey<FormState>();

  int? editingCropId;
  int? editingLandId;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    ever(selectedCropType, (_) => _loadCrops());
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      loadCropTypes(),
      loadHarvestFrequencies(),
      fetchLands(),
      loadLandUnits(),
    ]);
  }

  Future<void> loadCropDetails(int landId, int cropId) async {
    try {
      isSubmitting(true);
      editingCropId = cropId;
      editingLandId = landId;

      final data = await _cropService.getCropDetails(landId, cropId);

      measurementController.text = data["measurement_value"].toString();
      descriptionController.text = data["description"] ?? "";

      selectedCropType.value = cropTypes.firstWhereOrNull(
        (e) => e.id == data["crop_type"]["id"],
      );
      await _loadCrops();
      selectedCrop.value = crops.firstWhereOrNull(
        (e) => e.id == data["crop"]["id"],
      );
      selectedHarvestFrequency.value = harvestFrequencies.firstWhereOrNull(
        (e) => e.id == data["harvesting_type"]["id"],
      );

      selectedLand.value =
          lands.firstWhereOrNull((e) => e.id == data["land"]["id"]) ??
          lands.first;
      await loadSurveyDetails(selectedLand.value.id);
      selectedSurvey.value = surveyList.firstWhereOrNull(
        (e) => e.id == data["survey_details"].first["id"],
      );

      selectedMeasurementUnit.value = landUnits.firstWhereOrNull(
        (e) => e.id == data["measurement_unit"]["id"],
      );
      cropCoordinates.value = parseLatLngMapFromString(
        data['geo_marks'] ?? [],
      ).toList();
      locationController.text = data['geo_marks'].toString();
      geoMarks.value = data['geo_marks'];
      plantationDate.value = DateTime.parse(data["plantation_date"]);
    } catch (e) {
      showError("Failed to load crop details");
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> loadLandUnits() async {
    final result = await _landService.getLandUnits();
    landUnits.assignAll(result);
    if (result.isNotEmpty) selectedMeasurementUnit.value = result.first;
  }

  Future<void> loadCropTypes() async {
    isLoadingCropTypes(true);
    cropTypes.assignAll(await _cropService.getCropTypes());
    isLoadingCropTypes(false);
  }

  Future<void> _loadCrops() async {
    if (selectedCropType.value == null) return;
    isLoadingCrops(true);
    crops.assignAll(await _cropService.getCrops(selectedCropType.value!.id));
    selectedCrop.value = null;
    isLoadingCrops(false);
  }

  Future<void> loadHarvestFrequencies() async {
    isLoadingHarvestFrequencies(true);
    harvestFrequencies.assignAll(await _cropService.getHarvestFrequencies());
    isLoadingHarvestFrequencies(false);
  }

  Future<void> fetchLands() async {
    isLoadingLands(true);
    final landList = await _landService.getLands();
    lands.assignAll(landList.lands);
    if (parameterLandID.value != 0) {
      var firstWhere = lands.firstWhere(
        (land) => land.id == parameterLandID.value,
      );
      selectedLand.value = firstWhere;
      loadSurveyDetails(firstWhere.id);
    } else if (lands.isNotEmpty) {
      selectedLand.value = lands.first;
      loadSurveyDetails(lands.first.id);
    }
    isLoadingLands(false);
  }

  Future<void> loadSurveyDetails(int landId) async {
    List land = await _cropService.getSurveyDetails(landId: landId);
    surveyList.value = land[0];
    landCoordinates.value = land[1];
    
    if (surveyList.isNotEmpty) selectedSurvey.value = surveyList.first;
  }

  Future<void> selectPlantationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) plantationDate.value = picked;
  }

  Future<void> pickLocation() async {
    try {
      final location = await Get.to(
        LandPickerView(),
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
    } catch (e) {
      showError('Failed to pick location');
    }
  }

  void changeLand(Land landId) {
    selectedLand.value = landId;
    loadSurveyDetails(landId.id);
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedSurvey.value == null) {
      showError('Please select survey details');
      return;
    }

    try {
      isSubmitting(true);

      final formattedDate = DateFormat(
        "yyyy-MM-dd",
      ).format(plantationDate.value!);

      final request = {
        if (editingCropId != null) "crop_id": editingCropId,
        "farmer": appData.userId.value,
        "crop_type": selectedCropType.value!.id,
        "crop": selectedCrop.value!.id,
        "harvesting_type": selectedHarvestFrequency.value!.id,
        "plantation_date": formattedDate,
        "land": selectedLand.value.id,
        "survey_details": [selectedSurvey.value!.id],
        "status": 0,
        "description": descriptionController.text.trim(),
        "measurement_value": measurementController.text.trim(),
        "measurement_unit": selectedMeasurementUnit.value!.id,
        "geo_marks": convertLatLngListToMap(cropCoordinates),
      };
      final http.Response response;
      if (editingCropId != null) {
        response = await _cropService.updateCropDetails(request);
      } else {
        response = await _cropService.addCrop(request);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        FormingController landController = Get.find();
        landController.fetchLands();
        Get.back();
        showSuccess('Success');
      } else {
        showError(json.decode(response.body)["message"]);
      }
    } catch (e) {
      showError('Error submitting crop');
    } finally {
      isSubmitting(false);
    }
  }

  @override
  void onClose() {
    measurementController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }
}
