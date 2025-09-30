import 'dart:convert';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

import '../../../controller/app_controller.dart';
import '../model/cunsumption_detail_model.dart';

class CunsumptionDetailsRepository {
  final HttpService httpService = Get.find<HttpService>();

  final AppDataController appDeta = Get.find();

  
  Future<CunsumptionDetailModel> getCunsumptionDetail(
    int cunsumptionId,
    int inventoryType,
  ) async {
    final farmerId = appDeta.farmerId.value;
    try {
    
      final response = await httpService.get("/inventory_cunsumption_details/$farmerId/$inventoryType/$cunsumptionId", );

      if (response.statusCode == 200) {
        return CunsumptionDetailModel.fromJson(
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
