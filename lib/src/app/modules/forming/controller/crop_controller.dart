import 'dart:convert';

import 'package:argiot/src/app/modules/forming/controller/forming_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http show Response;
import 'package:intl/intl.dart';

import '../../../service/utils/utils.dart';
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
  late final String baseUrlIWithodAPi = appData.baseUrlWithoutAPi.value;
  final measurementController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  final RxList<AppDropdownItem> cropTypes = <AppDropdownItem>[].obs;
  final RxList<AppDropdownItem> crops = <AppDropdownItem>[].obs;
  final RxList<AppDropdownItem> harvestFrequencies = <AppDropdownItem>[].obs;
  var lands = <Land>[].obs;

  var selectedLand = Land(id: 0, name: '').obs;
  var parameterLandID = 0.obs;
  var selectedSurveys = RxList<CropSurveyDetail>();
  var surveyList = <CropSurveyDetail>[].obs;

  final Rx<DateTime?> plantationDate = Rx<DateTime?>(null);
  final Rx<AppDropdownItem?> selectedCropType = Rx<AppDropdownItem?>(null);
  final Rx<AppDropdownItem?> selectedCrop = Rx<AppDropdownItem?>(null);
  final Rx<AppDropdownItem?> parameterCrop = Rx<AppDropdownItem?>(null);
  final Rx<AppDropdownItem?> selectedHarvestFrequency = Rx<AppDropdownItem?>(
    null,
  );
  final RxList<AppDropdownItem> landUnits = <AppDropdownItem>[].obs;
  final Rx<AppDropdownItem?> selectedMeasurementUnit = Rx<AppDropdownItem?>(
    null,
  );

  final RxBool isLoadingCropTypes = false.obs;
  final RxBool isLoadingCrops = false.obs;
  final RxBool isLoadingHarvestFrequencies = false.obs;
  final RxBool isLoadingLands = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxList<LatLng?> landCoordinates = <LatLng>[].obs;
  final RxList<List<LatLng>?> priviesCropCoordinates = <List<LatLng>?>[].obs;

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

      parameterCrop.value = AppDropdownItem(
        id: data["crop"]["id"],
        name: data["crop"]["name"],
      );

      selectedCropType.value = cropTypes.firstWhereOrNull(
        (e) => e.id == data["crop_type"]["id"],
      );
      selectedHarvestFrequency.value = harvestFrequencies.firstWhereOrNull(
        (e) => e.id == data["harvesting_type"]["id"],
      );

      // selectedLand.value =
      //     lands.firstWhereOrNull((e) => e.id == data["land"]["id"]) ??
      //     lands.first;
      // await loadSurveyDetails(selectedLand.value.id);
      // selectedSurveys.value = surveyList.where(
      //   (e) => e.id == data["survey_details"].first["id"],
      // ).toList();

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
    if (parameterCrop.value != null) {
      selectedCrop.value = crops.firstWhere((e) => parameterCrop.value!.id == e.id);
    } else {
      selectedCrop.value = null;
    }
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
    priviesCropCoordinates.value = land[2];
    if (surveyList.isNotEmpty) selectedSurveys.value = surveyList;
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
        const LandPickerView(),
        arguments: {
          'land': landCoordinates,
          'priviese_crop': priviesCropCoordinates,
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
    // if (selectedSurvey.value == null) {
    //   showError('Please select survey details');
    //   return;
    // }

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
        if (selectedSurveys.isNotEmpty)
          "survey_details": [...selectedSurveys.map((e)=> e.id)],
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
        Get.back(result: true);
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
