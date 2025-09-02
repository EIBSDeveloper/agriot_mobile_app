import 'dart:convert';

import 'package:argiot/src/app/modules/expense/fuel.dart/purchases_add_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../../../consumption_model.dart';
import '../../../controller/app_controller.dart';
import '../../../utils/http/http_service.dart';
import '../../../widgets/input_card_style.dart';

class InventoryCategory {
  final int id;
  final String name;
  final String type;

  InventoryCategory({required this.id, required this.name, required this.type});

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    return InventoryCategory(
      id: json['id'],
      name: json['name'],
      type: json['inventory_type']?['name'] ?? '',
    );
  }
}

class InventoryItem {
  final int id;
  final String name;

  InventoryItem({required this.id, required this.name});

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(id: json['id'], name: json['name']);
  }
}

class ConsumptionRecord {
  final int id;
  final double quantityUtilized;
  final DateTime dateOfConsumption;
  final String description;
  final String crop;
  final double availableQuantity;

  ConsumptionRecord({
    required this.id,
    required this.quantityUtilized,
    required this.dateOfConsumption,
    required this.description,
    required this.crop,
    required this.availableQuantity,
  });

  factory ConsumptionRecord.fromJson(Map<String, dynamic> json) {
    return ConsumptionRecord(
      id: json['id'],
      crop: json['crop_name'],
      quantityUtilized:
          double.tryParse(json['quantity_utilized']?.toString() ?? '0') ?? 0,
      dateOfConsumption: DateTime.parse(json['date_of_consumption']),
      description: json['description'] ?? '',
      availableQuantity:
          double.tryParse(json['available_quans']?.toString() ?? '0') ?? 0,
    );
  }
}

class PurchaseRecord {
  final int id;
  final String vendorName;
  final double quantity;
  final String quantityUnit;
  final double purchaseAmount;
  final DateTime date;
  final String description;

  PurchaseRecord({
    required this.id,
    required this.vendorName,
    required this.quantity,
    required this.quantityUnit,
    required this.purchaseAmount,
    required this.date,
    required this.description,
  });

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: json['id'],
      vendorName: json['vendor']?['name'] ?? 'Unknown',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      quantityUnit: json['quantity_unit'] ?? '',
      purchaseAmount:
          double.tryParse(json['purchase_amount']?.toString() ?? '0') ?? 0,
      date: DateTime.parse(json['created_at']),
      description: json['description'] ?? '',
    );
  }
}

class InventoryData {
  final List<ConsumptionRecord> consumptionRecords;
  final List<PurchaseRecord> purchaseRecords;

  InventoryData({
    required this.consumptionRecords,
    required this.purchaseRecords,
  });
}

