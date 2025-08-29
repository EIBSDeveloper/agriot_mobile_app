import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../controller/app_controller.dart';
import '../../../utils/http/http_service.dart';
import '../model/crop_model.dart' show CropSurveyDetail;
import '../model/dropdown_item.dart';

class CropService extends GetxService {
  final HttpService _httpService = Get.find();

  final AppDataController appDeta = Get.put(AppDataController());
  Future<List<DropdownItem>> getCropTypes() async {
    final response = await _httpService.get('/crop_types');
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => DropdownItem.fromJson(item))
        .toList();
  }

  Future<List> getSurveyDetails({required int landId}) async {
    final farmerId = appDeta.userId;
    try {
      final response = await _httpService.get(
        '/lands/with-survey-details/$farmerId/$landId',
      );
      final data = json.decode(response.body);
      final List<dynamic> surveyJson = data[0]?['survey_details'] ?? [];
      final List<LatLng?> landGeoMark = parseLatLngMapFromString(
        data?[0]?['geo_marks'] ?? [],
      );

      var list = [
        surveyJson.map((e) => CropSurveyDetail.fromJson(e)).toList(),
        landGeoMark,
      ];
      return list;
    } catch (e) {
      throw Exception('Failed to load survey details: ${e.toString()}');
    }
  }

  Future<List<DropdownItem>> getCrops(int cropTypeId) async {
    final response = await _httpService.post('/crops', {
      'croptype_id': cropTypeId,
    });
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => DropdownItem.fromJson(item))
        .toList();
  }

  Future<List<DropdownItem>> getHarvestFrequencies() async {
    final response = await _httpService.get('/harvesting_types');
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => DropdownItem.fromJson(item))
        .toList();
  }

  Future<http.Response> addCrop(Map<String, dynamic> request) async {
    final farmerId = appDeta.userId;
    final response = await _httpService.post('/add_crop/$farmerId/', request);
    return response;
  }

  Future<DropdownItem> addNewCropName(Map<String, dynamic> request) async {
    final response = await _httpService.post('/add_cropname', request);
    final jsonData = json.decode(response.body);
    return DropdownItem.fromJson(jsonData[0]);
  }

  /// 🔹 Correct crop details API
  Future<Map<String, dynamic>> getCropDetails(int landId, int cropId) async {
    final farmerId = appDeta.userId;
    try {
      final response = await _httpService.get(
        '/crop_view/$farmerId/$landId/$cropId',
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to load crop details: $e');
    }
  }

  /// 🔹 Correct crop edit API
  Future<http.Response> updateCropDetails(Map<String, dynamic> data) async {
    final farmerId = appDeta.userId.value;
    try {
      final response = await _httpService.put('/edit_crop/$farmerId', data);

      return response;
    } catch (e) {
      throw Exception('Failed to update crop details: $e');
    }
  }
}

List<List<double>> convertLatLngToWebMercator(List<List<double>> latLngList) {
  const R = 6378137.0; // Earth's radius in meters for Web Mercator

  return latLngList.map((coord) {
    double lat = coord[0];
    double lng = coord[1];

    double x = R * radians(lng);
    double y = R * log(tan(pi / 4 + radians(lat) / 2));

    return [x, y];
  }).toList();
}

double radians(double deg) => deg * pi / 180;
List<LatLng> parseLatLngListFromString(List<dynamic> data) {
  try {
    List<LatLng> latLngList = data.map((item) {
      if (item is List && item.length == 2) {
        return LatLng(item[0], item[1]);
      } else {
        throw FormatException("Invalid LatLng format");
      }
    }).toList();

    return latLngList;
  } catch (e) {
    print("Error parsing LatLng list: $e");
    return [];
  }
}

List<LatLng> parseLatLngMapFromString(List<dynamic> data) {
  try {
    List<LatLng> latLngList = data.map((item) {
      if (item is Map) {
        return LatLng(item['lat'], item['lng']);
      } else {
        throw FormatException("Invalid LatLng format");
      }
    }).toList();
    print("Error ");
    return latLngList;
  } catch (e) {
    print("Error parsing LatLng list: $e");
    return [];
  }
}

List<List<double>> convertLatLngListToList(List<LatLng> latLngList) {
  return latLngList
      .map((latLng) => [latLng.latitude, latLng.longitude])
      .toList();
}

List<Map<String, double>> convertLatLngListToMap(List<LatLng?> latLngList) {
  return latLngList
      .map((latLng) => {'lat': latLng!.latitude, 'lng': latLng.longitude})
      .toList();
}
