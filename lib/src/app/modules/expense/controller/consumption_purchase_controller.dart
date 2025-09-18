import 'package:argiot/src/app/modules/expense/model/inventory_category_model.dart';
import 'package:argiot/src/app/modules/expense/model/inventory_item_model.dart';
import 'package:argiot/src/app/modules/expense/repostroy/consumption_purchase_repository.dart';
import 'package:argiot/src/app/modules/expense/repostroy/purchases_add_repository.dart';
import 'package:argiot/src/app/modules/expense/model/consumption_record.dart';
import 'package:argiot/src/app/modules/expense/model/purchase_record.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../service/utils/utils.dart';

class ConsumptionPurchaseController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ConsumptionPurchaseRepository _repository = Get.find();
  final PurchasesAddRepository purchasesrepository = PurchasesAddRepository();
  // Observables
  RxInt purchasePage = 0.obs;
  RxInt consumptionPage = 0.obs;
  RxBool isLoading = false.obs;
  var selectedInventoryType = Rxn<int>();
  var selectedInventoryCategory = Rxn<int>();
  var selectedInventoryItem = Rxn<int>();
  RxString selectedInventoryTypeName = 'Fuel'.obs;
  RxList<ConsumptionItem> consumptionData = <ConsumptionItem>[].obs;
  RxList<PurchaseItem> purchaseData = <PurchaseItem>[].obs;
  // var currentTabIndex = 0.obs;
  late TabController tabController;
  // 0 = Consumption, 1 = Purchase
  final RxBool isCategoryLoading = false.obs;
  final RxBool isinventoryLoading = false.obs;
  var inventoryCategories = <InventoryCategoryModel>[].obs;
  var inventoryItems = <InventoryItemModel>[].obs;
  final Rxn<int> inventoryType = Rxn<int>();
  final Rxn<int> inventoryCategory = Rxn<int>();
  final Rxn<int> inventoryItem = Rxn<int>();
  RxBool isLoadingMorePurchase = false.obs;
  RxBool isLoadingMoreConsumption = false.obs;
  RxBool hasMorePurchase = true.obs;
  RxBool hasMoreConsumption = true.obs;
  // Scroll controllers for detecting page end
  ScrollController purchaseScrollController = ScrollController();
  ScrollController consumptionScrollController = ScrollController();
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    var arguments = Get.arguments;

    var tab = Get.arguments["tab"];
    if (tab != null) {
      tabController.animateTo(tab);
      // currentTabIndex.value = tab;
    }
    if (arguments?["id"] != null) {
      inventoryType.value = arguments?["id"];
    }
    if (arguments?["category"] != null) {
      inventoryCategory.value = arguments?["category"];
    }
    if (arguments?["item"] != null) {
      inventoryItem.value = arguments?["item"];
    }
    selectedInventoryTypeName.value = getType(inventoryType.value ?? 0);

    setInventoryType(inventoryType.value ?? 0);
    purchaseScrollController.addListener(_onPurchaseScroll);
    consumptionScrollController.addListener(_onConsumptionScroll);
  }

  @override
  void onClose() {
    purchaseScrollController.dispose();
    consumptionScrollController.dispose();
    super.onClose();
  }

  void _onPurchaseScroll() {
    if (purchaseScrollController.position.pixels ==
        purchaseScrollController.position.maxScrollExtent) {
      if (hasMorePurchase.value && !isLoadingMorePurchase.value) {
        loadMorePurchaseData();
      }
    }
  }

  void _onConsumptionScroll() {
    if (consumptionScrollController.position.pixels ==
        consumptionScrollController.position.maxScrollExtent) {
      if (hasMoreConsumption.value && !isLoadingMoreConsumption.value) {
        loadMoreConsumptionData();
      }
    }
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

  Future<void> refreshData() async {
    // Reset pagination on refresh
    purchasePage.value = 1;
    consumptionPage.value = 1;
    hasMorePurchase.value = true;
    hasMoreConsumption.value = true;

    // Clear existing data
    purchaseData.clear();
    consumptionData.clear();

    // Load fresh data
    await loadData();
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
      showError('Failed to fetch inventory categories');
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

  loadData() {
    loadMorePurchaseData();
    loadMoreConsumptionData();
  }

  Future<void> loadMorePurchaseData() async {
    if (selectedInventoryItem.value == null) return;
    if (isLoadingMorePurchase.value || !hasMorePurchase.value) return;

    try {
      isLoadingMorePurchase(true);

      purchasePage.value++;

      final data = await _repository.getPurchaseList(
        itemId: selectedInventoryItem.value!,
        type: selectedInventoryType.value!,
        page: purchasePage.value,
      );

      purchaseData.assignAll(data);

      if (purchaseData.isEmpty) {
        showWarning('no_records_found'.tr);
      }
    } catch (e) {
      purchasePage.value--;
      showError('failed_to_load_data'.tr);
    } finally {
      isLoadingMorePurchase(false);
    }
  }

  Future<void> loadMoreConsumptionData() async {
    if (isLoadingMoreConsumption.value || !hasMoreConsumption.value) return;
    if (selectedInventoryItem.value == null) return;
    try {
      isLoadingMoreConsumption(true);
      consumptionPage.value++;

      final data = await _repository.getConsumptionList(
        itemId: selectedInventoryItem.value!,
        type: selectedInventoryType.value!,
        page: consumptionPage.value,
      );

      consumptionData.assignAll(data);
      if (consumptionData.isEmpty) {
        showWarning('no_records_found'.tr);
      }
    } catch (e) {
      showError('failed_to_load_data'.tr);
    } finally {
      isLoading(false);
    }
  }

  void reLoad(result) {
    if (result ?? false) {
      loadData();
    }
  }

  void open() {
    if (tabController.index == 0) {
      Get.toNamed(
        Routes.fuelConsumption,
        arguments: {
          "type": selectedInventoryType.value,
          "category": selectedInventoryCategory.value,
          "item": selectedInventoryItem.value,
        },
      )?.then((result) {
        reLoad(result);
      });
    } else {
      if (selectedInventoryType.value == 6) {
        Get.toNamed(
          '/fuel-expenses-entry',
          arguments: {
            "id": selectedInventoryType.value,
            "category": selectedInventoryCategory.value,
            "item": selectedInventoryItem.value,
          },
        )?.then((result) {
          reLoad(result);
        });
      } else if (selectedInventoryType.value == 1) {
        Get.toNamed(
          '/vehicle_entry',
          arguments: {
            "id": selectedInventoryType.value,
            "category": selectedInventoryCategory.value,
            "item": selectedInventoryItem.value,
          },
        )?.then((result) {
          reLoad(result);
        });
      } else if (selectedInventoryType.value == 2) {
        Get.toNamed(
          '/machinery_entry',
          arguments: {
            "id": selectedInventoryType.value,
            "category": selectedInventoryCategory.value,
            "item": selectedInventoryItem.value,
          },
        )?.then((result) {
          reLoad(result);
        });
      } else {
        Get.toNamed(
          '/fertilizer_entry',
          arguments: {
            "id": selectedInventoryType.value,
            "category": selectedInventoryCategory.value,
            "item": selectedInventoryItem.value,
          },
        )?.then((result) {
          reLoad(result);
        });
      }
    }
  }
}
