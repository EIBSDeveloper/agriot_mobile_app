import 'dart:convert';

import 'package:argiot/src/app/modules/registration/model/document_model.dart';
import 'package:argiot/src/app/modules/registration/model/dropdown_item.dart';
import 'package:argiot/src/app/modules/registration/model/land_model.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:get/get.dart';

class LandDetails {

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

  factory LandDetails.fromJson(Map<String, dynamic> json) => LandDetails(
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
}

class LandDocument {

  LandDocument({
    required this.id,
    required this.documentType,
    required this.documentUrl,
  });

  factory LandDocument.fromJson(Map<String, dynamic> json) => LandDocument(
      id: json['id'],
      documentType: json['document_type'],
      documentUrl: json['document_url'],
    );
  final int id;
  final String documentType;
  final String documentUrl;
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
