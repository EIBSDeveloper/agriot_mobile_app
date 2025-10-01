import 'dart:convert';

import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

class ManagerRepository {
  Future<Map<String, dynamic>> fetchPermissions() async {
    final HttpService _httpService = Get.find<HttpService>();

    // _httpService.get should return a Response
    final response = await _httpService.get('/permissions_list');

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load permissions');
    }
  }
}
