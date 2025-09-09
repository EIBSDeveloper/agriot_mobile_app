import 'dart:convert';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/expense/model/fuel_inventory_model.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

class FuelInventoryRepository {
  final HttpService httpService = Get.find<HttpService>();

  final AppDataController _appDataController = Get.find();
  Future<PurchaseDetailModel> getFuelInventoryDetail(
    int fuelId,
    int inventoryType,
  ) async {
    final farmerId = _appDataController.userId.value;
    try {
      var endpoint = '/get_myfuel';
      var body = {'my_fuel': fuelId};
      if (inventoryType == 1) {
        endpoint = '/get_myvehicle';
        body = {'vehicle': fuelId};
      } else if (inventoryType == 2) {
        endpoint = '/get_my_machinery';
        body = {'get_my_machinery': fuelId};
      } else if (inventoryType == 3) {
        endpoint = '/get_my_tools/';
        body = {'my_tools': fuelId};
      } else if (inventoryType == 4) {
        endpoint = '/get_my_pesticides';
        body = {'my_pesticides': fuelId};
      } else if (inventoryType == 5) {
        endpoint = '/get_my_fertilizers';
        body = {'my_fertilizers': fuelId};
      } else if (inventoryType == 6) {
        endpoint = '/get_myfuel';
        body = {'my_fuel': fuelId};
      } else {
        endpoint = '/get_my_seeds';
        body = {'my_seeds': fuelId};
      }
      final response = await httpService.post("$endpoint/$farmerId/", body);

      if (response.statusCode == 200) {
        return PurchaseDetailModel.fromJson(
          json.decode(response.body)['fuel_data'],
        );
      } else {
        throw Exception('Failed to load fuel inventory details');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteFuelInventory(int fuelId) async {
    try {
      // Assuming there's a delete endpoint
      final response = await httpService.delete('/delete_myfuel/$fuelId/');

      if (response.statusCode == 200 &&
          json.decode(response.body)['status'] == true) {
        return true;
      } else {
        throw Exception('Failed to delete fuel inventory');
      }
    } catch (e) {
      rethrow;
    }
  }
}
