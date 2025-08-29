import 'package:argiot/src/app/modules/registration/controller/kyc_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide State;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../utils.dart';
import '../../../bindings/app_binding.dart';
import '../../../controller/app_controller.dart';
import '../../registration/model/document_model.dart';
import '../../registration/model/dropdown_item.dart';
import '../../registration/model/land_model.dart';
import '../../registration/model/survey_model.dart';
import '../../registration/repostrory/crop_service.dart';
import '../../registration/repostrory/land_service.dart';
import '../../registration/view/screen/location_picker_view.dart';

class LandController extends GetxController {
  final LandService _landService = Get.find();
  final AppDataController appDeta = Get.put(AppDataController());
  // Form controllers
  final landIdController = TextEditingController();
  final pattaNoController = TextEditingController();
  final measurementController = TextEditingController();
  // final locationController = TextEditingController();
  final locationListController = TextEditingController();
  final RxList<LatLng?> landCoordinates = <LatLng>[].obs;
  final RxList geoMarks = [].obs;
  final descriptionController =
      TextEditingController(); // Added for description

  // Dropdown values
  final RxList<DropdownItem> landUnits = <DropdownItem>[].obs;
  final RxList<DropdownItem> soilTypes = <DropdownItem>[].obs;
  final RxList<DropdownItem> documentTypes = <DropdownItem>[].obs;

  // Selected values
  final Rx<DropdownItem?> selectedLandUnit = Rx<DropdownItem?>(null);
  final Rx<DropdownItem?> selectedSoilType = Rx<DropdownItem?>(null);
  final Rx<DropdownItem?> selectedDocType = Rx<DropdownItem?>(null);

  // Location
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  // Dynamic lists
  final RxList<SurveyItem> surveyItems = <SurveyItem>[].obs;
  final RxList<DocumentItem> documentItems = <DocumentItem>[].obs;

  // Loading states
  final RxBool isLoadingLandUnits = false.obs;
  final RxBool newSurveyItems = false.obs;
  final RxBool isLoadingSoilTypes = false.obs;
  final RxBool isLoadingDocTypes = false.obs;
  final RxBool isSubmitting = false.obs;

  final formKey = GlobalKey<FormState>();
  var landDetail = LandDetail(
    id: 0,
    name: '',
    measurementValue: 0,
    measurementUnit: MeasurementUnit(id: 0, name: ''),
    country: Country(id: 0, name: ''),
    state: State(id: 0, name: ''),
    city: City(id: 0, name: ''),
    taluk: Taluk(id: 0, name: ''),
    village: Village(id: 0, name: ''),
    doorNo: '',
    locations: '',
    latitude: 0,
    longitude: 0,
    geoMarks: [],
    pattaNumber: '',
    status: 0,
    lStatus: 0,
    createdAt: '',
    createdBy: CreatedBy(id: 0),
    updatedAt: '',
    translateJson: TranslateJson(name: {}, doorNo: {}, description: {}),
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
    await Future.wait([loadLandUnits(), loadSoilTypes(), loadDocumentTypes()]);
    if (landId.value != 0) {
      await fetchLandDetail();
      _populateFormWithExistingData();
    }
  }

