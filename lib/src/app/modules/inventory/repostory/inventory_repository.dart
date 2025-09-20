import 'dart:convert';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

import '../model/inventory_item.dart';

class InventoryRepository {
  final HttpService _httpService = Get.find<HttpService>();

  final AppDataController appDeta = Get.put(AppDataController());
  Future<List<InventoryType>> getInventory() async {
    try {
      final farmerId = appDeta.userId;
      final response = await _httpService.get('/inventory_types_quantity/$farmerId');
      final response2 = jsonDecode(response.body) as List;
return response2.map((data) => InventoryType.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
