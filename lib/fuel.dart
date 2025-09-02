import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'common.dart';
import 'src/app/controller/app_controller.dart';
import 'src/app/utils/http/http_service.dart';
import 'src/app/widgets/input_card_style.dart';
import 'src/routes/app_routes.dart';

class FuelPurchase {
  final int id;
  final String date;
  final Vendor vendor;
  final InventoryType inventoryType;
  final InventoryCategory inventoryCategory;
  final InventoryItem inventoryItem;
  final double quantity;
  final double purchaseAmount;
  final String? description;
  final List<Document>? documents;

  FuelPurchase({
    required this.id,
    required this.date,
    required this.vendor,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.inventoryItem,
    required this.quantity,
    required this.purchaseAmount,
    this.description,
    this.documents,
  });

  factory FuelPurchase.fromJson(Map<String, dynamic> json) {
    return FuelPurchase(
      id: json['id'],
      date: json['date_of_consumption'] ?? json['date'],
      vendor: Vendor.fromJson(
        json['vendor'] is int
            ? {'id': json['vendor'], 'name': ''}
            : json['vendor'],
      ),
      inventoryType: InventoryType.fromJson(
        json['inventory_type'] is int
            ? {'id': json['inventory_type'], 'name': ''}
            : json['inventory_type'],
      ),
      inventoryCategory: InventoryCategory.fromJson(
        json['inventory_category'] is int
            ? {'id': json['inventory_category'], 'name': ''}
            : json['inventory_category'],
      ),
      inventoryItem: InventoryItem.fromJson(
        json['inventory_items'] is int
            ? {'id': json['inventory_items'], 'name': ''}
            : json['inventory_items'],
      ),
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      purchaseAmount:
          double.tryParse(json['purchase_amount']?.toString() ?? '0') ?? 0,
      description: json['description'],
      documents: json['documents'] != null
          ? (json['documents'] as List)
                .map((docGroup) {
                  return (docGroup['documents'] as List)
                      .map((doc) => Document.fromJson(doc))
                      .toList();
                })
                .expand((docs) => docs)
                .toList()
          : null,
    );
  }
}

class FuelType {
  final int id;
  final String name;
  final double totalQuantity;

  FuelType({required this.id, required this.name, required this.totalQuantity});

  factory FuelType.fromJson(Map<String, dynamic> json) {
    return FuelType(
      id: json['id'],
      name: json['name'],
      totalQuantity:
          double.tryParse(json['total_quantity']?.toString() ?? '0') ?? 0,
    );
  }
}

// lib/modules/inventory/fuel/controllers/fuel_controller.dart

class FuelController extends GetxController {
  final FuelRepository _repository = Get.find();

  // Fuel Types List
  var fuelTypes = <FuelType>[].obs;
  var isLoadingFuelTypes = false.obs;
  var selectedFuelType = Rx<FuelType?>(null);

  // Fuel Purchases List
  var fuelPurchases = <FuelPurchase>[].obs;
  var isLoadingFuelPurchases = false.obs;
  var selectedFuelPurchase = Rx<FuelPurchase?>(null);

