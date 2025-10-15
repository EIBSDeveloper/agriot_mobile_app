import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/expense/model/inventory_item_model.dart';
import 'package:argiot/src/app/modules/expense/repostroy/consumption_purchase_repository.dart';
import 'package:argiot/src/app/modules/expense/repostroy/purchases_add_repository.dart';
import 'package:argiot/src/app/modules/expense/model/consumption_record.dart';
import 'package:argiot/src/app/modules/expense/model/purchase_record.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../inventory/model/inventory_item.dart';
import '../model/inventory_item_quantity.dart';

class ConsumptionPurchaseController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AppDataController appDeta = Get.find();
  final ConsumptionPurchaseRepository _repository = Get.find();
  final PurchasesAddRepository purchasesrepository = PurchasesAddRepository();
  // Observables
  RxInt purchasePage = 0.obs;
  RxInt consumptionPage = 0.obs;
  RxBool isLoading = false.obs;
  var selectedInventoryType = Rxn<int>();
  // var selectedInventoryCategory = Rxn<int>();
  var selectedInventoryItem = Rxn<int>();
  final Rxn<InventoryItemQuantity> inventoryItemQuantity =
      Rxn<InventoryItemQuantity>();
  RxList<ConsumptionItem> consumptionData = <ConsumptionItem>[].obs;
  RxList<PurchaseItem> purchaseData = <PurchaseItem>[].obs;
  // var currentTabIndex = 0.obs;
  late TabController tabController;
  // 0 = Consumption, 1 = Purchase
  final RxBool isCategoryLoading = false.obs;
  final RxBool isinventoryLoading = false.obs;
  var inventoryTypes = <InventoryType>[].obs;
  var inventoryItems = <InventoryItemModel>[].obs;
  final Rxn<int> inventoryType = Rxn<int>();
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
    }
    if (arguments?["id"] != null) {
      inventoryType.value = arguments?["id"];
    }
    if (arguments?["item"] != null) {
      inventoryItem.value = arguments?["item"];
    }
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
    await getItemQuantity();
    purchaseRefresh();
    cunsumptionRefresh();
  }

  Future<void> getItemQuantity() async {
    inventoryItemQuantity.value = await purchasesrepository
        .fetchInventoryItemsQuantity(
          selectedInventoryType.value!,
          selectedInventoryItem.value!,
        );
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
      final response = await purchasesrepository.getInventory();
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
    } catch (e) {
      consumptionPage.value--;
      showError('failed_to_load_data'.tr);
    } finally {
      isLoadingMoreConsumption(false);
    }
  }

  void reLoad(result) {
    if (result ?? false) {
      getItemQuantity();
      purchaseRefresh();
    }
  }

  void open() {
    final permission = appDeta.permission.value;

  bool hasConsumption() {
    if (appDeta.permission.value == null) return true;
    return (appDeta.permission.value?.fuel?.consumption ?? 0) != 0 ||
        (appDeta.permission.value?.fertilizer?.consumption ?? 0) != 0 ||
        (appDeta.permission.value?.pesticides?.consumption ?? 0) != 0 ||
        (appDeta.permission.value?.vehicle?.consumption ?? 0) != 0 ||
        (appDeta.permission.value?.machinery?.consumption ?? 0) != 0 ||
        (appDeta.permission.value?.tools?.consumption ?? 0) != 0 ||
        (appDeta.permission.value?.seeds?.consumption ?? 0) != 0;
  }
    if (tabController.index == 0 && hasConsumption()) {
      Get.toNamed(
        Routes.fuelConsumption,
        arguments: {
          "type": selectedInventoryType.value,
          "item": selectedInventoryItem.value,
        },
      )?.then((result) {
        if (result ?? false) {
          getItemQuantity();
          cunsumptionRefresh();
        }
      });
    } else if (tabController.index == 1 && permission?.expense?.add != 0) {
      if (selectedInventoryType.value == 6) {
        Get.toNamed(
          Routes.addFuel,
          arguments: {
            "id": selectedInventoryType.value,
            "item": selectedInventoryItem.value,
          },
        )?.then((result) {
          reLoad(result);
        });
      } else if (selectedInventoryType.value == 1) {
        Get.toNamed(
          Routes.addVehicle,
          arguments: {
            "id": selectedInventoryType.value,
            "item": selectedInventoryItem.value,
          },
        )?.then((result) {
          reLoad(result);
        });
      } else if (selectedInventoryType.value == 2) {
        Get.toNamed(
          Routes.addMachinery,
          arguments: {
            "id": selectedInventoryType.value,
            "item": selectedInventoryItem.value,
          },
        )?.then((result) {
          reLoad(result);
        });
      } else {
        Get.toNamed(
          Routes.addInventoryItem,
          arguments: {
            "id": selectedInventoryType.value,
            "item": selectedInventoryItem.value,
          },
        )?.then((result) {
          reLoad(result);
        });
      }
    } else {
      showWarning("You don't have permission to access this.");
    }
  }
}
