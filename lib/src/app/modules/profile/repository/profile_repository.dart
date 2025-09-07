import 'dart:async';
import 'dart:convert';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/profile/model/profile_model.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:get/get.dart';

class ProfileRepository {
  final HttpService _httpService = Get.find();
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final farmerId = Get.find<AppDataController>().userId.value;
    final response = await _httpService.put('/edit_farmer/$farmerId', data);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<ProfileModel> getProfile() async {
    final farmerId = Get.find<AppDataController>().userId.value;
    final response = await _httpService.get('/get_farmer/$farmerId');
    if (response.statusCode == 200) {
      return ProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
