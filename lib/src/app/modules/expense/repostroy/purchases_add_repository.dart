import 'dart:convert';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/expense/model/customer.dart';
import 'package:argiot/src/app/modules/expense/model/fertilizer_model.dart';
import 'package:argiot/src/app/modules/expense/model/fertilizer_response.dart';
import 'package:argiot/src/app/modules/expense/model/fuel_entry_model.dart';
import 'package:argiot/src/app/modules/expense/model/inventory_item_model.dart';
import 'package:argiot/src/app/modules/expense/model/machinery.dart';
import 'package:argiot/src/app/modules/expense/model/vehicle_model.dart';

import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:get/get.dart';

import '../../inventory/model/inventory_item.dart';
import '../../sales/model/unit.dart';
import '../model/inventory_item_quantity.dart';

class PurchasesAddRepository {
  final HttpService _httpService = Get.find<HttpService>();
  final AppDataController appDeta = Get.find();
  Future<Map<String, dynamic>> addFuelEntry(FuelEntryModel fuelEntry) async {
    final farmerId = appDeta.farmerId.value;
    try {
      final response = await _httpService.post(
        '/add_fuel/$farmerId',
        fuelEntry.toJson(),
      );
      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Unit>> getUnitList() async {
    try {
      final response = await _httpService.get('/area_units');
      final lands = json.decode(response.body)["data"] as List;

      final allCrops = lands
          .map((crop) => Unit.fromJson(crop))
          .toSet()
          .toList();

      return allCrops;
    } catch (e) {
      throw Exception('Failed to load crops: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> addMachinery(Machinery machinery) async {
    final farmerId = appDeta.farmerId.value;
    try {
      final response = await _httpService.post(
        '/add_machinery/$farmerId',
        machinery.toJson(),
      );
      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<InventoryType>> getInventory() async {
    try {
      final farmerId = appDeta.farmerId;
      final response = await _httpService.get(
        '/inventory_types_quantity/$farmerId',
      );
      final response2 = jsonDecode(response.body) as List;
      return response2.map((data) => InventoryType.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Customer>> getVendorList() async {
    try {
      final farmerId = appDeta.farmerId;
      final response = await _httpService.get('/get_vendor/$farmerId');
      var decode = json.decode(response.body);
      var map = decode
          .map<Customer>((item) => Customer.fromJson(item))
          .toList();
      return map;
    } catch (e) {
      rethrow;
    }
  }

  // Future<List<InventoryCategoryModel>> fetchInventoryCategories(
  //   int inventoryTypeId,
  // ) async {
  //   try {
  //     final response = await _httpService.get(
  //       '/get_inventory_category/$inventoryTypeId',
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       return data
  //           .map((json) => InventoryCategoryModel.fromJson(json))
  //           .toList();
  //     } else {
  //       return [];
  //     }
  //   } catch (e) {
  //     showError('Failed to fetch inventory categories');
  //     return [];
  //   }
  // }

  Future<List<InventoryItemModel>> fetchInventoryItems(
    int inventoryCategoryId,
  ) async {
    try {
      final response = await _httpService.get(
        '/get_inventory_items/$inventoryCategoryId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => InventoryItemModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      showError('Failed to fetch inventory items');
      return [];
    }
  }

  Future<InventoryItemQuantity?> fetchInventoryItemsQuantity(
    int inventoryTypeId,
    int inventoryItemId,
  ) async {
    try {
      final farmerId = appDeta.farmerId;
      final response = await _httpService.get(
        '/inventory_item_quantity/$farmerId/$inventoryTypeId/$inventoryItemId',
      );

      // if (response.statusCode == 200) {

      return InventoryItemQuantity.fromJson(json.decode(response.body));
      // }
      //  else {
      //   return ;
      // }
    } catch (e) {
      // showError('Failed to fetch inventory items');
    }
    return null;
  }

  Future addVehicle(VehicleModel vehicle) async {
    final farmerId = appDeta.farmerId.value;
    try {
      final response = await _httpService.post(
        '/add_vehicle/$farmerId/',
        vehicle.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<FertilizerResponse> addFertilizer(FertilizerModel fertilizer) async {
    final farmerId = appDeta.farmerId.value;

    try {
      var endpoint = '/add_fertilizer/$farmerId/';

      if (fertilizer.inventoryType == 3) {
        endpoint = '/add_tools/$farmerId';
      } else if (fertilizer.inventoryType == 4) {
        endpoint = '/add_pesticides/$farmerId';
      } else if (fertilizer.inventoryType == 5) {
        endpoint = '/add_fertilizer/$farmerId';
      } else {
        endpoint = '/add_seeds/$farmerId';
      }
      final response = await _httpService.post(endpoint, fertilizer.toJson());

      if (response.statusCode == 201) {
        return FertilizerResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add fertilizer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add fertilizer: $e');
    }
  }
}
