import 'package:argiot/src/app/modules/registration/controller/resgister_controller.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../routes/app_routes.dart';
import '../../../service/utils/enums.dart';
import '../../../service/utils/utils.dart';
import '../../../bindings/app_binding.dart';
import '../../../controller/app_controller.dart';
import '../../document/model/add_document_model.dart';
import '../model/dropdown_item.dart';
import '../model/survey_model.dart';
import '../repostrory/crop_service.dart';
import '../repostrory/land_service.dart';
import '../view/screen/location_picker_view.dart';

class RegLandController extends GetxController {
  final LandService _landService = Get.find();
  final AppDataController appDeta = Get.put(AppDataController());

  // Form controllers
  final landId = 0.obs;
  final landNameController = TextEditingController();
  final pattaNoController = TextEditingController();
  final pinCode = TextEditingController();
  
  final addressController = TextEditingController();
  final RxBool newSurveyItems = false.obs;
  final measurementController = TextEditingController();
  final locationListController = TextEditingController();
  final RxList<LatLng?> landCoordinates = <LatLng>[].obs;
  // Dropdown values
  final RxList<AppDropdownItem> landUnits = <AppDropdownItem>[].obs;
  final RxList<AppDropdownItem> soilTypes = <AppDropdownItem>[].obs;
  final RxList<AppDropdownItem> documentTypes = <AppDropdownItem>[].obs;

  // Selected values
  final Rx<AppDropdownItem?> selectedLandUnit = Rx<AppDropdownItem?>(null);
  final Rx<AppDropdownItem?> selectedSoilType = Rx<AppDropdownItem?>(null);
  final Rx<AppDropdownItem?> selectedDocType = Rx<AppDropdownItem?>(null);

  // Location
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  // Dynamic lists
  final RxList<SurveyItem> surveyItems = <SurveyItem>[].obs;
  final RxList<AddDocumentModel> documentItems = <AddDocumentModel>[].obs;

  // Loading states
  final RxBool isLoadingLandUnits = false.obs;
  final RxBool isLoadingSoilTypes = false.obs;
  final RxBool isLoadingAreaUnits = false.obs;
  final RxBool isLoadingDocTypes = false.obs;
  final RxBool isSubmitting = false.obs;

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([loadLandUnits(), loadSoilTypes(), loadDocumentTypes()]);
  }

  Future<void> loadLandUnits() async {
    try {
      isLoadingLandUnits(true);
      final result = await _landService.getLandUnits();
      landUnits.assignAll(result);
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

  Future<void> loadDocumentTypes() async {
    try {
      isLoadingDocTypes(true);
      final result = await _landService.getDocumentTypes(2); // 2 for Land docs
      documentTypes.assignAll(result);
    } finally {
      isLoadingDocTypes(false);
    }
  }

  void addSurveyItem() {
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

        locationListController.text = location.toString();
           Map addressFromLatLng = await getAddressFromLatLng(
          latitude: location['latitude'],
          longitude: location['longitude'],
        );
        // doorNoController.text = addressFromLatLng['address'] ?? '';
        // pincodeController.text = addressFromLatLng['pincode'] ?? '';
      }
      update();
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
        "name": landNameController.text.trim(),
        "measurement_value": double.parse(measurementController.text.trim()),
        "measurement_unit": selectedLandUnit.value?.id,
        if (selectedSoilType.value?.id != null)
          "soil_type": selectedSoilType.value?.id,

        "locations": generateGoogleMapsUrl(latitude.value, longitude.value),
          "door_no": addressController.text,
        "pincode": pinCode.text,
        "geo_marks": convertLatLngListToMap(landCoordinates),
        if (pattaNoController.text.isNotEmpty)
          "patta_number": pattaNoController.text.trim(),
        "description": '',
        if (newSurveyItems.value && landId.value == 0) ...surveyDetails,
        if (landId.value != 0) "surveyDetails": surveyDetails,
        "document": documentItemsList,
      };

      // Call appropriate API based on whether we're creating or editing
      if (landId.value == 0) {
        // Create new land
        Map land = await _landService.addLand(request: request);
        var land2 = land["my_land"];
        landId.value = land2["id"];
        ResgisterController resgisterController = Get.find();
        resgisterController.moveNextPage();
        showSuccess('Land added successfully');
      } else {
        // Edit existing land
        await _landService.editLand(request: request);
        ResgisterController resgisterController = Get.find();
        resgisterController.moveNextPage();
        
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
    landNameController.dispose();
    pattaNoController.dispose();
    measurementController.dispose();
    locationListController.dispose();
    super.onClose();
  }
}
