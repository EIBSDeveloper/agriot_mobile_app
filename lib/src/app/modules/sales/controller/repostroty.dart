import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../../../controller/app_controller.dart';
import '../../../utils/http/http_service.dart';
import '../../task/model/model.dart';
import '../model/model.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:isolate';

// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:path/path.dart';
class SalesRepository {
  final HttpService _httpService = Get.find();

  final AppDataController _appDataController = Get.find();
  // Add this class for multipart file handling

  Future<SalesListResponse> getSalesList({
    required int cropId,
    required String type,
  }) async {
    final farmerId = _appDataController.userId;
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
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.get(
        '/land-and-crop-details/$farmerId',
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

  static SalesListResponse _parseSalesList(String response) {
    return SalesListResponse.fromJson(jsonDecode(response));
  }

  Future<SalesDetailResponse> getSalesDetails({required int salesId}) async {
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.post('/get_sales_details/$farmerId', {
        'sales_id': salesId,
      });
      return compute(_parseSalesDetails, jsonEncode(jsonDecode(response.body)));
    } catch (e) {
      rethrow;
    }
  }

  static SalesDetailResponse _parseSalesDetails(String response) {
    return SalesDetailResponse.fromJson(jsonDecode(response));
  }

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

  Future<String> addSales({required SalesAddRequest request}) async {
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.post(
        '/add_sales_with_deductions/$farmerId',
        request.toJson(),
      );
      return jsonDecode(response.body)['id'].toString();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> updateSales({
    required int salesId,
    required SalesEditRequest request,
  }) async {
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.post(
        '/update_sales_with_deductions/$farmerId/$salesId',
        request.toJson(),
      );
      return jsonDecode(response.body)['id'].toString();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteSales({required int salesId}) async {
    final farmerId = _appDataController.userId;
    try {
      await _httpService.post('/deactivate_my_sale/$farmerId', {'id': salesId});
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadFile(File file, String fileType) async {
    try {
      final bytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'document',
        bytes,
        filename: basename(file.path),
      );

      final response = await _httpService.post(
        '/upload_document/',
        MultipartBody(fields: {'file_type': fileType}, files: [multipartFile]),
      );

      return jsonDecode(response.body)['file_url'];
    } catch (e) {
      rethrow;
    }
  }
}