class ConsumptionPurchaseRepository {
  final HttpService _httpService = Get.find();
  final AppDataController _appDataController = Get.find();
  Future<InventoryData> getInventoryData(
    String inventoryType,
    int itemId,
    int type,
  ) async {
    try {
      String endpoint;
      switch (inventoryType.toLowerCase()) {
        case 'fuel':
          endpoint = '/fuel_inventory_and_consumption';
          break;
        case 'pesticides':
          endpoint = '/pesticides-inventory-details';
          break;
        case 'seeds':
          endpoint = '/seeds-inventory-details';
          break;
        case 'fertilizers':
          endpoint = '/fertilizers-inventory-details';
          break;
        case 'tools':
          endpoint = '/tools-inventory-details';
          break;
        case 'vehicle':
          endpoint = '/vehicle-inventory-details';
          break;
        case 'machinery':
          endpoint = '/machinery-inventory-details';
          break;
        default:
          throw Exception('Unknown inventory type: $inventoryType');
      }

      // Get farmer ID from storage

      final farmerId = _appDataController.userId.value;
      final response = await _httpService.get(
        '$endpoint/$farmerId/$type/$itemId',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<ConsumptionRecord> consumptionRecords = [];
        List<PurchaseRecord> purchaseRecords = [];

        // Parse based on inventory type
        switch (inventoryType.toLowerCase()) {
          case 'fuel':
            consumptionRecords = (data['fuel_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['fuel_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          case 'pesticides':
            consumptionRecords = (data['pesticide_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['pesticide_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          case 'seeds':
            consumptionRecords = (data['seeds_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['seeds_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          case 'fertilizers':
            consumptionRecords = (data['fertilizers_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['fertilizers_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          case 'tools':
            consumptionRecords = (data['tools_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['tools_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          case 'vehicle':
            consumptionRecords = (data['vehicle_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['vehicle_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          case 'machinery':
            consumptionRecords = (data['machinery_consumption'] as List)
                .map((json) => ConsumptionRecord.fromJson(json))
                .toList();
            purchaseRecords = (data['machinery_purchase'] as List)
                .map((json) => PurchaseRecord.fromJson(json))
                .toList();
            break;
          default:
            throw Exception('Unknown inventory type: $inventoryType');
        }

        return InventoryData(
          consumptionRecords: consumptionRecords,
          purchaseRecords: purchaseRecords,
        );
      } else {
        throw Exception('Failed to load inventory data');
      }
    } catch (e) {
      rethrow;
    }
  }
}

class ConsumptionPurchaseController extends GetxController {
  final ConsumptionPurchaseRepository _repository = Get.find();
  final PurchasesAddRepository purchasesrepository = PurchasesAddRepository();
  // Observables
  var isLoading = false.obs;
  var selectedInventoryType = Rxn<int>();
  var selectedInventoryCategory = Rxn<int>();
  var selectedInventoryItem = Rxn<int>();
  final selectedInventoryTypeName = 'Fuel'.obs;
  var consumptionData = <ConsumptionRecord>[].obs;
  var purchaseData = <PurchaseRecord>[].obs;
  var currentTabIndex = 0.obs; // 0 = Consumption, 1 = Purchase
  final RxBool isCategoryLoading = false.obs;
  final RxBool isinventoryLoading = false.obs;
  var inventoryCategories = <InventoryCategoryModel>[].obs;
  var inventoryItems = <InventoryItemModel>[].obs;
  @override
  void onInit() {
    super.onInit();
    var argument = Get.arguments['id'];
    var type = Get.arguments["type"];
    selectedInventoryTypeName.value = type;
    setInventoryType(argument);
    fetchInventoryCategories(argument);
  }

  void setInventoryType(int typeId) {
    selectedInventoryType.value = typeId;
    selectedInventoryCategory.value = null;
    selectedInventoryItem.value = null;
  }

  void inventoryCategory(int? value) {
    setInventoryCategory(value!);
    fetchInventoryItems(value);
  }

  void setInventoryCategory(int categoryId) {
    selectedInventoryCategory.value = categoryId;
    selectedInventoryItem.value = null;
  }

  void setInventoryItem(int itemId) {
    selectedInventoryItem.value = itemId;
    loadData();
  }

  Future<void> fetchInventoryCategories(int inventoryTypeId) async {
    try {
      isCategoryLoading(true);
      final response = await purchasesrepository.fetchInventoryCategories(
        inventoryTypeId,
      );
      inventoryCategories.value = response;
      if (inventoryCategories.isNotEmpty) {
        selectedInventoryCategory.value = inventoryCategories.first.id;
        inventoryCategory(inventoryCategories.first.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch inventory categories');
    } finally {
      isCategoryLoading(false);
    }
  }

  Future<void> fetchInventoryItems(int inventoryCategoryId) async {
    try {
      isinventoryLoading(true);
      final response = await purchasesrepository.fetchInventoryItems(
        inventoryCategoryId,
      );
      inventoryItems.value = response;
      if (response.isNotEmpty) {
        setInventoryItem(response.first.id);
      }
    } finally {
      isinventoryLoading(false);
    }
  }

  Future<void> loadData() async {
    if (selectedInventoryItem.value == null) return;

    try {
      isLoading(true);
      final inventoryType = selectedInventoryTypeName.value;
      final inventoryTypeid = selectedInventoryType.value;
      final itemId = selectedInventoryItem.value!;

      final data = await _repository.getInventoryData(
        inventoryType,
        itemId,
        inventoryTypeid!,
      );

      var where = data.consumptionRecords.where((e) {
        return e.quantityUtilized != 0;
      });
      consumptionData.assignAll(where);
      purchaseData.assignAll(data.purchaseRecords);

      if (consumptionData.isEmpty && purchaseData.isEmpty) {
        Fluttertoast.showToast(
          msg: 'no_records_found'.tr,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'failed_to_load_data'.tr,
        toastLength: Toast.LENGTH_SHORT,
      );
    } finally {
      isLoading(false);
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}

class ConsumptionPurchaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsumptionPurchaseRepository>(
      () => ConsumptionPurchaseRepository(),
    );
    Get.lazyPut<PurchasesAddRepository>(() => PurchasesAddRepository());
    Get.lazyPut<ConsumptionPurchaseController>(
      () => ConsumptionPurchaseController(),
    );
  }
}

class ConsumptionPurchaseView extends GetView<ConsumptionPurchaseController> {
  const ConsumptionPurchaseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('consumption_purchase_title'.tr)),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                buildInventoryCategoryDropdown(),
                SizedBox(width: 16),
                buildInventoryItemDropdown(),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Get.theme.colorScheme.surface,
            child: TabBar(
              controller: TabController(
                length: 2,
                initialIndex: controller.currentTabIndex.value,
                vsync: Navigator.of(context),
              ),
              onTap: controller.changeTab,
              tabs: [
                Tab(text: 'consumption'.tr),
                Tab(text: 'purchase'.tr),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // if (controller.selectedItem.value == null) {
              //   return Center(
              //     child: Text('select_item_to_view_data'.tr),
              //   );
              // }

              return IndexedStack(
                index: controller.currentTabIndex.value,
                children: [
                  ConsumptionList(records: controller.consumptionData),
                  PurchaseList(records: controller.purchaseData),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildInventoryCategoryDropdown() {
    return Expanded(
      child: Obx(
        () => Column(
          children: [
            InputCardStyle(
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Inventory Category'.tr,
                  border: InputBorder.none,
                ),
                value: controller.selectedInventoryCategory.value,
                items: controller.inventoryCategories
                    .map(
                      (category) => DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.inventoryCategory(value);
                },
              ),
            ),
            //  ErrorText(error: getErrorForField('vendor')),
          ],
        ),
      ),
    );
  }

  Widget buildInventoryItemDropdown() {
    return Expanded(
      child: Obx(
        () => InputCardStyle(
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'Inventory Item'.tr,
              border: InputBorder.none,
            ),
            value: controller.selectedInventoryItem.value,
            items: controller.inventoryItems
                .map(
                  (item) => DropdownMenuItem<int>(
                    value: item.id,
                    child: Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                controller.selectedInventoryCategory.value != null
                ? controller.setInventoryItem(value!)
                : null,
          ),
        ),
      ),
    );
  }
}

class PurchaseList extends StatelessWidget {
  final List<PurchaseRecord> records;

  const PurchaseList({Key? key, required this.records}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(child: Text('no_purchase_records'.tr));
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                // Leading (Date)
                _formatDate(record.date),

                const SizedBox(width: 12),

                // Title + Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.vendorName, style: Get.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('${record.quantity} ${record.quantityUnit}'),
                      // if (record.description.isNotEmpty)
                      //   Text(record.description),
                    ],
                  ),
                ),

                // Trailing (Amount)
                Text(
                  '₹ ${record.purchaseAmount.toStringAsFixed(2)}',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _formatDate(DateTime date) {
    return Column(
      children: [
        Text(
          _getMonthName(date.month),
          style: TextStyle(
            color: Get.theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          date.day.toString(),
          style: TextStyle(
            color: Get.theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class ConsumptionList extends StatelessWidget {
  final List<ConsumptionRecord> records;

  const ConsumptionList({Key? key, required this.records}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(child: Text('no_consumption_records'.tr));
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
  return Card(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Leading (Date)
        _formatDate(record.dateOfConsumption),

        const SizedBox(width: 12),

        // Title + Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.crop,
                style: Get.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              // Text('available: ${record.availableQuantity} units'),
            ],
          ),
        ),

        // Trailing (Quantity Utilized)
        Text(
          '${record.quantityUtilized} units',
          style: Get.textTheme.titleMedium,
        ),
      ],
    ),
  ),
);

      },
    );
  }

  Widget _formatDate(DateTime date) {
    return Column(
      children: [
        Text(
          _getMonthName(date.month),
          style: TextStyle(
            color: Get.theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          date.day.toString(),
          style: TextStyle(
            color: Get.theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class InventoryDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final T? value;
  final bool enabled;

  const InventoryDropdown({
    Key? key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Get.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Get.theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              hint: Text(hint),
              items: items,
              onChanged: enabled ? onChanged : null,
              value: value,
            ),
          ),
        ),
      ],
    );
  }
}
