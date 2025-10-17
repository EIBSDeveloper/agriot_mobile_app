import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/inventory/repostory/inventory_repository.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../model/inventory_item.dart';
import '../model/inventory_list.dart';

class InventoryController extends GetxController {
  final InventoryRepository _repository = InventoryRepository();

  AppDataController appDeta = Get.find();
  final Rx<List<InventoryType>?> inventory = Rx<List<InventoryType>?>(null);
  final Rx<List<InventoryList>?> inventoryItemList = Rx<List<InventoryList>?>(
    null,
  );
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt expandedLandId = (-1).obs;
  @override
  void onInit() {
    super.onInit();
    loadInventory();
    loadInventoryItemList();
  }

  Future<void> loadInventory() async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await _repository.getInventory();
      inventory(result);
    } catch (e) {
      errorMessage(e.toString());
      showError("Failed to load inventory: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadInventoryItemList() async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await _repository.getInventoryItemList();
      inventoryItemList(result);
    } catch (e) {
      errorMessage(e.toString());
      showError("Failed to load inventory: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  void navigateToAddInventory() {
    Get.toNamed(Routes.fuelConsumption)?.then((res) {
      if (res ?? false) {
        loadInventoryItemList();
      }
    });
  }

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

  void toggleExpandLand(int landId) {
    expandedLandId.value = expandedLandId.value == landId ? -1 : landId;
  }

  void navigateToCategoryDetail(int id, {int tab = 0}) {
    Get.toNamed(
      Routes.consumptionPurchaseList,
      arguments: {"id": id, 'tab': tab},
    );
  }
}
