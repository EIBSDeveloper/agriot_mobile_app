import 'dart:convert';

import 'package:get/get.dart';

import '../../../controller/app_controller.dart';
import '../../../service/http/http_service.dart';
import '../../manager/model/dropdown_model.dart';
import '../../near_me/model/models.dart';
import '../model/dropdown_item.dart';
import '../model/land_model.dart';

class LandService extends GetxService {
  final HttpService _httpService = Get.find();

  final AppDataController appDeta = Get.put(AppDataController());
  Future<LandList> getLands() async {
    final userId = appDeta.farmerId;
    final isManager = appDeta.isManager.value;
    final managerId = appDeta.managerID.value;
    String manager = isManager ? "?manager_id=$managerId" : "";
    final response = await _httpService.get('/lands/$userId$manager');
    return LandList.fromJson(json.decode(response.body));
  }

  Future<List<AppDropdownItem>> getLandUnits() async {
    final response = await _httpService.get('/land_units');
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => AppDropdownItem.fromJson(item))
        .toList();
  }

  Future<LandDetail> fetchLandDetail(int landId) async {
    final farmerId = appDeta.farmerId;
    try {
      final response = await _httpService.get('/land_view/$farmerId/$landId');

      if (response.statusCode == 200) {
        var decode = json.decode(response.body);
        return LandDetail.fromJson(decode);
      } else {
        throw Exception('Failed to load land details');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DrapDown>> fetchAssignManager() async {
    final userId = appDeta.farmerId;
    final response = await _httpService.get("/manager_by_fermer/$userId");

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => DrapDown.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load permissions: ${response.statusCode}');
    }
  }

  Future<List<LandWithSurvey>> getLandsWithSurvey() async {
    final farmerId = appDeta.farmerId;
    try {
      final response = await _httpService.get(
        '/lands/with-survey-details/$farmerId',
      );
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => LandWithSurvey.fromJson(item)).toList();
    } catch (e) {
      throw Exception(
        'Failed to load lands with survey details: ${e.toString()}',
      );
    }
  }

  Future<List<AppDropdownItem>> getSoilTypes() async {
    final response = await _httpService.get('/soil_types');
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => AppDropdownItem.fromJson(item))
        .toList();
  }

  // Future<List<AppDropdownItem>> getAreaUnits() async {
  //   final response = await _httpService.get('/area_units');
  //   final jsonData = json.decode(response.body);
  //   return (jsonData['data'] as List)
  //       .map((item) => AppDropdownItem.fromJson(item))
  //       .toList();
  // }

  Future<List<AppDropdownItem>> getDocumentTypes(int docType) async {
    final response = await _httpService.get(
      '/document_categories?doctype=$docType',
    );
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => AppDropdownItem.fromJson(item))
        .toList();
  }

  Future<Map<String, dynamic>> addLand({
    required Map<dynamic, dynamic> request,
  }) async {
    // Convert all request values to strings
    final requestFields = request.map<String, dynamic>(
      (key, value) => MapEntry(key, value),
    );

    final response = await _httpService.post('/add_my_land/', requestFields);

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> editLand({
    required Map<dynamic, dynamic> request,
  }) async {
    final farmerId = appDeta.farmerId;
    // Convert all request values to strings
    final requestFields = request.map<String, dynamic>(
      (key, value) => MapEntry(key, value),
    );

    final response = await _httpService.put(
      '/edit_my_land/$farmerId',
      requestFields,
    );

    return json.decode(response.body);
  }
}
