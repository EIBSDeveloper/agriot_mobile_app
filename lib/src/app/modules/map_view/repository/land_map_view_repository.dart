import 'dart:convert';
import 'package:argiot/src/app/modules/map_view/model/crop_details.dart';
import 'package:argiot/src/app/modules/map_view/model/land_map_data.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/dashboad/model/weather_data.dart';
import 'package:argiot/src/app/modules/task/model/schedule_land.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

class LandMapViewRepository {
  final HttpService _httpService = Get.find<HttpService>();
  final AppDataController appDeta = Get.put(AppDataController());

  Future<List<ScheduleLand>> fetchLandsAndCrops() async {
    final farmerId = appDeta.farmerId;
    final isManager = appDeta.isManager.value;
    final managerId = appDeta.managerID.value;
    String manager = isManager ? "?manager_id=$managerId" : "";
    try {
      final response = await _httpService.get(
        '/land-and-crop-details/$farmerId$manager',
      );

      if (response.statusCode == 200) {
        final List<dynamic> landsJson = json.decode(response.body)['lands'];
        return landsJson.map((json) => ScheduleLand.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lands and crops');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<CropDetails> fetcCropDetails(int land, int crop) async {
    final farmerId = appDeta.farmerId;
    try {
      final response = await _httpService.get(
        '/crop_summary/$farmerId/$land/$crop',
      );

      if (response.statusCode == 200) {
        return CropDetails.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load lands and crops');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<WeatherData> getWeatherData(double lat, double lon) async {
    var weatherBaseUrllatlatlonlonappidweatherApiKey =
        '${appDeta.weatherBaseUrl}?lat=$lat&lon=$lon&appid=${appDeta.weatherApiKey}';
    final response = await _httpService.getRaw(
      weatherBaseUrllatlatlonlonappidweatherApiKey,
    );
    return WeatherData.fromJson(json.decode(response.body));
  }

  Future<LandMapData> fetchLandsAndCropMap(int landId) async {
    final farmerId = appDeta.farmerId;
        final isManager = appDeta.isManager.value;
    final managerId = appDeta.managerID.value;
   String manager = isManager?"?manager_id=$managerId":"";
    try {
      final response = await _httpService.get(
        '/lands/geo-marks/$farmerId/$landId$manager',
      );

      if (response.statusCode == 200) {
        var decode = json.decode(response.body)[0];
        var list = LandMapData.fromJson(decode);
        return list;
      } else {
        throw Exception('Failed to load lands and crops');
      }
    } catch (e) {
      rethrow;
    }
  }
}
