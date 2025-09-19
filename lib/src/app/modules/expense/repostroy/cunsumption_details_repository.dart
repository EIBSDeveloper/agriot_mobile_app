import 'dart:convert';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/expense/model/fuel_inventory_model.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

class CunsumptionDetailsRepository {
  final HttpService httpService = Get.find<HttpService>();

  final AppDataController _appDataController = Get.find();

  
  Future<PurchaseDetailModel> getCunsumptionDetail(
    int fuelId,
    int inventoryType,
  ) async {
    final farmerId = _appDataController.userId.value;
    try {
    
      final response = await httpService.get("/inventory_purchase_details/$farmerId/$inventoryType/$fuelId", );

      if (response.statusCode == 200) {
        return PurchaseDetailModel.fromJson(
          json.decode(response.body),
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
