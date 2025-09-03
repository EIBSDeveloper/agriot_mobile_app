import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../controller/app_controller.dart';
import '../../../utils/http/http_service.dart';

class FuelInventoryModel {
  final int fuelId;
  final double quantity;
  final double purchaseAmount;
  final String description;
  final String date;
  final Farmer farmer;
  final InventoryItem inventoryItem;
  final InventoryType inventoryType;
  final InventoryCategory inventoryCategory;
  final Vendor vendor;
  final List<DocumentCategory> documents;

  FuelInventoryModel({
    required this.fuelId,
    required this.quantity,
    required this.purchaseAmount,
    required this.description,
    required this.date,
    required this.farmer,
    required this.inventoryItem,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.vendor,
    required this.documents,
  });

  factory FuelInventoryModel.fromJson(Map<String, dynamic> json) {
    return FuelInventoryModel(
      fuelId: json['fuel_id'] ?? 0,
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      purchaseAmount: (json['purchase_amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      farmer: Farmer.fromJson(json['farmer'] ?? {}),
      inventoryItem: InventoryItem.fromJson(json['inventory_item'] ?? {}),
      inventoryType: InventoryType.fromJson(json['inventory_type'] ?? {}),
      inventoryCategory: InventoryCategory.fromJson(
        json['inventory_category'] ?? {},
      ),
      vendor: Vendor.fromJson(json['vendor'] ?? {}),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => DocumentCategory.fromJson(doc))
          .toList(),
    );
  }
}

class Farmer {
  final int id;
  final String name;

