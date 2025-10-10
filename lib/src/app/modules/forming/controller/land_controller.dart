import 'package:argiot/src/app/modules/document/model/add_document_model.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart' hide State;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../routes/app_routes.dart';
import '../../../service/utils/enums.dart';
import '../../../service/utils/utils.dart';
import '../../../bindings/app_binding.dart';
import '../../../controller/app_controller.dart';
import '../../manager/model/dropdown_model.dart';
import '../../registration/model/dropdown_item.dart';
import '../../registration/model/land_model.dart';
import '../../registration/model/survey_model.dart';
import '../../registration/repostrory/crop_service.dart';
import '../../registration/repostrory/land_service.dart';
import '../../registration/view/screen/location_picker_view.dart';
import '../model/measurement_unit.dart';

class LandController extends GetxController {
  final LandService _landService = Get.find();
  final AppDataController appDeta = Get.put(AppDataController());
  // Form controllers
  final landIdController = TextEditingController();
  final pattaNoController = TextEditingController();

  var managers = <DrapDown>[].obs;
  final pincodeController = TextEditingController();
  final addressController = TextEditingController();
  final measurementController = TextEditingController();
  final locationListController = TextEditingController();
  final RxList<LatLng?> landCoordinates = <LatLng>[].obs;
  final RxList geoMarks = [].obs;
  final descriptionController =
      TextEditingController(); // Added for description

  // Dropdown values
  final RxList<AppDropdownItem> landUnits = <AppDropdownItem>[].obs;
  final RxList<AppDropdownItem> soilTypes = <AppDropdownItem>[].obs;
  final RxList<AppDropdownItem> documentTypes = <AppDropdownItem>[].obs;

  // Selected values
  final Rx<AppDropdownItem?> selectedLandUnit = Rx<AppDropdownItem?>(null);
  final Rx<AppDropdownItem?> selectedSoilType = Rx<AppDropdownItem?>(null);
  final Rx<AppDropdownItem?> selectedDocType = Rx<AppDropdownItem?>(null);
  final Rx<DrapDown?> selectedManger = Rx<DrapDown?>(null);

  // Location
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  // Dynamic lists
  final RxList<SurveyItem> surveyItems = <SurveyItem>[].obs;
  final RxList<AddDocumentModel> documentItems = <AddDocumentModel>[].obs;

