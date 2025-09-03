import 'dart:convert';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:get/get.dart';

import 'model.dart';

class ConsumptionPurchaseRepository {
  final HttpService _httpService = Get.find();
  final AppDataController _appDataController = Get.find();
  Future<InventoryData> getInventoryData(
    String inventoryType,
    int itemId,
    int type,
  ) async {
    try {
      String endpoint;
      switch (inventoryType.toLowerCase()) {
        case 'fuel':
          endpoint = '/fuel_inventory_and_consumption';
          break;
        case 'pesticides':
          endpoint = '/pesticides-inventory-details';
          break;
        case 'seeds':
          endpoint = '/seeds-inventory-details';
          break;
        case 'fertilizers':
          endpoint = '/fertilizers-inventory-details';
          break;
        case 'tools':
          endpoint = '/tools-inventory-details';
          break;
        case 'vehicle':
          endpoint = '/vehicle-inventory-details';
          break;
        case 'machinery':
          endpoint = '/machinery-inventory-details';
          break;
        default:
          throw Exception('Unknown inventory type: $inventoryType');
      }

      // Get farmer ID from storage

      final farmerId = _appDataController.userId.value;
      final response = await _httpService.get(
        '$endpoint/$farmerId/$type/$itemId',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<ConsumptionRecord> consumptionRecords = [];
        List<PurchaseRecord> purchaseRecords = [];

        // Parse based on inventory type
        switch (inventoryType.toLowerCase()) {
          case 'fuel':
            consumptionRecords = (data['fuel_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['fuel_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          case 'pesticides':
            consumptionRecords = (data['pesticide_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['pesticide_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          case 'seeds':
            consumptionRecords = (data['seeds_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['seeds_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          case 'fertilizers':
            consumptionRecords = (data['fertilizers_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['fertilizers_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          case 'tools':
            consumptionRecords = (data['tools_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['tools_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          case 'vehicle':
            consumptionRecords = (data['vehicle_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['vehicle_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          case 'machinery':
            consumptionRecords = (data['machinery_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['machinery_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          default:
            throw Exception('Unknown inventory type: $inventoryType');
        }

        return InventoryData(
          consumptionRecords: consumptionRecords,
          purchaseRecords: purchaseRecords,
        );
      } else {
        throw Exception('Failed to load inventory data');
      }
    } catch (e) {
      rethrow;
    }
  }
}
