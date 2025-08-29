import 'package:argiot/src/app/modules/registration/controller/kyc_controller.dart';
import 'package:argiot/src/app/modules/registration/controller/resgister_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../utils.dart';
import '../../../bindings/app_binding.dart';
import '../../../controller/app_controller.dart';
import '../model/document_model.dart';
import '../model/dropdown_item.dart';
import '../model/survey_model.dart';
import '../repostrory/crop_service.dart';
import '../repostrory/land_service.dart';
import '../view/screen/location_picker_view.dart';

class RegLandController extends GetxController {
  final LandService _landService = Get.find();

  // Form controllers
  final landIdController = TextEditingController();
  final pattaNoController = TextEditingController();
  final measurementController = TextEditingController();
  // final locationController = TextEditingController();
  final locationListController = TextEditingController();
  final RxList<LatLng?> landCoordinates = <LatLng>[].obs;
  // Dropdown values
  final RxList<DropdownItem> landUnits = <DropdownItem>[].obs;
  final RxList<DropdownItem> soilTypes = <DropdownItem>[].obs;
  final RxList<DropdownItem> areaUnits = <DropdownItem>[].obs;
  final RxList<DropdownItem> documentTypes = <DropdownItem>[].obs;

  // Selected values
  final Rx<DropdownItem?> selectedLandUnit = Rx<DropdownItem?>(null);
  final Rx<DropdownItem?> selectedSoilType = Rx<DropdownItem?>(null);
  final Rx<DropdownItem?> selectedAreaUnit = Rx<DropdownItem?>(null);
  final Rx<DropdownItem?> selectedDocType = Rx<DropdownItem?>(null);

  // Location
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  // Dynamic lists
  final RxList<SurveyItem> surveyItems = <SurveyItem>[].obs;
  final RxList<DocumentItem> documentItems = <DocumentItem>[].obs;

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
    await Future.wait([
      loadLandUnits(),
      loadSoilTypes(),
      loadAreaUnits(),
      loadDocumentTypes(),
    ]);
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

  Future<void> loadAreaUnits() async {
    try {
      isLoadingAreaUnits(true);
      final result = await _landService.getAreaUnits();
      areaUnits.assignAll(result);
    } finally {
      isLoadingAreaUnits(false);
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
      SurveyItem(surveyNo: '', measurement: '', unit: areaUnits.firstOrNull),
    );
  }

  void removeSurveyItem(int index) {
    surveyItems.removeAt(index);
  }

  void addDocumentItem() {
    documentItems.add(
      DocumentItem(type: documentTypes.firstOrNull, file: null),
    );
  }

  void removeDocumentItem(int index) {
    documentItems.removeAt(index);
  }

  Future<void> listpickLocation() async {
    try {
      final location = await Get.to(
        LandPickerView(),
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
      }
    } catch (e) {
      showError('Failed to pick location');
    }
  }

  Future<void> pickDocument(int index) async {
    try {
      // Implement file picking logic
      final file = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (file != null) {
        documentItems[index] = documentItems[index].copyWith(
          file: file.files.single,
        );
      }
    } catch (e) {
      showError('Failed to pick document');
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;
    // if (surveyItems.isEmpty) {
    //   Fluttertoast.showToast(
    //     msg: 'Please add survey detail',
    //     backgroundColor: Colors.orangeAccent,
    //     gravity: ToastGravity.TOP,
    //   );

    //   return;
    // }

    try {
      isSubmitting(true);

      // Prepare survey details
      final surveyDetails = surveyItems.asMap().map((index, item) {
        return MapEntry(
          'survey_details_${index + 1}',
          'survey_no:${item.surveyNo},'
              'survey_measurement_value:${item.measurement},'
              'survey_measurement_unit_id:${item.unit?.id}',
        );
      });

      // Prepare documents
      final documents = documentItems
          .where((item) => item.file != null)
          .toList();

      final AppDataController appDeta = Get.put(AppDataController());
      final request = {
        "farmer": appDeta.userId.value,
        "name": landIdController.text.trim(),
        "measurement_value": measurementController.text.trim(),
        "measurement_unit": selectedLandUnit.value?.id,
        if (selectedSoilType.value?.id != null)
          "soil_type": selectedSoilType.value?.id,
        "country": Get.find<KycController>().selectedCountry.value?.id??1,
        "state": Get.find<KycController>().selectedState.value?.id??1,
        "city": Get.find<KycController>().selectedCity.value?.id??1,
        "taluk": Get.find<KycController>().selectedTaluk.value?.id??1,
        "village": Get.find<KycController>().selectedVillage.value?.id??1,
        "door_no": Get.find<KycController>().doorNoController.text.trim(),
        "locations": "${latitude.value} , ${longitude.value} ",
        "geo_marks": convertLatLngListToMap(landCoordinates),
        "latitude": latitude.value,
        "longitude": longitude.value,
        if (pattaNoController.text.isNotEmpty)
          "patta_number": pattaNoController.text.trim(),
        if (surveyItems.isNotEmpty) ...surveyDetails,
      };

      // Call API
      final response = await _landService.addLand(
        request: request,
        documents: documents,
      );

      showSuccess('Land added successfully');

      // Navigate to next screen

      ResgisterController resgisterController = Get.find();
      resgisterController.moveNextPage();
    } catch (e) {
      showError('Error');
    } finally {
      isSubmitting(false);
    }
  }

  @override
  void onClose() {
    landIdController.dispose();
    pattaNoController.dispose();
    measurementController.dispose();
    locationListController.dispose();
    super.onClose();
  }
}
