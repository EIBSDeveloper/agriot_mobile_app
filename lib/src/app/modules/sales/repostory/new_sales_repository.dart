// models/sales_model.dart

import 'dart:convert';
import 'package:argiot/src/app/modules/sales/model/sales_add_request.dart';
import 'package:argiot/src/app/modules/sales/model/sales_update_request.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/expense/model/customer.dart';
import 'package:argiot/src/app/modules/sales/model/unit.dart';
import 'package:argiot/src/app/modules/sales/model/reason.dart';
import 'package:argiot/src/app/modules/sales/model/rupee.dart';
import 'package:argiot/src/app/modules/sales/model/sales_detail.dart';
import 'package:argiot/src/app/modules/sales/model/sales_list_response.dart';
import 'package:argiot/src/app/modules/task/model/crop_model.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:get/get.dart';

class NewSalesRepository {
  final HttpService _httpService = Get.find<HttpService>();

  final AppDataController _appDataController = Get.find();
  Future<SalesListResponse> getSalesByCrop(int cropId, String type) async {
    try {
      final farmerId = _appDataController.userId;
      final response = await _httpService.post(
        '/get_sales_by_crop/$farmerId/',
        {'crop_id': cropId, 'type': type},
      );
      return SalesListResponse.fromJson(json.decode(response.body));
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

  Future<SalesDetail> getSalesDetails(int salesId) async {
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.post(
        '/get_sales_details/$farmerId/',
        {'sales_id': salesId},
      );
      return SalesDetail.fromJson(json.decode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addSales(SalesAddRequest request) async {
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.post(
        '/add_sales_with_deductions/$farmerId',
        request.toJson(),
      );
      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateSales(
    int salesId,
    SalesUpdateRequest request,
  ) async {
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.post(
        '/update_sales_with_deductions/$farmerId/$salesId/',
        request.toJson(),
      );
      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteSales(int salesId) async {
    try {
      final farmerId = _appDataController.userId;
      final response = await _httpService.post(
        '/deactivate_my_sale/$farmerId/',
        {'id': salesId},
      );
      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Reason>> getReasons() async {
    try {
      final response = await _httpService.get('/reasons/');
      var decode = json.decode(response.body);
      var list = decode.map<Reason>((item) => Reason.fromJson(item)).toList();
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Rupee>> getRupees() async {
    try {
      final response = await _httpService.get('/rupees/');
      var decode = json.decode(response.body);
      var map = decode.map<Rupee>((item) => Rupee.fromJson(item)).toList();
      return map;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Customer>> getCustomerList() async {
    try {
      final farmerId = _appDataController.userId;
      final response = await _httpService.get('/get_customer_list/$farmerId');
      var decode = json.decode(response.body);
      var map = decode
          .map<Customer>((item) => Customer.fromJson(item))
          .toList();
      return map;
    } catch (e) {
      rethrow;
    }
  }
}
