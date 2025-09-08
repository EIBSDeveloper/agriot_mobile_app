import 'package:argiot/src/app/modules/expense/model/consumption_model.dart';
import 'package:argiot/src/app/modules/expense/repostroy/consumption_purchase_repository.dart';
import 'package:argiot/src/app/modules/expense/repostroy/purchases_add_repository.dart';
import 'package:argiot/src/app/modules/expense/model/consumption_record.dart';
import 'package:argiot/src/app/modules/expense/model/purchase_record.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../service/utils/utils.dart';

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
  final Rxn<int> inventoryType = Rxn<int>();
  final Rxn<int> inventoryCategory = Rxn<int>();
  final Rxn<int> inventoryItem = Rxn<int>();
  @override
  void onInit() {
    super.onInit();
    var arguments = Get.arguments;

    var tab = Get.arguments["tab"];
    if (tab != null) {
      currentTabIndex.value = tab;
    }
    if (arguments?["id"] != null) {
      inventoryType.value = arguments?["type"];
    }
    if (arguments?["category"] != null) {
      inventoryCategory.value = arguments?["category"];
    }
    if (arguments?["item"] != null) {
      inventoryItem.value = arguments?["item"];
    }
    selectedInventoryTypeName.value = getType(inventoryType.value ?? 0);

    setInventoryType(inventoryType.value ?? 0);
  }

  void setInventoryType(int typeId) {
    selectedInventoryType.value = typeId;
    selectedInventoryCategory.value = null;
    selectedInventoryItem.value = null;
    fetchInventoryCategories(typeId);
  }

  void setInventoryCategory(int categoryId) {
    selectedInventoryCategory.value = categoryId;
    selectedInventoryItem.value = null;
    fetchInventoryItems(categoryId);
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
      if (inventoryCategory.value != null) {
        selectedInventoryCategory.value = inventoryCategory.value;
        setInventoryCategory(inventoryCategory.value!);
      } else if (inventoryCategories.isNotEmpty) {
        selectedInventoryCategory.value = inventoryCategories.first.id;
        setInventoryCategory(inventoryCategories.first.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch inventory categories');
    } finally {
      isCategoryLoading(false);
    }
  }

  String? get selectedInventoryItemName {
    try {
      final selectedId = selectedInventoryItem.value;
      final String item = inventoryItems.isNotEmpty
          ? inventoryItems
                .firstWhere((element) => element.id == selectedId)
                .name
          : '';
      return item;
    } catch (e) {
      return '';
    }
  }

  Future<void> fetchInventoryItems(int inventoryCategoryId) async {
    try {
      isinventoryLoading(true);
      final response = await purchasesrepository.fetchInventoryItems(
        inventoryCategoryId,
      );
      inventoryItems.value = response;
      if (inventoryItem.value != null) {
        setInventoryItem(inventoryItem.value!);
      } else if (response.isNotEmpty) {
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
      consumptionData.clear();
      purchaseData.clear();
      final inventoryType = selectedInventoryTypeName.value;
      final inventoryTypeid = selectedInventoryType.value;
      final itemId = selectedInventoryItem.value!;

      final data = await _repository.getInventoryData(
        inventoryType,
        itemId,
        inventoryTypeid!,
      );

      var where = data.consumptionRecords.where((e) => e.quantityUtilized != 0);
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
