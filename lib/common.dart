// lib/modules/inventory/fuel/models/common_models.dart

import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'src/app/controller/app_controller.dart';
import 'src/app/utils/http/http_service.dart';

class InventoryType {
  final int id;
  final String name;
  final String? totalQuantity;

  InventoryType({required this.id, required this.name, this.totalQuantity});

  factory InventoryType.fromJson(Map<String, dynamic> json) {
    return InventoryType(
      id: json['id'],
      name: json['name'],
      totalQuantity: json['total_quantity'],
    );
  }
}

class InventoryCategory {
  final int id;
  final String name;
  final int inventoryTypeId;

  InventoryCategory({
    required this.id,
    required this.name,
    required this.inventoryTypeId,
  });

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    return InventoryCategory(
      id: json['id'],
      name: json['name'],
      inventoryTypeId: json['inventory_type_id'],
    );
  }
}

class InventoryItem {
  final int id;
  final String name;
  final String? code;
  final String? description;

  InventoryItem({
    required this.id,
    required this.name,
    this.code,
    this.description,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
    );
  }
}

class Vendor {
  final int id;
  final String name;
  final String businessName;
  final String mobileNo;

  Vendor({
    required this.id,
    required this.name,
    required this.businessName,
    required this.mobileNo,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      businessName: json['business_name'] ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
    );
  }
}

class DocumentType {
  final int id;
  final String name;
  final String description;

  DocumentType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class Document {
  final int id;
  final String url;
  final String categoryName;

  Document({required this.id, required this.url, required this.categoryName});

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      url: json['upload_document'] ?? '',
      categoryName: json['document_category']?['name'] ?? '',
    );
  }
}

// lib/modules/inventory/fuel/controllers/common_controllers.dart

class CommonControllers extends GetxController {
  final HttpService httpService = Get.find();

  final AppDataController appDeta = Get.put(AppDataController());
  // Inventory Type
  var inventoryTypes = <InventoryType>[].obs;
  var isLoadingInventoryTypes = false.obs;

  Future<void> fetchInventoryTypes( ) async {
        final farmerId = appDeta.userId;
    try {
      isLoadingInventoryTypes(true);
      final response = await httpService.get('/purchase_list/$farmerId/');
      var response2 = json.decode(response.body);
      if (response2 != null) {
        inventoryTypes.clear();
        response2.forEach((key, value) {
          inventoryTypes.add(
            InventoryType(
              id: _getInventoryTypeId(key),
              name: key,
              totalQuantity: value['total_quantity']?.toString(),
            ),
          );
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load inventory types: $e');
    } finally {
      isLoadingInventoryTypes(false);
    }
  }

  int _getInventoryTypeId(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'fuel':
        return 6;
      case 'vehicle':
        return 1;
      case 'machinery':
        return 2;
      case 'tools':
        return 3;
      case 'pesticides':
        return 4;
      case 'fertilizers':
        return 5;
      case 'seeds':
        return 7;
      default:
        return 0;
    }
  }

  // Inventory Categories
  var inventoryCategories = <InventoryCategory>[].obs;
  var isLoadingInventoryCategories = false.obs;

  Future<void> fetchInventoryCategories(int inventoryTypeId) async {
    try {
      isLoadingInventoryCategories(true);
      final response = await httpService.get(
        '/get_inventory_category/$inventoryTypeId/',
      );
      inventoryCategories.value = (response as List)
          .map((item) => InventoryCategory.fromJson(item))
          .toList();
        } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load categories: $e');
    } finally {
      isLoadingInventoryCategories(false);
    }
  }

  // Inventory Items
  var inventoryItems = <InventoryItem>[].obs;
  var isLoadingInventoryItems = false.obs;

  Future<void> fetchInventoryItems(int inventoryCategoryId) async {
    try {
      isLoadingInventoryItems(true);
      final response = await httpService.get(
        '/get_inventory_items/$inventoryCategoryId/',
      );
      inventoryItems.value = (response as List)
          .map((item) => InventoryItem.fromJson(item))
          .toList();
        } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load items: $e');
    } finally {
      isLoadingInventoryItems(false);
    }
  }

  // Vendors
  var vendors = <Vendor>[].obs;
  var isLoadingVendors = false.obs;

  Future<void> fetchVendors() async {   final farmerId = appDeta.userId;
    try {
      isLoadingVendors(true);
      final response = await httpService.get('/get_vendor/$farmerId/');
      vendors.value = (response as List)
          .map((item) => Vendor.fromJson(item))
          .toList();
        } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load vendors: $e');
    } finally {
      isLoadingVendors(false);
    }
  }

  // Document Types
  var documentTypes = <DocumentType>[].obs;
  var isLoadingDocumentTypes = false.obs;

  Future<void> fetchDocumentTypes() async {
    try {
      isLoadingDocumentTypes(true);
      final respons = await httpService.get('/document_categories');
      final response = json.decode(respons.body);
      if (response != null && response['data'] != null) {
        documentTypes.value = (response['data'] as List)
            .map((item) => DocumentType.fromJson(item))
            .toList();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load document types: $e');
    } finally {
      isLoadingDocumentTypes(false);
    }
  }
}
