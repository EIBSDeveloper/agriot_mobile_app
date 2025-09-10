import 'dart:async';
import 'dart:convert';
import 'package:argiot/src/app/modules/expense/model/consumption_model.dart';
import 'package:argiot/src/app/modules/expense/repostroy/consumption_repository.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/task/model/crop_model.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../service/utils/enums.dart';
import '../../../service/utils/utils.dart';
import '../../document/binding/document_binding.dart';
import '../../document/model/add_document_model.dart';
import '../../document/view/add_document_view.dart';

class ConsumptionController extends GetxController {
  final ConsumptionRepository _repository = ConsumptionRepository();
  final AppDataController _appDataController = Get.find();

  final formKey = GlobalKey<FormState>();
  // Observable variables
  RxList<InventoryTypeModel> inventoryTypes = <InventoryTypeModel>[].obs;
  RxList<InventoryCategoryModel> inventoryCategories =
      <InventoryCategoryModel>[].obs;
  RxList<InventoryItemModel> inventoryItems = <InventoryItemModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isCategoryLoading = false.obs;
  RxBool isTypeLoading = false.obs;
  RxBool isInventoryLoading = false.obs;
  RxBool documentTypesLoading = false.obs;

  // Form fields
  Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<CropModel> selectedCropType = CropModel(id: 0, name: '').obs;
  final RxList<CropModel> crop = <CropModel>[].obs;
  final RxList<AddDocumentModel> documentItems = <AddDocumentModel>[].obs;

  Rxn<int> selectedInventoryType = Rxn<int>();
  Rxn<String> selectedInventoryTypeName = Rxn<String>();
  Rxn<int> selectedInventoryCategory = Rxn<int>();
  Rxn<int> selectedInventoryItem = Rxn<int>();
  RxString quantity = ''.obs;
  RxString description = ''.obs;
  RxString usageHours = ''.obs;
  RxString startKilometer = ''.obs;
  RxString endKilometer = ''.obs;
  RxString toolItems = ''.obs;

  Rxn<int> inventoryType = Rxn<int>();
  Rxn<int> inventoryCategory = Rxn<int>();
  Rxn<int> inventoryItem = Rxn<int>();

  // Getter to check if current inventory type requires usage hours
  bool get requiresUsageHours {
    final typeId = selectedInventoryType.value;
    return typeId == 2 || typeId == 3 || typeId == 1;
  }

  bool get requiresQuantity {
    final typeId = selectedInventoryType.value;
    return typeId == 7 || typeId == 5 || typeId == 4 || typeId == 3;
  }

  bool get requiresUnit {
    final typeId = selectedInventoryType.value;
    return typeId == 4 || typeId == 5 || typeId == 7;
  }

  // Getter to check if current inventory type requires kilometer fields
  bool get requiresKilometerFields => selectedInventoryType.value == 1;

  // Getter to check if current inventory type requires tool items
  bool get requiresToolItems => selectedInventoryType.value == 3;

