import 'dart:convert';
import 'package:argiot/consumption_model.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:get/get.dart';

class ConsumptionRepository {
  final HttpService _httpService = Get.find<HttpService>();

  Future<List<InventoryTypeModel>> fetchInventoryTypes(String farmerId) async {
    final response = await _httpService.get('/purchase_list/$farmerId/');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final types = <InventoryTypeModel>[];

      data.forEach((key, value) {
        if (key != 'language' && value is Map<String, dynamic>) {
          types.add(InventoryTypeModel.fromJson(key, value));
        }
      });

      return types;
    } else {
      throw Exception('Failed to fetch inventory types');
    }
  }

  Future<List<InventoryCategoryModel>> fetchInventoryCategories(
    int typeId,
  ) async {
    final response = await _httpService.get('/get_inventory_category/$typeId');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => InventoryCategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch inventory categories');
    }
  }

  Future<List<InventoryItemModel>> fetchInventoryItems(int categoryId) async {
    final response = await _httpService.get('/get_inventory_items/$categoryId');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => InventoryItemModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch inventory items');
    }
  }

  Future<List<DocumentTypeModel>> fetchDocumentTypes() async {
    final response = await _httpService.get('/document_categories');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => DocumentTypeModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch document types');
    }
  }

  Future<bool> submitConsumption(Map<String, dynamic> consumptionData) async {
    final response = await _httpService.post(
      '/create_consumption/',
      consumptionData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to submit consumption');
    }
  }
}
