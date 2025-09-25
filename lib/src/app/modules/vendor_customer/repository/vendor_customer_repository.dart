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
    final farmerId = appDeta.userId;
    try {
      String endpoint;
      switch (type) {
        case 0:
          endpoint = '/get_customer_list/$farmerId';
          break;
        case 1:
          endpoint = '/get_vendor/$farmerId';
          break;
        default:
          endpoint = '/both_customers_and_vendors/$farmerId';
      }

      final response = await _httpService.get(endpoint);

      List list = json.decode(response.body);
      return list;
    } catch (e) {
      // List list = [];
      // return list;
      throw Exception('Error fetching vendor/customer list: $e');
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
    final userId = appDeta.userId;
    var endPoint = '';
    if (type == 'customer') {
      endPoint = '/deactivate_my_customer/$userId/';
    } else if (type == 'vendor') {
      endPoint = '/deactivate_my_vendor/$userId/';
    } else {
      endPoint = '/deactivate_customer_and_vendor/$userId/$id';
      final response = await _httpService.delete(endPoint);
      return json.decode(response.body);
    }

    final response = await _httpService.post(endPoint, {"${type}_id": id});
    return json.decode(response.body);
  }

  Future<int> addCustomer(VendorCustomerFormData formData) async {
    final farmerId = appDeta.userId;
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
    final farmerId = appDeta.userId;
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
    final farmerId = appDeta.userId.value;
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

  Future<int>editVendor(VendorCustomerFormData formData) async {
    final farmerId = appDeta.userId.value;
    try {
      var json2 = formData.toJson();
      json2['farmer'] = farmerId;
      final response = await _httpService.put('/update_vendor/$farmerId/', json2);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body)['id'] ?? 0;
      } else {
        throw Exception('Failed to add vendor');
      }
    } catch (e) {
      throw Exception('Error adding vendor: $e');
    }
  }

  Future<int> addBoth(VendorCustomerFormData formData) async {
    final farmerId = appDeta.userId;
    try {
      var json2 = formData.toJson();
      json2["is_customer_is_vendor"] = "yes";

      final response = await _httpService.post(
        '/add_customer/$farmerId',
        json2,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var decode = json.decode(response.body);
        return decode['id'] ?? 0;
      } else {
        throw Exception('Failed to add customer/vendor');
      }
    } catch (e) {
      throw Exception('Error adding customer/vendor: $e');
    }
  }
  Future<int> editBoth(VendorCustomerFormData formData) async {
    final farmerId = appDeta.userId;
    try {
      var json2 = formData.toJson();
      json2["is_customer_is_vendor"] = "yes";

      final response = await _httpService.put(
        '/update_manage_customer/$farmerId/${formData.id}',
        json2,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var decode = json.decode(response.body);
        return decode['id'] ?? 0;
      } else {
        throw Exception('Failed to add customer/vendor');
      }
    } catch (e) {
      throw Exception('Error adding customer/vendor: $e');
    }
  }
}
