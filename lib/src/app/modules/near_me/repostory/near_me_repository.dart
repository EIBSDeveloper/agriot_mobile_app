// repositories/near_me_repository.dart
import 'dart:convert';

import 'package:get/get.dart';

import '../../../controller/app_controller.dart';
import '../../../service/http/http_service.dart';
import '../model/models.dart';

class NearMeRepository {
  final HttpService _httpService = Get.find();
  final AppDataController appDeta = Get.find();

  Future<LandList> getLands() async {  
      final userId = appDeta.farmerId;
          final isManager = appDeta.isManager.value;
    final managerId = appDeta.managerID.value;
   String manager = isManager?"?manager_id=$managerId":"";
    final response = await _httpService.get('/lands/$userId$manager');
    return LandList.fromJson( json.decode(response.body));
  }

  Future<MarketResponse> getNearbyMarkets(int landId) async {
    final userId = appDeta.farmerId;
    final response = await _httpService.get(
      '/get_near_by_markets/$userId/$landId',
    );
    return MarketResponse.fromJson(json.decode(response.body));
  }

  Future<List<PlaceCategory>> getPlaceDetails(int landId) async {
    final userId = appDeta.farmerId;
    final response = await _httpService.get('/places_detail/$userId/$landId');
    List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => PlaceCategory.fromJson(json)).toList();
  }

  Future<List<ManPowerAgent>> getNearbyManPower(int landId) async {
    final userId = appDeta.farmerId;
    final response = await _httpService.get(
      '/get_near_by_users_workers/$userId/$landId',
    );
    List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => ManPowerAgent.fromJson(json)).toList();
  }

  Future<List<RentalItem>> getNearbyRentals(int landId) async {
    final userId = appDeta.farmerId;
    final response = await _httpService.get(
      '/get_near_by_rentals/$userId/$landId',
    );
    List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => RentalItem.fromJson(json)).toList();
  }
}