  // Loading states
  final RxBool isLoadingLandUnits = false.obs;
  final RxBool newSurveyItems = false.obs;
  final RxBool isLoadingSoilTypes = false.obs;
  final RxBool isLoadingDocTypes = false.obs;
  final RxBool isSubmitting = false.obs;
  var isLoadingManager = false.obs;
  final formKey = GlobalKey<FormState>();
  var landDetail = LandDetail(
    id: 0,
    name: '',
    measurementValue: 0,
    measurementUnit: MeasurementUnit(id: 0, name: ''),
    doorNo: '',
    locations: '',
    latitude: 0,
    longitude: 0,
    geoMarks: [],
    pattaNumber: '',
    status: 0,
    lStatus: 0,
    surveyDetails: [],
    documents: [],
  ).obs;
  var landId = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([loadLandUnits(), loadSoilTypes(), loadManagers()]);
    if (landId.value != 0) {
      await fetchLandDetail();
      _populateFormWithExistingData();
    }
  }

  Future<void> loadManagers() async {
    try {
      isLoadingManager.value = true;
      final data = await _landService.fetchAssignManager();
      managers.value = data;
    } catch (e) {
      print('Error fetching managers: $e');
    } finally {
      isLoadingManager.value = false;
    }
  }

  Future<void> fetchLandDetail() async {
    try {
      isLoading(true);
      final result = await _landService.fetchLandDetail(landId.value);
      landDetail(result);
    } catch (e) {
      showError('failed_to_load_land_details'.tr);
    } finally {
      isLoading(false);
    }
  }

  void _populateFormWithExistingData() {
    // Populate text fields
    landIdController.text = landDetail.value.name;
    pattaNoController.text = landDetail.value.pattaNumber;
    measurementController.text = landDetail.value.measurementValue.toString();
    descriptionController.text = landDetail.value.description ?? '';

    if (landDetail.value.soilType != null &&
        landDetail.value.soilType!.id != null) {
      selectedSoilType.value = AppDropdownItem(
        id: landDetail.value.soilType!.id!,
        name: landDetail.value.soilType!.name!,
      );
    }
    var list = parseLngListFromString(landDetail.value.geoMarks).toList();
    landCoordinates.value = list;
    geoMarks.value = landDetail.value.geoMarks;
    locationListController.text = landDetail.value.geoMarks.toString();
    // Set location data
    latitude.value = landDetail.value.latitude;
    pincodeController.text = "0";
    longitude.value = landDetail.value.longitude;
    selectedLandUnit.value = AppDropdownItem(
      id: landDetail.value.measurementUnit.id,
      name: landDetail.value.measurementUnit.name,
    );
    if (landDetail.value.manager?.id != null) {
      selectedManger.value = managers.firstWhereOrNull(
        (manager) => manager.id == landDetail.value.manager!.id!,
      );
    }
    if (landDetail.value.soilType?.id != null) {
      selectedSoilType.value = soilTypes.firstWhereOrNull(
        (soilType) => soilType.id == landDetail.value.soilType!.id!,
      );
    }
    // Populate survey items
    surveyItems.clear();
    for (var survey in landDetail.value.surveyDetails) {
      surveyItems.add(
        SurveyItem(
          id: survey.id,
          surveyNo: survey.surveyNo!,
          measurement: survey.measurementValue.toString(),
          unit: landUnits.firstWhere(
            (unit) => unit.name == survey.measurementUnit,
          ),
        ),
      );
    }
  }

  Future<void> loadLandUnits() async {
    try {
      isLoadingLandUnits(true);
      final result = await _landService.getLandUnits();
      landUnits.assignAll(result);

      if (landDetail.value.id != 0) {
        selectedLandUnit.value = result.firstWhereOrNull(
          (e) => e.id == landDetail.value.measurementUnit.id,
        );
      } else if (result.isNotEmpty) {
        selectedLandUnit.value = result.first;
      }
    } finally {
      isLoadingLandUnits(false);
    }
  }

  Future<void> loadSoilTypes() async {
    try {
      isLoadingSoilTypes(true);
      final result = await _landService.getSoilTypes();
      soilTypes.assignAll(result);
    } finally {
      isLoadingSoilTypes(false);
    }
  }

  // Future<void> loadDocumentTypes() async {
  //   try {
  //     isLoadingDocTypes(true);
  //     final result = await _landService.getDocumentTypes(2); // 2 for Land docs
  //     documentTypes.assignAll(result);
  //   } finally {
  //     isLoadingDocTypes(false);
  //   }
  // }

  void addSurveyItem() {
    newSurveyItems.value = true;
    surveyItems.add(
      SurveyItem(surveyNo: '', measurement: '', unit: landUnits.firstOrNull),
    );
  }

  void removeSurveyItem(int index) {
    surveyItems.removeAt(index);
  }

  void addDocumentItem() {
    Get.toNamed(Routes.addDocument, arguments: {"type": DocTypes.land})?.then((
      result,
    ) {
      if (result != null && result is AddDocumentModel) {
        documentItems.add(result);
      }
      print(documentItems.toString());
    });
  }

  void removeDocumentItem(int index) {
    documentItems.removeAt(index);
  }

  Future<void> listpickLocation() async {
    print(locationListController.text);
    try {
      final location = await Get.to(
        const LandPickerView(),
        arguments: {
          if (landCoordinates.isNotEmpty) 'crop': landCoordinates,
          "zoom": true,
        },
        binding: LandPickerViewerBinding(),
      );
      if (location != null) {
        landCoordinates.value = parseLatLngListFromString(location).toList();
        latitude.value = location[0][0];
        longitude.value = location[0][1];
        geoMarks.value = location;
        locationListController.text = location.toString();
        Map addressFromLatLng = await getAddressFromLatLng(
          latitude: location[0][0],
          longitude: location[0][1],
        );
        addressController.text = addressFromLatLng['address'] ?? '';
        pincodeController.text = addressFromLatLng['pincode'] ?? '';
        measurementController.text = calculatePolygonAreaAcre(
          points: landCoordinates,
        ).toString();
      }
    } catch (e) {
      showError('Failed to pick location');
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting(true);

      final dynamic surveyDetails;
      if (landId.value != 0) {
        surveyDetails = surveyItems.map((survey) {
          Map map = {
            if (survey.id != null) "id": survey.id,
            "survey_no": survey.surveyNo,
            "survey_measurement_value": survey.measurement,
            "survey_measurement_unit": survey.unit?.id,
          };
          return map;
        }).toList();
      } else {
        surveyDetails = surveyItems.asMap().map(
          (index, item) => MapEntry(
            'survey_details_${index + 1}',
            'survey_no:${item.surveyNo},'
                'survey_measurement_value:${item.measurement},'
                'survey_measurement_unit_id:${item.unit?.id}',
          ),
        );
      }

      final documentItemsList = documentItems.map((doc) {
        var json = doc.toJson();
        return json;
      }).toList();

      // Create request based on whether we're creating or editing
      final request = {
        if (landId.value != 0) "id": landId.value,
        "farmer": appDeta.farmerId.value,
        "name": landIdController.text.trim(),
        "measurement_value": double.parse(measurementController.text.trim()),
        "measurement_unit": selectedLandUnit.value?.id,
        if (selectedSoilType.value?.id != null)
          "soil_type": selectedSoilType.value?.id,
        "manager": selectedManger.value?.id,
        "locations": generateGoogleMapsUrl(latitude.value, longitude.value),
        "door_no": addressController.text,
        "pincode": pincodeController.text,
        "l_status": 0,
        "geo_marks": convertLatLngListToMap(landCoordinates),
        if (pattaNoController.text.isNotEmpty)
          "patta_number": pattaNoController.text.trim(),
        if (descriptionController.text.isNotEmpty)
          "description": descriptionController.text.trim(),
        if (newSurveyItems.value && landId.value == 0) ...surveyDetails,
        if (landId.value != 0) "surveyDetails": surveyDetails,
        "document": documentItemsList,
      };

      // Call appropriate API based on whether we're creating or editing
      if (landId.value == 0) {
        // Create new land
        await _landService.addLand(request: request);

        Get.back(result: true);
        showSuccess('Land added successfully');
      } else {
        // Edit existing land
        await _landService.editLand(request: request);
        Get.back(result: true);
        showSuccess('Land updated successfully');
      }
    } catch (e) {
      showError('Error: ${e.toString()}');
    } finally {
      isSubmitting(false);
    }
  }

  @override
  void onClose() {
    landIdController.dispose();
    pattaNoController.dispose();
    measurementController.dispose();

    descriptionController.dispose();
    super.onClose();
  }
}
