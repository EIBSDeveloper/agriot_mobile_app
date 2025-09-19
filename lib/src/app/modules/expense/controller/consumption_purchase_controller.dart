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
import '../model/inventory_type_model.dart';

class ConsumptionPurchaseController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ConsumptionPurchaseRepository _repository = Get.find();
  final PurchasesAddRepository purchasesrepository = PurchasesAddRepository();
  // Observables
  RxInt purchasePage = 0.obs;
  RxInt consumptionPage = 0.obs;
  RxBool isLoading = false.obs;
  var selectedInventoryType = Rxn<int>();
  // var selectedInventoryCategory = Rxn<int>();
  var selectedInventoryItem = Rxn<int>();
  RxString selectedInventoryTypeName = 'Fuel'.obs;
  RxList<ConsumptionItem> consumptionData = <ConsumptionItem>[].obs;
  RxList<PurchaseItem> purchaseData = <PurchaseItem>[].obs;
  // var currentTabIndex = 0.obs;
  late TabController tabController;
  // 0 = Consumption, 1 = Purchase
  final RxBool isCategoryLoading = false.obs;
  final RxBool isinventoryLoading = false.obs;
  var inventoryTypes = <InventoryTypeModel>[].obs;
  var inventoryItems = <InventoryItemModel>[].obs;
  final Rxn<int> inventoryType = Rxn<int>();
  // final Rxn<int> inventoryCategory = Rxn<int>();
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
    // if (arguments?["category"] != null) {
    //   inventoryCategory.value = arguments?["category"];
    // }
    if (arguments?["item"] != null) {
      inventoryItem.value = arguments?["item"];
    }
    selectedInventoryTypeName.value = getType(inventoryType.value ?? 0);
    fetchInventoryCategories();

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
    selectedInventoryItem.value = null;
    fetchInventoryItems(typeId);
  }

  void setInventoryItem(int itemId) {
    selectedInventoryItem.value = itemId;
    refreshData();
  }

  Future<void> refreshData() async {
    purchaseRefresh();
    cunsumptionRefresh();
  }

  void purchaseRefresh() {
    purchasePage.value = 0;
    hasMorePurchase.value = true;
    purchaseData.clear();
    loadMorePurchaseData();
  }

  void cunsumptionRefresh() {
     consumptionPage.value = 0;
    hasMoreConsumption.value = true;
    consumptionData.clear();
    loadMoreConsumptionData();
  }

  Future<void> fetchInventoryCategories() async {
    try {
      isCategoryLoading(true);
      final response = await purchasesrepository.fetchInventoryTypes();
      inventoryTypes.value = response;
      if (inventoryType.value != null) {
        selectedInventoryType.value = inventoryType.value;
        setInventoryType(inventoryType.value!);
      } else if (inventoryTypes.isNotEmpty) {
        selectedInventoryType.value = inventoryTypes.first.id;
        setInventoryType(inventoryTypes.first.id);
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

      purchaseData.addAll(data);

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
    if (selectedInventoryItem.value == null) return;
    if (isLoadingMoreConsumption.value || !hasMoreConsumption.value) return;

    try {
      isLoadingMoreConsumption(true);
      consumptionPage.value++;

      final data = await _repository.getConsumptionList(
        itemId: selectedInventoryItem.value!,
        type: selectedInventoryType.value!,
        page: consumptionPage.value,
      );

      consumptionData.addAll(data);
      if (consumptionData.isEmpty) {
        showWarning('no_records_found'.tr);
      }
    } catch (e) {
      consumptionPage.value--;
      showError('failed_to_load_data'.tr);
    } finally {
      isLoadingMoreConsumption(false);
    }
  }

  void reLoad(result) {
    if (result ?? false) {
     purchaseRefresh();
    }
  }

  void open() {
    if (tabController.index == 0) {
      Get.toNamed(
        Routes.fuelConsumption,
        arguments: {
          "type": selectedInventoryType.value,
          "item": selectedInventoryItem.value,
        },
      )?.then((result) {
        if(result??false){
          cunsumptionRefresh();
        }
      });
    } else {
      if (selectedInventoryType.value == 6) {
        Get.toNamed(
          '/fuel-expenses-entry',
          arguments: {
            "id": selectedInventoryType.value,
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
            "item": selectedInventoryItem.value,
          },
        )?.then((result) {
          reLoad(result);
        });
      }
    }
  }
}