  // Form state
  var selectedDate = DateTime.now().obs;
  var selectedVendor = Rx<Vendor?>(null);
  var selectedInventoryItem = Rx<InventoryItem?>(null);
  var quantity = ''.obs;
  var purchaseAmount = ''.obs;
  var description = ''.obs;
  var selectedDocuments = <Map<String, dynamic>>[].obs;
  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFuelTypes();
  }

  Future<void> fetchFuelTypes() async {
    try {
      isLoadingFuelTypes(true);
      final response = await _repository.getFuelTypes();
      if (response != null) {
        fuelTypes.value = response;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load fuel types: $e');
    } finally {
      isLoadingFuelTypes(false);
    }
  }

  Future<Map<String, dynamic>?> pickDocument() async {
    return await _repository.pickDocument();
  }

  Future<void> fetchFuelPurchases(int inventoryItemId) async {
    try {
      isLoadingFuelPurchases(true);
      final response = await _repository.getFuelPurchases(inventoryItemId);
      if (response != null) {
        fuelPurchases.value = response;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load purchases: $e');
    } finally {
      isLoadingFuelPurchases(false);
    }
  }

  Future<void> fetchFuelPurchaseDetails(int fuelId) async {
    try {
      isLoadingFuelPurchases(true);
      final response = await _repository.getFuelPurchaseDetails(fuelId);
      if (response != null) {
        selectedFuelPurchase.value = response;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load purchase details: $e');
    } finally {
      isLoadingFuelPurchases(false);
    }
  }

  Future<bool> addFuelPurchase() async {
    try {
      isSubmitting(true);
      final result = await _repository.addFuelPurchase(
        date: selectedDate.value,
        vendorId: selectedVendor.value?.id ?? 0,
        inventoryItemId: selectedInventoryItem.value?.id ?? 0,
        quantity: double.tryParse(quantity.value) ?? 0,
        purchaseAmount: double.tryParse(purchaseAmount.value) ?? 0,
        description: description.value,
        documents: selectedDocuments,
      );
      if (result) {
        Fluttertoast.showToast(msg: 'Fuel purchase added successfully');
        clearForm();
        return true;
      }
      return false;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to add fuel purchase: $e');
      return false;
    } finally {
      isSubmitting(false);
    }
  }

  Future<bool> updateFuelPurchase(int fuelId) async {
    try {
      isSubmitting(true);
      final result = await _repository.updateFuelPurchase(
        fuelId: fuelId,
        date: selectedDate.value,
        vendorId: selectedVendor.value?.id ?? 0,
        inventoryItemId: selectedInventoryItem.value?.id ?? 0,
        quantity: double.tryParse(quantity.value) ?? 0,
        purchaseAmount: double.tryParse(purchaseAmount.value) ?? 0,
        description: description.value,
        documents: selectedDocuments,
      );
      if (result) {
        Fluttertoast.showToast(msg: 'Fuel purchase updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update fuel purchase: $e');
      return false;
    } finally {
      isSubmitting(false);
    }
  }

  Future<bool> deleteFuelPurchase(int fuelId) async {
    try {
      isSubmitting(true);
      final result = await _repository.deleteFuelPurchase(fuelId);
      if (result) {
        Fluttertoast.showToast(msg: 'Fuel purchase deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to delete fuel purchase: $e');
      return false;
    } finally {
      isSubmitting(false);
    }
  }

  void clearForm() {
    selectedDate.value = DateTime.now();
    selectedVendor.value = null;
    selectedInventoryItem.value = null;
    quantity.value = '';
    purchaseAmount.value = '';
    description.value = '';
    selectedDocuments.clear();
  }

  void setFormData(FuelPurchase purchase) {
    selectedDate.value = DateTime.parse(purchase.date);
    selectedVendor.value = purchase.vendor;
    selectedInventoryItem.value = purchase.inventoryItem;
    quantity.value = purchase.quantity.toString();
    purchaseAmount.value = purchase.purchaseAmount.toString();
    description.value = purchase.description ?? '';
    selectedDocuments.value =
        purchase.documents
            ?.map(
              (doc) => {
                'id': doc.id,
                'url': doc.url,
                'categoryName': doc.categoryName,
              },
            )
            .toList() ??
        [];
  }

  bool get isFormValid {
    return selectedVendor.value != null &&
        selectedInventoryItem.value != null &&
        quantity.value.isNotEmpty &&
        double.tryParse(quantity.value) != null &&
        purchaseAmount.value.isNotEmpty &&
        double.tryParse(purchaseAmount.value) != null;
  }
}

// lib/modules/inventory/fuel/repository/fuel_repository.dart

class FuelRepository {
  final HttpService _httpService = Get.find();

  final AppDataController appDeta = Get.put(AppDataController());
  Future<List<FuelType>?> getFuelTypes() async {
    try {
      final farmerId = appDeta.userId;
      final respons = await _httpService.get('/purchase_list/$farmerId/');
      final response = json.decode(respons.body);
      if (response != null && response['fuel'] != null) {
        return [
          FuelType(
            id: 6, // Assuming 6 is the ID for Fuel
            name: 'Fuel',
            totalQuantity: double.parse(
              response['fuel']['total_quantity'] ?? '0',
            ),
          ),
        ];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FuelPurchase>?> getFuelPurchases(int inventoryItemId) async {
    try {
      final farmerId = appDeta.userId;
      final respons = await _httpService.get(
        '/fuel_list_with_items/$farmerId?inventory_type=6&inventory_items=${inventoryItemId.toString()}',
      );
      final response = json.decode(respons.body);
      if (response != null && response['fuels'] != null) {
        return (response['fuels'] as List)
            .map((item) => FuelPurchase.fromJson(item))
            .toList();
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<FuelPurchase?> getFuelPurchaseDetails(int fuelId) async {
    try {
      final farmerId = appDeta.userId;
      final respons = await _httpService.post('/get_myfuel/$farmerId/', {
        'my_fuel': fuelId,
      });
      final response = json.decode(respons.body);
      if (response != null && response['fuel_data'] != null) {
        return FuelPurchase.fromJson(response['fuel_data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addFuelPurchase({
    required DateTime date,
    required int vendorId,
    required int inventoryItemId,
    required double quantity,
    required double purchaseAmount,
    String? description,
    List<Map<String, dynamic>>? documents,
  }) async {
    try {
      final farmerId = appDeta.userId;
      final body = {
        'date_of_consumption': _formatDate(date),
        'vendor': vendorId.toString(),
        'inventory_type': '6', // Fuel type ID
        'inventory_category': '6', // Fuel category ID
        'inventory_items': inventoryItemId.toString(),
        'quantity': quantity.toString(),
        'purchase_amount': purchaseAmount.toString(),
        if (description != null) 'description': description,
        if (documents != null && documents.isNotEmpty)
          'documents': _prepareDocuments(documents),
      };

      final respons = await _httpService.post('/add_fuel/$farmerId/', body);
      final response = json.decode(respons.body);
      return response != null && response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateFuelPurchase({
    required int fuelId,
    required DateTime date,
    required int vendorId,
    required int inventoryItemId,
    required double quantity,
    required double purchaseAmount,
    String? description,
    List<Map<String, dynamic>>? documents,
  }) async {
    try {
      final farmerId = appDeta.userId;
      final body = {
        'fuel_id': fuelId,
        'date_of_consumption': _formatDate(date),
        'vendor': vendorId,
        'inventory_type': 6, // Fuel type ID
        'inventory_category': 6, // Fuel category ID
        'inventory_items': inventoryItemId,
        'quantity': quantity,
        'purchase_amount': purchaseAmount,
        if (description != null) 'description': description,
        if (documents != null && documents.isNotEmpty)
          'documents': _prepareDocuments(documents),
      };

      final respons = await _httpService.put('/update_fuel/$farmerId/', body);
      final response = json.decode(respons.body);
      return response != null && response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteFuelPurchase(int fuelId) async {
    try {
      final farmerId = appDeta.userId;
      final respons = await _httpService.post('/deactivate_fuel/$farmerId/', {
        'my_fuel_id': fuelId,
      });
      final response = json.decode(respons.body);
      return response != null &&
          response['message'] == 'MyFuelDeletedsuccessfully';
    } catch (e) {
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> _prepareDocuments(
    List<Map<String, dynamic>> documents,
  ) {
    return documents.map((doc) {
      if (doc['file'] != null) {
        // New file upload
        return {
          'new_file_type': 'fuel',
          'documents': [base64Encode((doc['file'] as PlatformFile).bytes!)],
        };
      } else {
        // Existing document
        return {
          'id': doc['id'],
          'file_type': 1, // Default document type
        };
      }
    }).toList();
  }

  Future<Map<String, dynamic>?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        return {'file': file, 'name': file.name, 'size': file.size};
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}

// lib/modules/inventory/fuel/bindings/fuel_bindings.dart

class FuelBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CommonControllers());
    Get.lazyPut(() => FuelRepository());
    Get.lazyPut(() => FuelController());
  }
}

// lib/modules/inventory/routes.dart

// lib/modules/inventory/fuel/views/fuel_list_screen.dart

class FuelListScreen extends StatelessWidget {
  final FuelController controller = Get.find();

  FuelListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fuel'.tr), centerTitle: true),
      body: Obx(() {
        if (controller.isLoadingFuelTypes.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.fuelTypes.length,
          itemBuilder: (context, index) {
            final fuelType = controller.fuelTypes[index];
            return ListTile(
              title: Text(fuelType.name),
              subtitle: Text('${fuelType.totalQuantity} Ltr'),
              onTap: () {
                controller.selectedFuelType.value = fuelType;
                Get.toNamed(
                  Routes.fuelPurchaseList,
                  arguments: {'inventoryItemId': fuelType.id},
                );
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          if (controller.fuelTypes.isNotEmpty) {
            Get.toNamed(
              Routes.addFuelPurchase,
              arguments: {'inventoryItemId': controller.fuelTypes.first.id},
            );
          } else {
            Fluttertoast.showToast(msg: 'No fuel types available'.tr);
          }
        },
      ),
    );
  }
}

// lib/modules/inventory/fuel/views/fuel_purchase_list_screen.dart

class FuelPurchaseListScreen extends StatefulWidget {
  final int inventoryItemId;

  FuelPurchaseListScreen({super.key})
    : inventoryItemId = Get.arguments['inventoryItemId'];

  @override
  State<FuelPurchaseListScreen> createState() => _FuelPurchaseListScreenState();
}

class _FuelPurchaseListScreenState extends State<FuelPurchaseListScreen> {
  final FuelController controller = Get.find();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.fetchFuelPurchases(widget.inventoryItemId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.selectedFuelType.value?.name ?? 'Fuel Purchases'.tr,
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingFuelPurchases.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.fuelPurchases.length,
          itemBuilder: (context, index) {
            final purchase = controller.fuelPurchases[index];
            return ListTile(
              title: Text(purchase.vendor.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(purchase.date),
                  Text('${purchase.quantity} Litre'),
                ],
              ),
              trailing: Text('${purchase.purchaseAmount}'),
              onTap: () {
                controller.selectedFuelPurchase.value = purchase;
                Get.toNamed(Routes.fuelPurchaseDetails);
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Get.toNamed(
            Routes.addFuelPurchase,
            arguments: {'inventoryItemId': widget.inventoryItemId},
          );
        },
      ),
    );
  }
}

// lib/modules/inventory/fuel/views/add_edit_fuel_purchase_screen.dart

class AddEditFuelPurchaseScreen extends StatelessWidget {
  final FuelController controller = Get.find();
  final CommonControllers commonControllers = Get.find();
  final bool isEditing;

  AddEditFuelPurchaseScreen({required this.isEditing, super.key});

  @override
  Widget build(BuildContext context) {
    final int inventoryItemId = Get.arguments['inventoryItemId'];

    if (isEditing && controller.selectedFuelPurchase.value != null) {
      controller.setFormData(controller.selectedFuelPurchase.value!);
    } else {
      controller.clearForm();
      commonControllers.fetchVendors();
      commonControllers.fetchInventoryItems(inventoryItemId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Purchase'.tr : 'Add Purchase'.tr),
        actions: isEditing
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    final confirmed = await Get.dialog(
                      AlertDialog(
                        title: Text('Confirm Delete'.tr),
                        content: Text(
                          'Are you sure you want to delete this purchase?'.tr,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: Text('Cancel'.tr),
                          ),
                          TextButton(
                            onPressed: () => Get.back(result: true),
                            child: Text('Delete'.tr),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final success = await controller.deleteFuelPurchase(
                        controller.selectedFuelPurchase.value!.id,
                      );
                      if (success) {
                        Get.back();
                      }
                    }
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          child: Column(
            children: [
              // Date Picker
              InkWell(
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate.value,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (selected != null) {
                    controller.selectedDate.value = selected;
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date'.tr,
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat(
                          'yyyy-MM-dd',
                        ).format(controller.selectedDate.value),
                      ),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Fuel Category (read-only)
               InputCardStyle(
         
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Fuel Category'.tr,
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  initialValue: controller.selectedFuelType.value?.name ?? '',
                ),
              ),
              SizedBox(height: 16),

              // Vendor Dropdown
              Obx(() {
                return DropdownButtonFormField<Vendor>(
                  decoration: InputDecoration(
                    labelText: 'Vendor'.tr,
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Fluttertoast.showToast(
                          msg: 'Add vendor functionality to be implemented',
                        );
                      },
                    ),
                  ),
                  value: controller.selectedVendor.value,
                  items: commonControllers.vendors.map((vendor) {
                    return DropdownMenuItem<Vendor>(
                      value: vendor,
                      child: Text(vendor.name),
                    );
                  }).toList(),
                  onChanged: (Vendor? value) {
                    controller.selectedVendor.value = value;
                  },
                  validator: (value) =>
                      value == null ? 'Please select a vendor'.tr : null,
                );
              }),
              SizedBox(height: 16),

              // Inventory Item Dropdown
              Obx(() {
                return DropdownButtonFormField<InventoryItem>(
                  decoration: InputDecoration(
                    labelText: 'Fuel Type'.tr,
                    border: OutlineInputBorder(),
                  ),
                  value: controller.selectedInventoryItem.value,
                  items: commonControllers.inventoryItems.map((item) {
                    return DropdownMenuItem<InventoryItem>(
                      value: item,
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (InventoryItem? value) {
                    controller.selectedInventoryItem.value = value;
                  },
                  validator: (value) =>
                      value == null ? 'Please select a fuel type'.tr : null,
                );
              }),
              SizedBox(height: 16),

              // Purchase Amount
              InputCardStyle(
         
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Purchase Amount'.tr,
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  controller:
                      TextEditingController(
                          text: controller.purchaseAmount.value,
                        )
                        ..selection = TextSelection.collapsed(
                          offset: controller.purchaseAmount.value.length,
                        ),
                  onChanged: (value) => controller.purchaseAmount.value = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount'.tr;
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number'.tr;
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Quantity
               InputCardStyle(
         
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity (Litre)'.tr,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller:
                      TextEditingController(text: controller.quantity.value)
                        ..selection = TextSelection.collapsed(
                          offset: controller.quantity.value.length,
                        ),
                  onChanged: (value) => controller.quantity.value = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity'.tr;
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number'.tr;
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Documents
              ExpansionTile(
                title: Text('Documents'.tr),
                children: [
                  Obx(() {
                    return Column(
                      children: [
                        ...controller.selectedDocuments.map((doc) {
                          return ListTile(
                            title: Text(
                              doc['name'] ?? doc['categoryName'] ?? 'Document',
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                controller.selectedDocuments.remove(doc);
                              },
                            ),
                          );
                        }),
                        ElevatedButton(
                          onPressed: () async {
                            final doc = await controller.pickDocument();
                            if (doc != null) {
                              controller.selectedDocuments.add(doc);
                            }
                          },
                          child: Text('Add Document'.tr),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              SizedBox(height: 16),

              // Description
              InputCardStyle(
         
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description'.tr,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  controller:
                      TextEditingController(text: controller.description.value)
                        ..selection = TextSelection.collapsed(
                          offset: controller.description.value.length,
                        ),
                  onChanged: (value) => controller.description.value = value,
                ),
              ),
              SizedBox(height: 24),

              // Submit Button
              Obx(() {
                return ElevatedButton(
                  onPressed:
                      controller.isFormValid && !controller.isSubmitting.value
                      ? () async {
                          final success = isEditing
                              ? await controller.updateFuelPurchase(
                                  controller.selectedFuelPurchase.value!.id,
                                )
                              : await controller.addFuelPurchase();
                          if (success) {
                            Get.back();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: controller.isSubmitting.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? 'Update'.tr : 'Add'.tr),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/modules/inventory/fuel/views/fuel_purchase_details_screen.dart

class FuelPurchaseDetailsScreen extends StatelessWidget {
  final FuelController controller = Get.find();

  FuelPurchaseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final purchase = controller.selectedFuelPurchase.value;
    if (purchase == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('No purchase selected'.tr)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Details'.tr),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Get.toNamed(Routes.editFuelPurchase);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Date', purchase.date),
            _buildDetailItem('Fuel Type', purchase.inventoryType.name),
            _buildDetailItem('Fuel Category', purchase.inventoryCategory.name),
            _buildDetailItem('Vendor', purchase.vendor.name),
            _buildDetailItem('Purchase Amount', '${purchase.purchaseAmount}'),
            _buildDetailItem('Quantity', '${purchase.quantity} Litre'),
            if (purchase.description?.isNotEmpty ?? false)
              _buildDetailItem('Description', purchase.description!),

            // Documents
            if (purchase.documents?.isNotEmpty ?? false) ...[
              SizedBox(height: 16),
              Text('Documents'.tr, style: Get.textTheme.titleLarge),
              SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: purchase.documents?.length ?? 0,
                  itemBuilder: (context, index) {
                    final doc = purchase.documents![index];
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement document preview
                          Fluttertoast.showToast(
                            msg: 'Document preview to be implemented',
                          );
                        },
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.picture_as_pdf, size: 40),
                              Text(
                                doc.categoryName,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.tr, style: Get.textTheme.bodySmall),
          SizedBox(height: 4),
          Text(value, style: Get.textTheme.bodyLarge),
          Divider(),
        ],
      ),
    );
  }
}

// Add to your existing localization file or create a new one
