import 'dart:async';
import 'dart:convert';
import 'package:argiot/src/app/modules/sales/model/dropdown_item.dart';
import 'package:argiot/src/app/modules/sales/model/sales_detail_response.dart';
import 'package:argiot/src/app/modules/sales/model/sales_list_response.dart';
import 'package:argiot/src/app/modules/task/model/crop_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../controller/app_controller.dart';
import '../../../service/http/http_service.dart';
class SalesRepository {
  final HttpService _httpService = Get.find();

  final AppDataController appDeta = Get.find();
  // Add this class for multipart file handling

  Future<SalesListResponse> getSalesList({
    required int cropId,
    required String type,
  }) async {
    final farmerId = appDeta.farmerId;
    try {
      final response = await _httpService.post(
        '/get_sales_by_crop/$farmerId/',
        {'crop_id': cropId, 'type': type},
      );
      return compute(_parseSalesList, jsonEncode(jsonDecode(response.body)));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CropModel>> getCropList() async {
    final farmerId = appDeta.farmerId;
        final isManager = appDeta.isManager.value;
    final managerId = appDeta.managerID.value;
   String manager = isManager?"?manager_id=$managerId":"";
    try {
      final response = await _httpService.get(
        '/land-and-crop-details/$farmerId$manager',
      );
      final lands = json.decode(response.body)['lands'] as List;

      // Flatten all crops from each land and remove duplicates by crop ID
      final allCrops = lands
          .expand((land) => land['crops'] as List)
          .map((crop) => CropModel.fromJson(crop))
          .toSet()
          .toList();

      return allCrops;
    } catch (e) {
      throw Exception('Failed to load crops: ${e.toString()}');
    }
  }

  static SalesListResponse _parseSalesList(String response) => SalesListResponse.fromJson(jsonDecode(response));

  Future<SalesDetailResponse> getSalesDetails({required int salesId}) async {
    final farmerId = appDeta.farmerId;
    try {
      final response = await _httpService.post('/get_sales_details/$farmerId', {
        'sales_id': salesId,
      });
      return compute(_parseSalesDetails, jsonEncode(jsonDecode(response.body)));
    } catch (e) {
      rethrow;
    }
  }

  static SalesDetailResponse _parseSalesDetails(String response) => SalesDetailResponse.fromJson(jsonDecode(response));

  Future<List<DropdownItem>> getReasons() async {
    try {
      final response = await _httpService.get('/reasons');
      return compute(
        _parseDropdownItems,
        jsonEncode(jsonDecode(response.body)),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DropdownItem>> getRupees() async {
    try {
      final response = await _httpService.get('/detections');
      return compute(
        _parseDropdownItems,
        jsonEncode(jsonDecode(response.body)['data']),
      );
    } catch (e) {
      rethrow;
    }
  }

  static List<DropdownItem> _parseDropdownItems(String response) {
    var jsonDecode2 = jsonDecode(response);
    var map = jsonDecode2
        .map<DropdownItem>((item) => DropdownItem.fromJson(item))
        .toList();
    return map;
  }

  Future<bool> deleteSales({required int salesId}) async {
    final farmerId = appDeta.farmerId;
    try {
      await _httpService.post('/deactivate_my_sale/$farmerId', {'id': salesId});
      return true;
    } catch (e) {
      rethrow;
    }
  }

  
}