  Future<void> fetchLandDetail() async {
    try {
      isLoading(true);
      final result = await _landService.fetchLandDetail(landId.value);
      landDetail(result);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'failed_to_load_land_details'.tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
      );
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

    // Set selected dropdown values
    selectedLandUnit.value = DropdownItem(
      id: landDetail.value.measurementUnit.id,
      name: landDetail.value.measurementUnit.name,
    );

    if (landDetail.value.soilType != null &&
        landDetail.value.soilType!.id != null) {
      selectedSoilType.value = DropdownItem(
        id: landDetail.value.soilType!.id!,
        name: landDetail.value.soilType!.name!,
      );
    }
    landCoordinates.value = parseLatLngListFromString(
      landDetail.value.geoMarks,
    ).toList();
    geoMarks.value = landDetail.value.geoMarks;
    locationListController.text = landDetail.value.geoMarks.toString();
    // Set location data
    latitude.value = landDetail.value.latitude;
    longitude.value = landDetail.value.longitude;

    // Populate survey items
    surveyItems.clear();
    for (var survey in landDetail.value.surveyDetails) {
      surveyItems.add(
        SurveyItem(
          id: survey.id,
          surveyNo: survey.surveyNo!,
          measurement: survey.measurementValue.toString(),
        ),
      );
    }

    // Populate document items
    documentItems.clear();
    for (var doc in landDetail.value.documents) {
      documentItems.add(
        DocumentItem(
          type: DropdownItem(
            id: doc.documentCategory.id,
            name: doc.documentCategory.name,
          ),

          file: null, // Existing file, not a new one
        ),
      );
    }
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
    newSurveyItems.value = true;
    surveyItems.add(
      SurveyItem(surveyNo: '', measurement: '', unit: landUnits.firstOrNull),
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
        geoMarks.value = location;
        locationListController.text = location.toString();
      }
    } catch (e) {
      showError('Failed to pick location');
    }
  }

  Future<void> pickDocument(int index) async {
    try {
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
    //   showError('Please add at least one survey detail');
    //   return;
    // }

    try {
      isSubmitting(true);

      // Prepare survey details
      // final surveyDetails = surveyItems.map((item) {
      //   return {
      //     if (item.id != null) "id": item.id,
      //     "survey_no": item.surveyNo,
      //     "survey_measurement_value": double.parse(item.measurement),
      //     "survey_measurement_unit": item.unit?.id,
      //   };
      // }).toList();
      final surveyDetails = surveyItems.asMap().map((index, item) {
        return MapEntry(
          'survey_details_${index + 1}',
          'survey_no:${item.surveyNo},'
              'survey_measurement_value:${item.measurement},'
              'survey_measurement_unit_id:${item.unit?.id}',
        );
      });

      // Prepare documents
      // final documents = documentItems
      //     .where((item) => item.file != null || item.filePath != null)
      //     .map((item) {
      //       return {
      //         if (item.id != null) "id": item.id,
      //         "document_category": item.type?.id,
      //         if (item.file != null) "upload_document": item.file,
      //         if (item.filePath != null) "upload_document": item.filePath,
      //       };
      //     })
      //     .toList();

      // Create request based on whether we're creating or editing
      final request = {
        if (landId.value != 0) "id": landId.value,
        "farmer": appDeta.userId.value,
        "name": landIdController.text.trim(),
        "measurement_value": double.parse(measurementController.text.trim()),
        "measurement_unit": selectedLandUnit.value?.id,
        if (selectedSoilType.value?.id != null)
          "soil_type": selectedSoilType.value?.id,
        "country": Get.find<KycController>().selectedCountry.value?.id,
        "state": Get.find<KycController>().selectedState.value?.id,
        "city": Get.find<KycController>().selectedCity.value?.id,
        "taluk": Get.find<KycController>().selectedTaluk.value?.id,
        "village": Get.find<KycController>().selectedVillage.value?.id,
        "door_no": Get.find<KycController>().doorNoController.text.trim(),
        "locations": "${latitude.value} , ${longitude.value} ",
        "latitude": latitude.value,
        "longitude": longitude.value,
        "l_status": 0,
        "geo_marks": convertLatLngListToMap(landCoordinates),
        if (pattaNoController.text.isNotEmpty)
          "patta_number": pattaNoController.text.trim(),
        if (descriptionController.text.isNotEmpty)
          "description": descriptionController.text.trim(),
        if (newSurveyItems.value) ...surveyDetails,
        // "documents": documents,
      };

      // Call appropriate API based on whether we're creating or editing
      if (landId.value == 0) {
        // Create new land
        var res = await _landService.addLand(request: request, documents: []);
        Get.back();
        showSuccess('Land added successfully');
      } else {
        // Edit existing land
        var res = await _landService.editLand(request: request, documents: []);
        Get.back();
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
