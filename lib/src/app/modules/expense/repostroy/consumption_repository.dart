import 'dart:convert';
import 'package:argiot/src/app/modules/expense/model/document_type_model.dart';
import 'package:argiot/src/app/modules/expense/model/inventory_item_model.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

import '../../../controller/app_controller.dart';
import '../../inventory/model/inventory_item.dart';

class ConsumptionRepository {
  final HttpService _httpService = Get.find<HttpService>();

  final AppDataController appDeta = Get.put(AppDataController());
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