  @override
  void onInit() {
    super.onInit();
    unawaited(getCropList());
    final arguments = Get.arguments;
    if (arguments?["type"] != null) {
      inventoryType.value = arguments?["type"];
    }
    if (arguments?["category"] != null) {
      inventoryCategory.value = arguments?["category"];
    }
    if (arguments?["item"] != null) {
      inventoryItem.value = arguments?["item"];
    }
    unawaited(fetchInventoryTypes());
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  Future<void> setInventoryType(int typeId) async {
    selectedInventoryType.value = typeId;
    selectedInventoryCategory.value = null;
    inventoryCategories.clear();
    selectedInventoryItem.value = null;
    inventoryItems.clear();

    // Clear conditional fields when type changes
    usageHours.value = '';
    startKilometer.value = '';
    endKilometer.value = '';
    toolItems.value = '';
    await fetchInventoryCategories(typeId);
  }

  Future<void> setInventoryCategory(int categoryId) async {
    selectedInventoryCategory.value = categoryId;
    selectedInventoryItem.value = null;
    inventoryItems.clear();
    await fetchInventoryItems(categoryId);
  }

  void removeDocumentItem(int index) {
    documentItems.removeAt(index);
  }

  void addDocumentItem() {
    Get.to(
      const AddDocumentView(),
      binding: DocumentBinding(),
      arguments: {"id": getDocTypeId(DocType.inventory)},
    )?.then((result) {
      if (result != null && result is AddDocumentModel) {
        documentItems.add(result);
      }
      print(documentItems.toString());
    });
  }

  void setInventoryItem(int itemId) {
    selectedInventoryItem.value = itemId;
    if (inventoryItem.value != null) {
      inventoryCategory.value = null;
      inventoryType.value = null;
      inventoryItem.value = null;
    }
  }

  void setQuantity(String value) {
    quantity.value = value;
  }

  void setDescription(String value) {
    description.value = value;
  }

  void setUsageHours(String value) {
    usageHours.value = value;
  }

  void setStartKilometer(String value) {
    startKilometer.value = value;
  }

  void setEndKilometer(String value) {
    endKilometer.value = value;
  }

  void setToolItems(String value) {
    toolItems.value = value;
  }

  void changeCrop(CropModel crop) {
    selectedCropType.value = crop;
  }

  Future<void> fetchInventoryTypes() async {
    final farmerId = _appDataController.userId.value;
    try {
      isTypeLoading(true);
      final types = await _repository.fetchInventoryTypes(farmerId);
      inventoryTypes.assignAll(types);
      if (inventoryType.value != null) {
        setInventoryType(inventoryType.value!);
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to fetch inventory types'.tr);
    } finally {
      isTypeLoading(false);
    }
  }

  Future<void> getCropList() async {
    final farmerId = _appDataController.userId.value;
    try {
      final response = await Get.find<HttpService>().get(
        '/land-and-crop-details/$farmerId',
      );
      final lands = json.decode(response.body)['lands'] as List;

      final cropList = lands
          .expand((land) => land['crops'] as List)
          .map((crop) => CropModel.fromJson(crop))
          .toSet()
          .toList();

      crop.assignAll(cropList);

      if (cropList.isNotEmpty) {
        selectedCropType.value = cropList.first;
      }
    } catch (e) {
      throw Exception('Failed to load crops: ${e.toString()}');
    }
  }

  Future<void> fetchInventoryCategories(int inventoryTypeId) async {
    try {
      isCategoryLoading(true);
      final categories = await _repository.fetchInventoryCategories(
        inventoryTypeId,
      );
      inventoryCategories.assignAll(categories);
      if (inventoryCategories.isNotEmpty && inventoryCategory.value != null) {
        setInventoryCategory(inventoryCategory.value!);
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to fetch inventory categories'.tr);
    } finally {
      isCategoryLoading(false);
    }
  }

  Future<void> fetchInventoryItems(int inventoryCategoryId) async {
    try {
      isInventoryLoading(true);
      final items = await _repository.fetchInventoryItems(inventoryCategoryId);
      inventoryItems.assignAll(items);
      if (inventoryItem.value != null) {
        setInventoryItem(inventoryItem.value!);
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to fetch inventory items'.tr);
    } finally {
      isInventoryLoading(false);
    }
  }

  Future<bool> submitConsumption() async {
    if (!formKey.currentState!.validate()) return false;

    final String farmerId = _appDataController.userId.value;
    try {
      isLoading(true);

      // Prepare the request body based on inventory type
      var s = requiresUsageHours ? usageHours.value : quantity.value;
      final Map<String, dynamic> requestBody = {
        "date_of_consumption": selectedDate.value.toIso8601String().split(
          'T',
        )[0],
        "crop": selectedCropType.value.id,
        "inventory_type": selectedInventoryType.value.toString(),
        "inventory_category": selectedInventoryCategory.value,
        "inventory_items": selectedInventoryItem.value,
        "description": description.value,
        "farmer": farmerId,
        "quantity_utilized": s,
      };

      // Add conditional fields
      if (requiresUsageHours && usageHours.value.isNotEmpty) {
        requestBody["usage_hours"] = usageHours.value;
      }

      if (requiresKilometerFields) {
        requestBody["start_kilometer"] = double.parse(startKilometer.value);
        requestBody["end_kilometer"] = double.parse(endKilometer.value);
      }

      if (requiresToolItems && toolItems.value.isNotEmpty) {
        requestBody["items"] = toolItems.value;
      }

      // Add documents if any

      final success = await _repository.submitConsumption(requestBody);

      if (success) {
        showSuccess( 'Consumption recorded successfully'.tr);
        // clearForm();
        return true;
      } else {
        Fluttertoast.showToast(msg: 'Failed to record consumption'.tr);
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  void clearForm() {
    selectedDate.value = DateTime.now();
    selectedCropType.value = crop.isNotEmpty
        ? crop.first
        : CropModel(id: 0, name: '');
    selectedInventoryType.value = null;
    selectedInventoryCategory.value = null;
    selectedInventoryItem.value = null;
    quantity.value = '';
    description.value = '';
    usageHours.value = '';
    startKilometer.value = '';
    endKilometer.value = '';
    toolItems.value = '';
  }

  bool get isFormValid {
    bool basicValid =
        selectedInventoryType.value != null &&
        selectedInventoryCategory.value != null &&
        selectedInventoryItem.value != null &&
        quantity.value.isNotEmpty &&
        selectedCropType.value.id != 0;

    if (requiresUsageHours) {
      basicValid = basicValid && usageHours.value.isNotEmpty;
    }

    if (requiresKilometerFields) {
      basicValid =
          basicValid &&
          startKilometer.value.isNotEmpty &&
          endKilometer.value.isNotEmpty;
    }

    if (requiresToolItems) {
      basicValid = basicValid && toolItems.value.isNotEmpty;
    }

    return basicValid;
  }
}
