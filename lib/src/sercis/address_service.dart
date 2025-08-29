import 'dart:convert';
import 'package:argiot/src/app/modules/registration/model/address_model.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:get/get.dart';

class AddressService extends GetxService {
  final HttpService _httpService = Get.find();

  Future<List<CountryModel>> getCountries() async {
    final response = await _httpService.get('/countries');
    final List<dynamic> jsonData = json.decode(response.body)['countries'];
    return jsonData.map((item) => CountryModel.fromJson(item)).toList();
  }



  Future<List<StateModel>> getStates(int countryId) async {
    final response = await _httpService.post('/states', {
      'country_id': countryId,
    });
    final jsonData = json.decode(response.body);
    return (jsonData['states'] as List)
        .map((item) => StateModel.fromJson(item))
        .toList();
  }

  Future<List<CityModel>> getCities(int stateId) async {
    final response = await _httpService.post('/cities', {'state_id': stateId});
    final jsonData = json.decode(response.body);
    return (jsonData['cities'] as List)
        .map((item) => CityModel.fromJson(item))
        .toList();
  }

  Future<List<TalukModel>> getTaluks(int cityId) async {
    final response = await _httpService.post('/taluks', {'city_id': cityId});
    final List<dynamic> jsonData = json.decode(response.body)['taluks'];
    return jsonData.map((item) => TalukModel.fromJson(item)).toList();
  }

  Future<List<VillageModel>> getVillages(int talukId) async {
    final response = await _httpService.post('/villages', {
      'taluk_id': talukId,
    });
    final List<dynamic> jsonData = json.decode(response.body)['villages'];
    return jsonData.map((item) => VillageModel.fromJson(item)).toList();
  }
}
