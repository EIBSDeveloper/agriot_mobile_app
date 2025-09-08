import 'dart:convert';
import 'package:argiot/src/app/modules/inventory/model/inventory_model.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

class InventoryRepository {
  final HttpService _httpService = Get.find<HttpService>();

  final AppDataController appDeta = Get.put(AppDataController());
  Future<InventoryModel> getInventory() async {
    try {
      final farmerId = appDeta.userId;
      final response = await _httpService.get('/purchase_list/$farmerId');
      var response2 = jsonDecode(response.body);
      return InventoryModel.fromJson(response2);
    } catch (e) {
      rethrow;
    }
  }
}
