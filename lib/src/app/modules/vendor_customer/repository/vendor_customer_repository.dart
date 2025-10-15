import 'dart:convert';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/vendor_customer/model/market.dart';
import 'package:argiot/src/app/modules/vendor_customer/model/vendor_customer_form_data.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

class VendorCustomerRepository {
  final HttpService _httpService = Get.find<HttpService>();
  final AppDataController appDeta = Get.find();
  Future<List> getVendorCustomerList(int type) async {
    final farmerId = appDeta.farmerId;
    try {
      String endpoint;
      if (appDeta.permission.value?.customer?.list == 0 && appDeta.permission.value?.customer?.view == 0) {
        type = 1;
      }
      switch (type) {
        case 0:
          endpoint = '/get_customer_list/$farmerId';
          break;
        default:
          endpoint = '/get_vendor/$farmerId';
          break;
      }

      final response = await _httpService.get(endpoint);

      List list = json.decode(response.body);
      return list;
    } catch (e) {
      List list = [];
      return list;
    }
  }

  Future<List<Market>> getMarkets() async {
    try {
      final response = await _httpService.get('/list_market_names');
      return List<Market>.from(
        json.decode(response.body).map((x) => Market.fromJson(x)),
      );
    } catch (e) {
      throw Exception('Failed to load markets: $e');
    }
  }

  Future<Map<String, dynamic>> daleteDetails(int id, String type) async {
    final userId = appDeta.farmerId;
    var endPoint = '';
    if (type == 'customer') {
      endPoint = '/deactivate_my_customer/$userId/';
    } else {
      endPoint = '/deactivate_my_vendor/$userId/';
    }
    final response = await _httpService.post(endPoint, {"${type}_id": id});
    return json.decode(response.body);
  }

  Future<int> addCustomer(VendorCustomerFormData formData) async {
    final farmerId = appDeta.farmerId;
    try {
      var json2 = formData.toJson();
      final response = await _httpService.post(
        '/add_customer_sales/$farmerId',
        json2,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        return json.decode(response.body)['id'] ?? 0;
      } else {
        throw Exception('Failed to add customer');
      }
    } catch (e) {
      throw Exception('Error adding customer: $e');
    }
  }

  Future<int> editCustomer(VendorCustomerFormData formData) async {
    final farmerId = appDeta.farmerId;
    try {
      var json2 = formData.toJson();
      final response = await _httpService.put(
        '/update_customer/$farmerId/',
        json2,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        return json.decode(response.body)['id'] ?? 0;
      } else {
        throw Exception('Failed to add customer');
      }
    } catch (e) {
      throw Exception('Error adding customer: $e');
    }
  }

  Future<int> addVendor(VendorCustomerFormData formData) async {
    final farmerId = appDeta.farmerId.value;
    try {
      var json2 = formData.toJson();
      json2['farmer'] = farmerId;
      final response = await _httpService.post('/add_vendor/$farmerId', json2);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body)['id'] ?? 0;
      } else {
        throw Exception('Failed to add vendor');
      }
    } catch (e) {
      throw Exception('Error adding vendor: $e');
    }
  }

  Future<int> editVendor(VendorCustomerFormData formData) async {
    final farmerId = appDeta.farmerId.value;
    try {
      var json2 = formData.toJson();
      json2['farmer'] = farmerId;
      final response = await _httpService.put(
        '/update_vendor/$farmerId/',
        json2,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body)['id'] ?? 0;
      } else {
        throw Exception('Failed to add vendor');
      }
    } catch (e) {
      throw Exception('Error adding vendor: $e');
    }
  }
}
