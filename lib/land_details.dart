import 'dart:convert';
import 'package:argiot/src/app/bindings/app_binding.dart';
import 'package:argiot/src/app/modules/registration/controller/kyc_controller.dart';
import 'package:argiot/src/app/modules/registration/model/address_model.dart';
import 'package:argiot/src/app/modules/registration/model/document_model.dart';
import 'package:argiot/src/app/modules/registration/model/dropdown_item.dart';
import 'package:argiot/src/app/modules/registration/model/land_model.dart';
import 'package:argiot/src/app/modules/registration/model/survey_model.dart';
import 'package:argiot/src/app/modules/registration/view/screen/landpicker.dart';
import 'package:argiot/src/app/modules/registration/view/widget/document_item_widget.dart';
import 'package:argiot/src/app/modules/registration/view/widget/searchable_dropdown.dart';
import 'package:argiot/src/app/modules/registration/view/widget/survey_item_widget.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class LandDetails {
  final int id;
  final String farmer;
  final String name;
  final String measurementValue;
  final String measurementUnit;
  final String soilType;
  final String country;
  final String state;
  final String city;
  final String taluk;
  final String village;
  final String doorNo;
  final String locations;
  final double latitude;
  final double longitude;
  final String pattaNumber;
  final String? description;
  final int status;
  final List<SurveyDetail> surveyDetails;
  final List<LandDocument> documents;

  LandDetails({
    required this.id,
    required this.farmer,
    required this.name,
    required this.measurementValue,
    required this.measurementUnit,
    required this.soilType,
    required this.country,
    required this.state,
    required this.city,
    required this.taluk,
    required this.village,
    required this.doorNo,
    required this.locations,
    required this.latitude,
    required this.longitude,
    required this.pattaNumber,
    this.description,
    required this.status,
    required this.surveyDetails,
    required this.documents,
  });

  factory LandDetails.fromJson(Map<String, dynamic> json) {
    return LandDetails(
      id: json['id'],
      farmer: json['farmer'],
      name: json['name'],
      measurementValue: json['measurement_value'].toString(),
      measurementUnit: json['measurement_unit'],
      soilType: json['soil_type'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      taluk: json['taluk'],
      village: json['village'],
      doorNo: json['door_no'] ?? '',
      locations: json['locations'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      pattaNumber: json['patta_number'],
      description: json['description'],
      status: json['l_status'],
      surveyDetails: (json['survey_details'] as List)
          .map((e) => SurveyDetail.fromJson(e))
          .toList(),
      documents: (json['documents'] as List)
          .map((e) => LandDocument.fromJson(e))
          .toList(),
    );
  }
}

class LandDocument {
  final int id;
  final String documentType;
  final String documentUrl;

  LandDocument({
    required this.id,
    required this.documentType,
    required this.documentUrl,
  });

  factory LandDocument.fromJson(Map<String, dynamic> json) {
    return LandDocument(
      id: json['id'],
      documentType: json['document_type'],
      documentUrl: json['document_url'],
    );
  }
}

class LandRepository {
  final HttpService _httpService = Get.find();

  Future<LandDetails> getLandDetails() async {
    try {
      final response = await _httpService.post('/get_land_details/${314}', {
        'land_id': 393,
      });
      return LandDetails.fromJson(json.decode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateLandDetails({
    required Map<String, dynamic> request,
    required List<DocumentItem> documents,
  }) async {
    try {
      final response = await _httpService.post('/update_land_details', request);

      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AppDropdownItem>> getLandUnits() async {
    try {
      final response = await _httpService.get('/get_land_units');
      return (response as List).map((e) => AppDropdownItem.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AppDropdownItem>> getSoilTypes() async {
    try {
      final response = await _httpService.get('/get_soil_types');
      return (response as List).map((e) => AppDropdownItem.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

class InventoryCommonController extends GetxController {
  // Inventory Type List
  final RxList<AppDropdownItem> inventoryTypes = <AppDropdownItem>[].obs;
  final RxBool isLoadingInventoryTypes = false.obs;

  // Inventory Category
  final RxList<AppDropdownItem> inventoryCategories = <AppDropdownItem>[].obs;
  final RxBool isLoadingInventoryCategories = false.obs;

  // Inventory Items
  final RxList<AppDropdownItem> inventoryItems = <AppDropdownItem>[].obs;
  final RxBool isLoadingInventoryItems = false.obs;

  // Documents types
  final RxList<AppDropdownItem> documentTypes = <AppDropdownItem>[].obs;
  final RxBool isLoadingDocumentTypes = false.obs;

  // Vendor List
  final RxList<AppDropdownItem> vendorList = <AppDropdownItem>[].obs;
  final RxBool isLoadingVendorList = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCommonData();
  }

  Future<void> loadCommonData() async {
    await Future.wait([
      loadInventoryTypes(),
      loadInventoryCategories(),
      loadInventoryItems(),
      loadDocumentTypes(),
      loadVendorList(),
    ]);
  }

  Future<void> loadInventoryTypes() async {
    try {
      isLoadingInventoryTypes(true);
      // Implement API call
    } finally {
      isLoadingInventoryTypes(false);
    }
  }

  Future<void> loadInventoryCategories() async {
    try {
      isLoadingInventoryCategories(true);
      // Implement API call
    } finally {
      isLoadingInventoryCategories(false);
    }
  }

  Future<void> loadInventoryItems() async {
    try {
      isLoadingInventoryItems(true);
      // Implement API call
    } finally {
      isLoadingInventoryItems(false);
    }
  }

  Future<void> loadDocumentTypes() async {
    try {
      isLoadingDocumentTypes(true);
      // Implement API call
    } finally {
      isLoadingDocumentTypes(false);
    }
  }

  Future<void> loadVendorList() async {
    try {
      isLoadingVendorList(true);
      // Implement API call
    } finally {
      isLoadingVendorList(false);
    }
  }
}

class LandEditController extends GetxController {
  final LandRepository _landRepository = Get.find();
  final InventoryCommonController _commonController = Get.find();
  final KycController _kycController = Get.find();

  // Form controllers
  final landIdController = TextEditingController();
  final pattaNoController = TextEditingController();
  final measurementController = TextEditingController();
  final locationController = TextEditingController();

  // Dropdown values
  final RxList<AppDropdownItem> landUnits = <AppDropdownItem>[].obs;
  final RxList<AppDropdownItem> soilTypes = <AppDropdownItem>[].obs;
  final RxList<AppDropdownItem> areaUnits = <AppDropdownItem>[].obs;
  RxList<AppDropdownItem> get documentTypes => _commonController.documentTypes;

  // Selected values
  final Rx<AppDropdownItem?> selectedLandUnit = Rx<AppDropdownItem?>(null);
  final Rx<AppDropdownItem?> selectedSoilType = Rx<AppDropdownItem?>(null);

  // Location
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  // Dynamic lists
  final RxList<SurveyItem> surveyItems = <SurveyItem>[].obs;
  final RxList<DocumentItem> documentItems = <DocumentItem>[].obs;

  // Loading states
  final RxBool isLoadingLandDetails = false.obs;
  final RxBool isLoadingLandUnits = false.obs;
  final RxBool isLoadingSoilTypes = false.obs;
  final RxBool isLoadingAreaUnits = false.obs;
  final RxBool isSubmitting = false.obs;

  final formKey = GlobalKey<FormState>();

  // Expose KYC controller properties and methods
  RxList<CountryModel> get countries => _kycController.countries;
  RxList<StateModel> get states => _kycController.states;
  RxList<CityModel> get cities => _kycController.cities;
  RxList<TalukModel> get taluks => _kycController.taluks;
  RxList<VillageModel> get villages => _kycController.villages;

  Rx<CountryModel?> get selectedCountry => _kycController.selectedCountry;
  Rx<StateModel?> get selectedState => _kycController.selectedState;
  Rx<CityModel?> get selectedCity => _kycController.selectedCity;
  Rx<TalukModel?> get selectedTaluk => _kycController.selectedTaluk;
  Rx<VillageModel?> get selectedVillage => _kycController.selectedVillage;

  RxBool get isLoadingCountries => _kycController.isLoadingCountries;
  RxBool get isLoadingStates => _kycController.isLoadingStates;
  RxBool get isLoadingCities => _kycController.isLoadingCities;
  RxBool get isLoadingTaluks => _kycController.isLoadingTaluks;
  RxBool get isLoadingVillages => _kycController.isLoadingVillages;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      loadLandDetails(),
      loadLandUnits(),
      loadSoilTypes(),
      loadAreaUnits(),
    ]);
  }

  Future<void> loadLandDetails() async {
    try {
      isLoadingLandDetails(true);
      final landDetails = await _landRepository.getLandDetails();
      _populateFormFields(landDetails);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load land details: ${e.toString()}',
      );
    } finally {
      isLoadingLandDetails(false);
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
      Fluttertoast.showToast(msg: 'Failed to pick location');
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
      Fluttertoast.showToast(msg: 'Failed to pick document');
    }
  }

  void _populateFormFields(LandDetails landDetails) {
    landIdController.text = landDetails.name;
    pattaNoController.text = landDetails.pattaNumber;
    measurementController.text = landDetails.measurementValue;
    locationController.text = landDetails.locations;
    latitude.value = landDetails.latitude;
    longitude.value = landDetails.longitude;

    // Set dropdown values
    selectedLandUnit.value = landUnits.firstWhereOrNull(
      (unit) => unit.name == landDetails.measurementUnit,
    );
    selectedSoilType.value = soilTypes.firstWhereOrNull(
      (soil) => soil.name == landDetails.soilType,
    );

    // Populate survey details
    surveyItems.assignAll(
      landDetails.surveyDetails.map(
        (detail) => SurveyItem(
          surveyNo: detail.surveyNo!,
          measurement: detail.measurementValue!,
          unit: areaUnits.firstWhereOrNull(
            (unit) => unit.name == detail.measurementUnit,
          ),
        ),
      ),
    );

    // Populate documents (implementation depends on your DocumentItem model)
  }

  Future<void> loadLandUnits() async {
    try {
      isLoadingLandUnits(true);
      final result = await _landRepository.getLandUnits();
      landUnits.assignAll(result);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load land units: ${e.toString()}');
    } finally {
      isLoadingLandUnits(false);
    }
  }

  Future<void> loadSoilTypes() async {
    try {
      isLoadingSoilTypes(true);
      final result = await _landRepository.getSoilTypes();
      soilTypes.assignAll(result);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load soil types: ${e.toString()}');
    } finally {
      isLoadingSoilTypes(false);
    }
  }

  Future<void> loadAreaUnits() async {
    try {
      isLoadingAreaUnits(true);
      // Implement area units loading
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load area units: ${e.toString()}');
    } finally {
      isLoadingAreaUnits(false);
    }
  }

  // Reuse your existing methods for:
  // addSurveyItem, removeSurveyItem, addDocumentItem, removeDocumentItem, pickLocation, pickDocument

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;
    if (surveyItems.isEmpty) {
      Fluttertoast.showToast(msg: 'Please add at least one survey detail');
      return;
    }
    if (documentItems.isEmpty) {
      Fluttertoast.showToast(msg: 'Please add at least one document');
      return;
    }

    try {
      isSubmitting(true);

      // Prepare request data
      final request = {
        "land_id": 393,
        "name": landIdController.text.trim(),
        "measurement_value": measurementController.text.trim(),
        "measurement_unit": selectedLandUnit.value?.id,
        "soil_type": selectedSoilType.value?.id,
        "country": _kycController.selectedCountry.value?.id,
        "state": _kycController.selectedState.value?.id,
        "city": _kycController.selectedCity.value?.id,
        "taluk": _kycController.selectedTaluk.value?.id,
        "village": _kycController.selectedVillage.value?.id,
        "door_no": _kycController.doorNoController.text.trim(),
        "locations": locationController.text.trim(),
        "latitude": latitude.value,
        "longitude": longitude.value,
        if (pattaNoController.text.isNotEmpty)
          "patta_number": pattaNoController.text.trim(),
      };

      // Call API
      final response = await _landRepository.updateLandDetails(
        request: request,
        documents: documentItems.where((doc) => doc.file != null).toList(),
      );

      Fluttertoast.showToast(
        msg: response['message'] ?? 'Land updated successfully',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );

      Get.back(result: true); // Return success to previous screen
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update land: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      isSubmitting(false);
    }
  }

  @override
  void onClose() {
    landIdController.dispose();
    pattaNoController.dispose();
    measurementController.dispose();
    locationController.dispose();
    super.onClose();
  }
}

class LandEditView extends GetView<LandEditController> {
  const LandEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('land_details'.tr),
      ),
      body: Obx(() {
        if (controller.isLoadingLandDetails.value) {
          return Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: controller.landIdController,
                  label: '${'land_identification'.tr} *',
                  validator: (value) =>
                      value!.isEmpty ? 'required_field'.tr : null,
                ),
                SizedBox(height: 14),
                _buildTextField(
                  controller: controller.pattaNoController,
                  label: '${'patta_number'.tr} *',
                  validator: (value) =>
                      value!.isEmpty ? 'required_field'.tr : null,
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        controller: controller.measurementController,
                        label: '${'measurement'.tr} *',
                        validator: (value) =>
                            value!.isEmpty ? 'required_field'.tr : null,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: SearchableDropdown<AppDropdownItem>(
                        label: '${'unit'.tr} *',
                        items: controller.landUnits,
                        displayItem: (value) => value.name.toString(),
                        selectedItem: controller.selectedLandUnit.value,
                        onChanged: (value) =>
                            controller.selectedLandUnit.value = value,
                        validator: (value) =>
                            value == null ? 'required_field'.tr : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                SearchableDropdown<AppDropdownItem>(
                  label: '${'soil_type'.tr} *',
                  items: controller.soilTypes,
                  selectedItem: controller.selectedSoilType.value,
                  onChanged: (value) =>
                      controller.selectedSoilType.value = value,
                  displayItem: (value) => value.name.toString(),
                  validator: (value) =>
                      value == null ? 'required_field'.tr : null,
                ),
                SizedBox(height: 14),
                _buildCountryDropdown(),
                SizedBox(height: 14),
                _buildStateDropdown(),
                SizedBox(height: 14),
                _buildCityDropdown(),
                SizedBox(height: 14),
                _buildTalukDropdown(),
                SizedBox(height: 14),
                _buildVillageDropdown(),
                SizedBox(height: 14),
                _buildTextField(
                  controller: controller.locationController,
                  label: '${'location_coordinates'.tr} *',
                  validator: (value) =>
                      value!.isEmpty ? 'required_field'.tr : null,
                  readOnly: true,
                  onTap: controller.pickLocation,
                ),
                SizedBox(height: 14),
                _buildSurveyDetailsSection(),
                SizedBox(height: 14),
                _buildDocumentsSection(),
                SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCountryDropdown() {
    return Obx(() {
      if (controller.isLoadingCountries.value) {
        return _buildLoadingDropdown('Loading countries...');
      }
      return SearchableDropdown<CountryModel>(
        label: 'Country *',
        items: controller.countries,
        displayItem: (country) => country.name.toString(),
        selectedItem: controller.selectedCountry.value,
        onChanged: (CountryModel? value) =>
            controller.selectedCountry.value = value,
        validator: (value) => value == null ? 'Required field' : null,
      );
    });
  }

  Widget _buildStateDropdown() {
    return Obx(() {
      if (controller.selectedCountry.value == null) {
        return _buildDisabledDropdown('Select country first');
      }
      if (controller.isLoadingStates.value) {
        return _buildLoadingDropdown('Loading states...');
      }
      return SearchableDropdown<StateModel>(
        label: 'State *',
        items: controller.states,
        displayItem: (state) => state.name.toString(),
        selectedItem: controller.selectedState.value,
        onChanged: (StateModel? value) =>
            controller.selectedState.value = value,
        validator: (value) => value == null ? 'Required field' : null,
      );
    });
  }

  // Update similarly for _buildCityDropdown, _buildTalukDropdown, _buildVillageDropdown
  Widget _buildCityDropdown() {
    return Obx(() {
      if (controller.selectedState.value == null) {
        return _buildDisabledDropdown('Select state first');
      }
      if (controller.isLoadingCities.value) {
        return _buildLoadingDropdown('Loading cities...');
      }
      return SearchableDropdown<CityModel>(
        label: 'City *',
        items: controller.cities,
        displayItem: (city) => city.name.toString(),
        selectedItem: controller.selectedCity.value,
        onChanged: (CityModel? value) => controller.selectedCity.value = value,
        validator: (value) => value == null ? 'Required field' : null,
      );
    });
  }

  Widget _buildTalukDropdown() {
    return Obx(() {
      if (controller.selectedCity.value == null) {
        return _buildDisabledDropdown('Select city first');
      }
      if (controller.isLoadingTaluks.value) {
        return _buildLoadingDropdown('Loading taluks...');
      }
      return SearchableDropdown<TalukModel>(
        label: 'Taluk *',
        items: controller.taluks,
        displayItem: (taluk) => taluk.name.toString(),
        selectedItem: controller.selectedTaluk.value,
        onChanged: (TalukModel? value) =>
            controller.selectedTaluk.value = value,
        validator: (value) => value == null ? 'Required field' : null,
      );
    });
  }

  Widget _buildVillageDropdown() {
    return Obx(() {
      if (controller.selectedTaluk.value == null) {
        return _buildDisabledDropdown('Select taluk first');
      }
      if (controller.isLoadingVillages.value) {
        return _buildLoadingDropdown('Loading villages...');
      }
      return SearchableDropdown<VillageModel>(
        label: 'Village *',
        items: controller.villages,
        displayItem: (village) => village.name.toString(),
        selectedItem: controller.selectedVillage.value,
        onChanged: (VillageModel? value) =>
            controller.selectedVillage.value = value,
        validator: (value) => value == null ? 'Required field' : null,
      );
    });
  }

  Widget _buildLoadingDropdown(String text) {
    return Container(
      decoration: AppStyle.decoration.copyWith(
        color: const Color.fromARGB(137, 221, 234, 234),
        boxShadow: const [],
      ),
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: text,
          border: InputBorder.none,
          isDense: true,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledDropdown(String text) {
    return Container(
      decoration: AppStyle.decoration.copyWith(
        color: const Color.fromARGB(137, 221, 234, 234),
        boxShadow: const [],
      ),
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: text,
          border: InputBorder.none,
          isDense: true,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.keyboard_arrow_down_outlined,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Survey Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: controller.addSurveyItem,
              tooltip: 'Add Survey Detail',
            ),
          ],
        ),
        Obx(() {
          if (controller.surveyItems.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No survey details added',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.surveyItems.length,
            itemBuilder: (context, index) {
              return SurveyItemWidget(
                index: index,
                item: controller.surveyItems[index],
                areaUnits: controller.landUnits,
                onRemove: () => controller.removeSurveyItem(index),
                onChanged: (item) => controller.surveyItems[index] = item,
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Land Documents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: controller.addDocumentItem,
                tooltip: 'Add Document',
              ),
            ],
          ),
          Obx(() {
            if (controller.documentItems.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No documents added',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.documentItems.length,
              itemBuilder: (context, index) {
                return DocumentItemWidget(
                  index: index,
                  item: controller.documentItems[index],
                  documentTypes: controller.documentTypes,
                  onRemove: () => controller.removeDocumentItem(index),
                  onChanged: (item) => controller.documentItems[index] = item,
                  onPickDocument: () => controller.pickDocument(index),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed: controller.isSubmitting.value ? null : controller.submitForm,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: controller.isSubmitting.value
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text('Save Land Details'),
      );
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: AppStyle.decoration.copyWith(
        color: const Color.fromARGB(137, 221, 234, 234),
        boxShadow: const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: 55,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          isDense: true,
          suffixIcon: readOnly ? Icon(Icons.location_on) : null,
        ),
        validator: validator,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }
}
