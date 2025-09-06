// ignore_for_file: constant_pattern_never_matches_value_type

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../controller/app_controller.dart';
import '../../../utils/http/http_service.dart';

// Base Models
class Farmer {
  final int id;
  final String name;

  Farmer({required this.id, required this.name});

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class InventoryItem {
  final int id;
  final String name;

  InventoryItem({required this.id, required this.name});

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class InventoryType {
  final int id;
  final String name;

  InventoryType({required this.id, required this.name});

  factory InventoryType.fromJson(Map<String, dynamic> json) => InventoryType(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class InventoryCategory {
  final int id;
  final String name;

  InventoryCategory({required this.id, required this.name});

  factory InventoryCategory.fromJson(Map<String, dynamic> json) => InventoryCategory(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class Vendor {
  final int id;
  final String name;

  Vendor({required this.id, required this.name});

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class QuantityUnit {
  final int id;
  final String name;

  QuantityUnit({required this.id, required this.name});

  factory QuantityUnit.fromJson(Map<String, dynamic> json) => QuantityUnit(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class Document {
  final int id;
  final String documentName;
  final String fileType;

  Document({
    required this.id,
    required this.documentName,
    required this.fileType,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
      id: json['id'] ?? 0,
      documentName: json['document_name'] ?? '',
      fileType: json['file_type'] is String
          ? json['file_type']
          : (json['file_type']?['name'] ?? 'Document'),
    );
}

// Inventory Type Models
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
  final List<Document> documents;

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

  factory FuelInventoryModel.fromJson(Map<String, dynamic> json) => FuelInventoryModel(
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
          .map((doc) => Document.fromJson(doc))
          .toList(),
    );
}

class MachineryInventoryModel {
  final int machineryId;
  final Vendor vendor;
  final InventoryItem inventoryItem;
  final InventoryType inventoryType;
  final InventoryCategory inventoryCategory;
  final int machineryType;
  final double fuelCapacity;
  final double purchaseAmount;
  final String warrantyStartDate;
  final String warrantyEndDate;
  final String description;
  final int status;
  final String availableQuantity;
  final List<Document> documents;

  MachineryInventoryModel({
    required this.machineryId,
    required this.vendor,
    required this.inventoryItem,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.machineryType,
    required this.fuelCapacity,
    required this.purchaseAmount,
    required this.warrantyStartDate,
    required this.warrantyEndDate,
    required this.description,
    required this.status,
    required this.availableQuantity,
    required this.documents,
  });

  factory MachineryInventoryModel.fromJson(Map<String, dynamic> json) => MachineryInventoryModel(
      machineryId: json['machinery_id'] ?? 0,
      vendor: Vendor.fromJson(json['vendor'] ?? {}),
      inventoryItem: InventoryItem.fromJson(json['inventory_item'] ?? {}),
      inventoryType: InventoryType.fromJson(json['inventory_type'] ?? {}),
      inventoryCategory: InventoryCategory.fromJson(
        json['inventory_category'] ?? {},
      ),
      machineryType: json['machinery_type'] ?? 0,
      fuelCapacity: (json['fuel_capacity'] ?? 0.0).toDouble(),
      purchaseAmount: (json['purchase_amount'] ?? 0.0).toDouble(),
      warrantyStartDate: json['warranty_start_date'] ?? '',
      warrantyEndDate: json['warranty_end_date'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      availableQuantity: json['available_quantity']?.toString() ?? '0',
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => Document.fromJson(doc))
          .toList(),
    );
}

class PesticidesInventoryModel {
  final int pesticidesId;
  final Vendor vendor;
  final InventoryItem inventoryItem;
  final InventoryType inventoryType;
  final InventoryCategory inventoryCategory;
  final double quantity;
  final QuantityUnit quantityUnit;
  final double purchaseAmount;
  final String description;
  final int status;
  final double availableQuantity;
  final List<Document> documents;

  PesticidesInventoryModel({
    required this.pesticidesId,
    required this.vendor,
    required this.inventoryItem,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.quantity,
    required this.quantityUnit,
    required this.purchaseAmount,
    required this.description,
    required this.status,
    required this.availableQuantity,
    required this.documents,
  });

  factory PesticidesInventoryModel.fromJson(Map<String, dynamic> json) => PesticidesInventoryModel(
      pesticidesId: json['pesticides_id'] ?? 0,
      vendor: Vendor.fromJson(json['vendor'] ?? {}),
      inventoryItem: InventoryItem.fromJson(json['inventory_item'] ?? {}),
      inventoryType: InventoryType.fromJson(json['inventory_type'] ?? {}),
      inventoryCategory: InventoryCategory.fromJson(
        json['inventory_category'] ?? {},
      ),
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      quantityUnit: QuantityUnit.fromJson(json['quantity_unit'] ?? {}),
      purchaseAmount: (json['purchase_amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      availableQuantity: (json['available_quantity'] ?? 0.0).toDouble(),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => Document.fromJson(doc))
          .toList(),
    );
}

class SeedsInventoryModel {
  final int seedsId;
  final Vendor vendor;
  final InventoryItem inventoryItem;
  final InventoryType inventoryType;
  final InventoryCategory inventoryCategory;
  final String quantity;
  final QuantityUnit quantityUnit;
  final String purchaseAmount;
  final String description;
  final int status;
  final String availableQuantity;
  final List<Document> documents;

  SeedsInventoryModel({
    required this.seedsId,
    required this.vendor,
    required this.inventoryItem,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.quantity,
    required this.quantityUnit,
    required this.purchaseAmount,
    required this.description,
    required this.status,
    required this.availableQuantity,
    required this.documents,
  });

  factory SeedsInventoryModel.fromJson(Map<String, dynamic> json) => SeedsInventoryModel(
      seedsId: json['seeds_id'] ?? 0,
      vendor: Vendor.fromJson(json['vendor'] ?? {}),
      inventoryItem: InventoryItem.fromJson(json['inventory_item'] ?? {}),
      inventoryType: InventoryType.fromJson(json['inventory_type'] ?? {}),
      inventoryCategory: InventoryCategory.fromJson(
        json['inventory_category'] ?? {},
      ),
      quantity: json['quantity']?.toString() ?? '0',
      quantityUnit: QuantityUnit.fromJson(json['quantity_unit'] ?? {}),
      purchaseAmount: json['purchase_amount']?.toString() ?? '0',
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      availableQuantity: json['available_quantity']?.toString() ?? '0',
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => Document.fromJson(doc))
          .toList(),
    );
}

class VehicleInventoryModel {
  final int vehicleId;
  final String registerNumber;
  final String ownerName;
  final double runningKilometer;
  final double purchaseAmount;
  final bool insurance;
  final String description;
  final int status;
  final Vendor vendor;
  final InventoryItem inventoryItem;
  final InventoryType inventoryType;
  final InventoryCategory inventoryCategory;
  final List<Document> documents;

  VehicleInventoryModel({
    required this.vehicleId,
    required this.registerNumber,
    required this.ownerName,
    required this.runningKilometer,
    required this.purchaseAmount,
    required this.insurance,
    required this.description,
    required this.status,
    required this.vendor,
    required this.inventoryItem,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.documents,
  });

  factory VehicleInventoryModel.fromJson(Map<String, dynamic> json) => VehicleInventoryModel(
      vehicleId: json['vehicle_id'] ?? 0,
      registerNumber: json['register_number'] ?? '',
      ownerName: json['owner_name'] ?? '',
      runningKilometer: (json['running_kilometer'] ?? 0.0).toDouble(),
      purchaseAmount: (json['purchase_amount'] ?? 0.0).toDouble(),
      insurance: json['insurance'] ?? false,
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      vendor: Vendor.fromJson(json['vendor'] ?? {}),
      inventoryItem: InventoryItem.fromJson(json['inventory_item'] ?? {}),
      inventoryType: InventoryType.fromJson(json['inventory_type'] ?? {}),
      inventoryCategory: InventoryCategory.fromJson(
        json['inventory_category'] ?? {},
      ),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => Document.fromJson(doc))
          .toList(),
    );
}

class FertilizersInventoryModel {
  final int fertilizerId;
  final Vendor vendor;
  final InventoryItem inventoryItem;
  final InventoryType inventoryType;
  final InventoryCategory inventoryCategory;
  final double quantity;
  final QuantityUnit quantityUnit;
  final double purchaseAmount;
  final String description;
  final int status;
  final double availableQuantity;
  final List<Document> documents;

  FertilizersInventoryModel({
    required this.fertilizerId,
    required this.vendor,
    required this.inventoryItem,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.quantity,
    required this.quantityUnit,
    required this.purchaseAmount,
    required this.description,
    required this.status,
    required this.availableQuantity,
    required this.documents,
  });

  factory FertilizersInventoryModel.fromJson(Map<String, dynamic> json) => FertilizersInventoryModel(
      fertilizerId: json['fertilizer_id'] ?? 0,
      vendor: Vendor.fromJson(json['vendor'] ?? {}),
      inventoryItem: InventoryItem.fromJson(json['inventory_item'] ?? {}),
      inventoryType: InventoryType.fromJson(json['inventory_type'] ?? {}),
      inventoryCategory: InventoryCategory.fromJson(
        json['inventory_category'] ?? {},
      ),
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      quantityUnit: QuantityUnit.fromJson(json['quantity_unit'] ?? {}),
      purchaseAmount: (json['purchase_amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      availableQuantity: (json['available_quantity'] ?? 0.0).toDouble(),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => Document.fromJson(doc))
          .toList(),
    );
}

class ToolsInventoryModel {
  final int toolsId;
  final Vendor vendor;
  final InventoryItem inventoryItem;
  final InventoryType inventoryType;
  final InventoryCategory inventoryCategory;
  final double quantity;
  final double purchaseAmount;
  final String description;
  final int status;
  final double availableQuantity;
  final List<Document> documents;

  ToolsInventoryModel({
    required this.toolsId,
    required this.vendor,
    required this.inventoryItem,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.quantity,
    required this.purchaseAmount,
    required this.description,
    required this.status,
    required this.availableQuantity,
    required this.documents,
  });

  factory ToolsInventoryModel.fromJson(Map<String, dynamic> json) => ToolsInventoryModel(
      toolsId: json['tools_id'] ?? 0,
      vendor: Vendor.fromJson(json['vendor'] ?? {}),
      inventoryItem: InventoryItem.fromJson(json['inventory_item'] ?? {}),
      inventoryType: InventoryType.fromJson(json['inventory_type'] ?? {}),
      inventoryCategory: InventoryCategory.fromJson(
        json['inventory_category'] ?? {},
      ),
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      purchaseAmount: (json['purchase_amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      availableQuantity: (json['available_quantity'] ?? 0.0).toDouble(),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => Document.fromJson(doc))
          .toList(),
    );
}

enum MyInventoryType {
  fuel,
  machinery,
  pesticides,
  seeds,
  vehicle,
  fertilizers,
  tools,
}

class InventoryDetailRepository {
  final HttpService httpService = Get.find<HttpService>();
  final AppDataController _appDataController = Get.find();

  Future<dynamic> getInventoryDetail(MyInventoryType type, int id) async {
    final farmerId = _appDataController.userId.value;

    try {
      late String endpoint;
      late Map<String, dynamic> requestBody;

      switch (type) {
        case MyInventoryType.fuel:
          endpoint = '/get_myfuel/$farmerId/';
          requestBody = {'my_fuel': id};
          break;
        case MyInventoryType.machinery:
          endpoint = '/get_my_machinery/$farmerId/';
          requestBody = {'my_machinery': id};
          break;
        case MyInventoryType.pesticides:
          endpoint = '/get_my_pesticides/$farmerId/';
          requestBody = {'my_pesticides': id};
          break;
        case MyInventoryType.seeds:
          endpoint = '/get_my_seeds/$farmerId/';
          requestBody = {'my_seeds': id};
          break;
        case MyInventoryType.vehicle:
          endpoint = '/get_myvehicle/$farmerId/';
          requestBody = {'my_vehicle': id};
          break;
        case MyInventoryType.fertilizers:
          endpoint = '/get_my_fertilizers/$farmerId/';
          requestBody = {'my_fertilizers': id};
          break;
        case MyInventoryType.tools:
          endpoint = '/get_my_tools/$farmerId/';
          requestBody = {'my_tools': id};
          break;
      }

      final response = await httpService.post(endpoint, requestBody);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        switch (type) {
          case MyInventoryType.fuel:
            return FuelInventoryModel.fromJson(responseData['fuel_data']);
          case MyInventoryType.machinery:
            return MachineryInventoryModel.fromJson(
              responseData['machinery_data'],
            );
          case MyInventoryType.pesticides:
            return PesticidesInventoryModel.fromJson(
              responseData['pesticides_data'],
            );
          case MyInventoryType.seeds:
            return SeedsInventoryModel.fromJson(responseData['seeds_data']);
          case MyInventoryType.vehicle:
            return VehicleInventoryModel.fromJson(responseData['vehicle_data']);
          case MyInventoryType.fertilizers:
            return FertilizersInventoryModel.fromJson(
              responseData['fertilizers_data'],
            );
          case MyInventoryType.tools:
            return ToolsInventoryModel.fromJson(responseData['tools_data']);
        }
      } else {
        throw Exception('Failed to load inventory details');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Future<bool> deleteInventory(InventoryLISTType type, int id) async {
  //   try {
  //     late String endpoint;

  //     switch (type) {
  //       case InventoryLISTType.fuel:
  //         endpoint = '/delete_myfuel/$id/';
  //         break;
  //       case InventoryLISTType.machinery:
  //         endpoint = '/delete_my_machinery/$id/';
  //         break;
  //       case InventoryLISTType.pesticides:
  //         endpoint = '/delete_my_pesticides/$id/';
  //         break;
  //       case InventoryLISTType.seeds:
  //         endpoint = '/delete_my_seeds/$id/';
  //         break;
  //       case InventoryLISTType.vehicle:
  //         endpoint = '/delete_myvehicle/$id/';
  //         break;
  //       case InventoryLISTType.fertilizers:
  //         endpoint = '/delete_my_fertilizers/$id/';
  //         break;
  //       case InventoryLISTType.tools:
  //         endpoint = '/delete_my_tools/$id/';
  //         break;
  //     }

  //     final response = await httpService.delete(endpoint);

  //     if (response.statusCode == 200 && json.decode(response.body)['status'] == true) {
  //       return true;
  //     } else {
  //       throw Exception('Failed to delete inventory');
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}

class InventoryDetailController extends GetxController {
  final InventoryDetailRepository repository = InventoryDetailRepository();

  final inventoryType = Rx<MyInventoryType>(MyInventoryType.fuel);
  final inventoryId = RxInt(0);
  final isLoading = true.obs;
  final inventoryData = Rx<dynamic>(null);
  final error = RxString('');

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    inventoryType.value = args['type'];
    inventoryId.value = args['id'];
    loadInventoryDetail();
  }

  Future<void> loadInventoryDetail() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await repository.getInventoryDetail(
        inventoryType.value,
        inventoryId.value,
      );
      inventoryData.value = result;
    } catch (e) {
      error.value = e.toString();
      Fluttertoast.showToast(
        msg: 'Failed to load inventory details',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteInventory() async {
    // try {
    //   final confirmed = await showDeleteConfirmation();
    //   if (!confirmed) return;

    //   final success = await repository.deleteInventory(
    //     inventoryType.value,
    //     inventoryId.value
    //   );
    //   if (success) {
    //     Fluttertoast.showToast(
    //       msg: 'Inventory deleted successfully',
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //     );
    //     Get.back(result: true);
    //   }
    // } catch (e) {
    //   Fluttertoast.showToast(
    //     msg: 'Failed to delete inventory',
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //   );
    // }
  }

  Future<bool> showDeleteConfirmation() async => await Get.dialog(
          AlertDialog(
            title: Text('confirm_delete'.tr),
            content: Text('delete_inventory_confirmation'.tr),
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

  void navigateToEditScreen() {
    if (inventoryData.value != null) {
      final editRoute = '/edit_${inventoryType.value.name}';
      Get.toNamed(
        editRoute,
        arguments: {'type': inventoryType.value, 'data': inventoryData.value},
      );
    }
  }

  void viewDocument(String documentUrl) {
    Get.toNamed('/document_viewer', arguments: documentUrl);
  }

  String getScreenTitle() {
    switch (inventoryType.value) {
      case MyInventoryType.fuel:
        return 'Fuel Inventory';
      case MyInventoryType.machinery:
        return 'Machinery Inventory';
      case MyInventoryType.pesticides:
        return 'Pesticides Inventory';
      case MyInventoryType.seeds:
        return 'Seeds Inventory';
      case MyInventoryType.vehicle:
        return 'Vehicle Inventory';
      case MyInventoryType.fertilizers:
        return 'Fertilizers Inventory';
      case MyInventoryType.tools:
        return 'Tools Inventory';
    }
  }
}

class InventoryView extends GetView<InventoryDetailController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('error_loading_data'.tr),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadInventoryDetail,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        if (controller.inventoryData.value == null) {
          return Center(child: Text('no_data_available'.tr));
        }

        return _buildInventoryContent();
      }),
    );

  Widget _buildInventoryContent() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _buildTypeSpecificContent(),
          const Divider(height: 32),
          _buildDocumentsSection(),
          const Divider(height: 32),
          _buildDescriptionSection(),
        ],
      ),
    );

  // Similar methods for other inventory types (seeds, vehicle, fertilizers, tools)

  Widget _buildDocumentsSection() {
    List<Document> documents = [];

    switch (controller.inventoryType.value) {
      case MyInventoryType.fuel:
        documents =
            (controller.inventoryData.value as FuelInventoryModel).documents;
        break;
      case MyInventoryType.machinery:
        documents = (controller.inventoryData.value as MachineryInventoryModel)
            .documents;
        break;
      case MyInventoryType.pesticides:
        documents = (controller.inventoryData.value as PesticidesInventoryModel)
            .documents;
        break;
      case MyInventoryType.seeds:
        documents =
            (controller.inventoryData.value as SeedsInventoryModel).documents;
        break;
      case MyInventoryType.vehicle:
        documents =
            (controller.inventoryData.value as VehicleInventoryModel).documents;
        break;
      case MyInventoryType.fertilizers:
        documents =
            (controller.inventoryData.value as FertilizersInventoryModel)
                .documents;
        break;
      case MyInventoryType.tools:
        documents =
            (controller.inventoryData.value as ToolsInventoryModel).documents;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('uploaded_documents'.tr, style: Get.textTheme.titleMedium),
        const SizedBox(height: 16),
        _buildDocumentsGrid(documents),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    String description = '';

    switch (controller.inventoryType.value) {
      case MyInventoryType.fuel:
        description =
            (controller.inventoryData.value as FuelInventoryModel).description;
        break;
      case MyInventoryType.machinery:
        description =
            (controller.inventoryData.value as MachineryInventoryModel)
                .description;
        break;
      case MyInventoryType.pesticides:
        description =
            (controller.inventoryData.value as PesticidesInventoryModel)
                .description;
        break;
      case MyInventoryType.seeds:
        description =
            (controller.inventoryData.value as SeedsInventoryModel).description;
        break;
      case MyInventoryType.vehicle:
        description = (controller.inventoryData.value as VehicleInventoryModel)
            .description;
        break;
      case MyInventoryType.fertilizers:
        description =
            (controller.inventoryData.value as FertilizersInventoryModel)
                .description;
        break;
      case MyInventoryType.tools:
        description =
            (controller.inventoryData.value as ToolsInventoryModel).description;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('description'.tr, style: Get.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(description, style: Get.textTheme.bodyLarge),
      ],
    );
  }



  Widget _buildDocumentsGrid(List<Document> documents) {
    if (documents.isEmpty) {
      return Text('no_documents_available'.tr);
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: documents.map((document) => GestureDetector(
          onTap: () => controller.viewDocument(document.documentName),
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
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    document.fileType,
                    style: Get.textTheme.labelSmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
    );
  }
}

class InventoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InventoryDetailRepository());
    Get.lazyPut(() => InventoryDetailController());
  }
}