  Farmer({required this.id, required this.name});

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class InventoryItem {
  final int id;
  final String name;

  InventoryItem({required this.id, required this.name});

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class InventoryType {
  final int id;
  final String name;

  InventoryType({required this.id, required this.name});

  factory InventoryType.fromJson(Map<String, dynamic> json) {
    return InventoryType(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class InventoryCategory {
  final int id;
  final String name;

  InventoryCategory({required this.id, required this.name});

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    return InventoryCategory(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class Vendor {
  final int id;
  final String name;

  Vendor({required this.id, required this.name});

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class DocumentCategory {
  final int categoryId;
  final List<Document> documents;

  DocumentCategory({required this.categoryId, required this.documents});

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    return DocumentCategory(
      categoryId: json['category_id'] ?? 0,
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => Document.fromJson(doc))
          .toList(),
    );
  }
}

class Document {
  final int id;
  final DocumentCategoryDetail documentCategory;
  final String uploadDocument;
  Document({
    required this.id,
    required this.documentCategory,
    required this.uploadDocument,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? 0,
      documentCategory: DocumentCategoryDetail.fromJson(
        json['document_category'] ?? {},
      ),
      uploadDocument: json['upload_document'] ?? '',
    );
  }
}

class DocumentCategoryDetail {
  final int id;
  final String name;

  DocumentCategoryDetail({required this.id, required this.name});

  factory DocumentCategoryDetail.fromJson(Map<String, dynamic> json) {
    return DocumentCategoryDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class FuelInventoryRepository {
  final HttpService httpService = Get.find<HttpService>();

  final AppDataController _appDataController = Get.find();
  Future<FuelInventoryModel> getFuelInventoryDetail(int fuelId) async {
    final farmerId = _appDataController.userId.value;
    try {
      final response = await httpService.post('/get_myfuel/$farmerId/', {
        'my_fuel': fuelId,
      });

      if (response.statusCode == 200) {
        return FuelInventoryModel.fromJson(
          json.decode(response.body)['fuel_data'],
        );
      } else {
        throw Exception('Failed to load fuel inventory details');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteFuelInventory(int fuelId) async {
    try {
      // Assuming there's a delete endpoint
      final response = await httpService.delete('/delete_myfuel/$fuelId/');

      if (response.statusCode == 200 &&
          json.decode(response.body)['status'] == true) {
        return true;
      } else {
        throw Exception('Failed to delete fuel inventory');
      }
    } catch (e) {
      rethrow;
    }
  }
}

class FuelInventoryController extends GetxController {
  final FuelInventoryRepository repository = FuelInventoryRepository();

  final RxInt fuelId = 0.obs;

  final isLoading = true.obs;
  final fuelInventory = Rx<FuelInventoryModel?>(null);
  final error = RxString('');

  @override
  void onInit() {
    super.onInit();
    fuelId.value = Get.arguments['id'];
    loadFuelInventoryDetail();
  }

  Future<void> loadFuelInventoryDetail() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await repository.getFuelInventoryDetail(fuelId.value);
      fuelInventory.value = result;
    } catch (e) {
      error.value = e.toString();
      Fluttertoast.showToast(
        msg: 'Failed to load fuel inventory details',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteInventory() async {
    try {
      final confirmed = await showDeleteConfirmation();
      if (!confirmed) return;

      final success = await repository.deleteFuelInventory(fuelId.value);
      if (success) {
        Fluttertoast.showToast(
          msg: 'Fuel inventory deleted successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        Get.back(result: true);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to delete fuel inventory',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<bool> showDeleteConfirmation() async {
    return await Get.dialog(
          AlertDialog(
            title: Text('confirm_delete'.tr),
            content: Text('delete_fuel_confirmation'.tr),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('cancel'.tr),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('delete'.tr),
              ),
            ],
          ),
        ) ??
        false;
  }

  void navigateToEditScreen() {
    if (fuelInventory.value != null) {
      Get.toNamed('/edit_fuel', arguments: fuelInventory.value);
    }
  }

  void viewDocument(String documentUrl) {
    Get.toNamed('/document_viewer', arguments: documentUrl);
  }
}

class FuelInventoryBinding extends Bindings {
  FuelInventoryBinding();

  @override
  void dependencies() {
    Get.lazyPut(() => FuelInventoryRepository());
    Get.lazyPut(() => FuelInventoryController());
  }
}

class FuelInventoryView extends GetView<FuelInventoryController> {
  const FuelInventoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('error_loading_data'.tr),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadFuelInventoryDetail,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        final fuel = controller.fuelInventory.value;
        if (fuel == null) {
          return Center(child: Text('no_data_available'.tr));
        }

        return _buildFuelDetailContent(fuel);
      }),
    );
  }

  Widget _buildFuelDetailContent(FuelInventoryModel fuel) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fuel.inventoryItem.name, style: Get.textTheme.headlineSmall),
            ],
          ),
          SizedBox(height: 24),

          // Basic Information
          _buildInfoRow('date'.tr, fuel.date),
          _buildInfoRow('inventory_type'.tr, fuel.inventoryType.name),
          _buildInfoRow('inventory_category'.tr, fuel.inventoryCategory.name),
          _buildInfoRow('vendor'.tr, fuel.vendor.name),
          _buildInfoRow('purchase_amount'.tr, '${fuel.purchaseAmount} ₹'),
          _buildInfoRow('quantity'.tr, '${fuel.quantity} L'),

          Divider(height: 32),

          // Uploaded Documents
          Text('uploaded_documents'.tr, style: Get.textTheme.titleMedium),
          SizedBox(height: 16),
          _buildDocumentsSection(fuel),

          Divider(height: 32),

          // Description
          Text('description'.tr, style: Get.textTheme.titleMedium),
          SizedBox(height: 8),
          Text(fuel.description, style: Get.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Get.textTheme.bodySmall),
          Text(value, style: Get.textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(FuelInventoryModel fuel) {
    final allDocuments = fuel.documents
        .expand((category) => category.documents)
        .toList();

    if (allDocuments.isEmpty) {
      return Text('no_documents_available'.tr);
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: allDocuments.map((document) {
        return GestureDetector(
          onTap: () => controller.viewDocument(document.uploadDocument),
          child: Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Get.theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Icon(
                    Icons.picture_as_pdf,
                    size: 48,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    document.documentCategory.name,
                    style: Get.textTheme.labelSmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
