import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../controller/app_controller.dart';
import '../../../utils/http/http_service.dart';
import '../../near_me/model/models.dart';
import '../model/document_model.dart';
import '../model/dropdown_item.dart';
import '../model/land_model.dart';

class LandService extends GetxService {
  final HttpService _httpService = Get.find();

  final AppDataController appDeta = Get.put(AppDataController());
  Future<LandList> getLands() async {
    final userId = appDeta.userId;
    final response = await _httpService.get('/lands/$userId');
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
    final farmerId = appDeta.userId;
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

  Future<List<LandWithSurvey>> getLandsWithSurvey() async {
    final farmerId = appDeta.userId;
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

  Future<List<AppDropdownItem>> getAreaUnits() async {
    final response = await _httpService.get('/area_units');
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => AppDropdownItem.fromJson(item))
        .toList();
  }
  // Future<Map<String, dynamic>> editLand({
  //   required int landId,
  //   required Map<String, dynamic> request,
  //   required List<DocumentItem> documents,
  // }) async {
  //   // Convert all request values to strings
  //   final requestFields = request.map<String, String>(
  //     (key, value) => MapEntry(key, value.toString()),
  //   );

  //   // Prepare multipart files (with null safety check)
  //   final multipartFiles = documents
  //       .where((doc) => doc.file != null)
  //       .map(
  //         (doc) => http.MultipartFile.fromBytes(
  //           'documents[]',
  //           doc.file!.bytes!,
  //           filename: doc.file!.name,
  //         ),
  //       )
  //       .toList();

  //   final response = await _httpService.put(
  //     '/edit_my_land/$landId/',
  //     MultipartBody(
  //       fields: requestFields, // Now properly typed as Map<String, String>
  //       files: multipartFiles,
  //     ),
  //   );

  //   return json.decode(response.body);
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
    required List<DocumentItem> documents,
  }) async {
    // Convert all request values to strings
    final requestFields = request.map<String, dynamic>(
      (key, value) => MapEntry(key, value),
    );

    // Prepare multipart files (with null safety check)
    final multipartFiles = documents
        .where((doc) => doc.file != null)
        .map(
          (doc) => http.MultipartFile.fromBytes(
            'documents[]',
            doc.file!.bytes!,
            filename: doc.file!.name,
          ),
        )
        .toList();

    final response = await _httpService.post('/add_my_land/', requestFields);

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> editLand({
    required Map<dynamic, dynamic> request,
    required List<DocumentItem> documents,
  }) async {
    final farmerId = appDeta.userId;
    // Convert all request values to strings
    final requestFields = request.map<String, dynamic>(
      (key, value) => MapEntry(key, value),
    );

    // Prepare multipart files (with null safety check)
    final multipartFiles = documents
        .where((doc) => doc.file != null)
        .map(
          (doc) => http.MultipartFile.fromBytes(
            'documents[]',
            doc.file!.bytes!,
            filename: doc.file!.name,
          ),
        )
        .toList();

    final response = await _httpService.put(
      '/edit_my_land/$farmerId',
      requestFields,
      // MultipartBody(
      //   fields: requestFields, // Now properly typed as Map<String, String>
      //   files: multipartFiles,
      // ),
    );

    return json.decode(response.body);
  }
}
