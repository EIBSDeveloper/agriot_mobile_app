import 'dart:convert';
import 'package:argiot/consumption_model.dart';
import 'package:argiot/src/app/controller/app_controller.dart';

import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:get/get.dart';

import 'model.dart';

class PurchasesAddRepository {
  final HttpService _httpService = Get.find<HttpService>();
  final AppDataController _appDataController = Get.find();
  Future<Map<String, dynamic>> addFuelEntry(FuelEntryModel fuelEntry) async {
    final farmerId = _appDataController.userId.value;
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

  Future<Map<String, dynamic>> addMachinery(Machinery machinery) async {
    final farmerId = _appDataController.userId.value;
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

  Future<List<InventoryTypeModel>> fetchInventoryTypes() async {
    final farmerId = _appDataController.userId.value;
    try {
      final response = await _httpService.get('/purchase_list/$farmerId/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        List<InventoryTypeModel> inventoryTypes = [];

        data.forEach((key, value) {
          if (key != 'language' && value is Map<String, dynamic>) {
            inventoryTypes.add(InventoryTypeModel.fromJson(key, value));
          }
        });

        return inventoryTypes;
      } else {
        return [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch inventory types');
      return [];
    }
  }

  Future<List<Customer>> getVendorList() async {
    try {
      final farmerId = _appDataController.userId;
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

  Future<List<InventoryCategoryModel>> fetchInventoryCategories(
    int inventoryTypeId,
  ) async {
    try {
      final response = await _httpService.get(
        '/get_inventory_category/$inventoryTypeId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => InventoryCategoryModel.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch inventory categories');
      return [];
    }
  }

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
      Get.snackbar('Error', 'Failed to fetch inventory items');
      return [];
    }
  }

  Future addVehicle(VehicleModel vehicle) async {
    final farmerId = _appDataController.userId.value;
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
    final farmerId = _appDataController.userId.value;
    try {
      var endpoint = '/add_fertilizer/$farmerId/';
      final response = await _httpService.post(endpoint, fertilizer.toJson());

      if (response.statusCode == 200) {
        return FertilizerResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add fertilizer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add fertilizer: $e');
    }
  }
}
