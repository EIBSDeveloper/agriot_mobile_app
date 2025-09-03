import 'dart:convert';
import 'package:argiot/consumption_model.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/task/model/model.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
// consumption_repository.dart
// abstract class ConsumptionRepository {
//   Future<List<InventoryTypeModel>> fetchInventoryTypes(String farmerId);
//   Future<List<InventoryCategoryModel>> fetchInventoryCategories(int typeId);
//   Future<List<InventoryItemModel>> fetchInventoryItems(int categoryId);
//   Future<List<DocumentTypeModel>> fetchDocumentTypes();
//   Future<bool> submitConsumption(Map<String, dynamic> consumptionData);
// }

class ConsumptionRepositoryImpl  {
  final HttpService _httpService = Get.find<HttpService>();



  Future<List<InventoryTypeModel>> fetchInventoryTypes(String farmerId) async {
    final response = await _httpService.get('/purchase_list/$farmerId/');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final types = <InventoryTypeModel>[];
      
      data.forEach((key, value) {
        if (key != 'language' && value is Map<String, dynamic>) {
          types.add(InventoryTypeModel.fromJson(key, value));
        }
      });
      
      return types;
    } else {
      throw Exception('Failed to fetch inventory types');
    }
  }


  Future<List<InventoryCategoryModel>> fetchInventoryCategories(int typeId) async {
    final response = await _httpService.get('/get_inventory_category/$typeId');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => InventoryCategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch inventory categories');
    }
  }


  Future<List<InventoryItemModel>> fetchInventoryItems(int categoryId) async {
    final response = await _httpService.get('/get_inventory_items/$categoryId');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => InventoryItemModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch inventory items');
    }
  }


  Future<List<DocumentTypeModel>> fetchDocumentTypes() async {
    final response = await _httpService.get('/document_categories');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => DocumentTypeModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch document types');
    }
  }


  Future<bool> submitConsumption(Map<String, dynamic> consumptionData) async {
    final response = await _httpService.post('/create_consumption/', consumptionData);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to submit consumption');
    }
  }
}

// consumption_controller.dart
class ConsumptionController extends GetxController {
  final ConsumptionRepositoryImpl _repository= ConsumptionRepositoryImpl();
  final AppDataController _appDataController = Get.find();
  
  // Observable variables
  var inventoryTypes = <InventoryTypeModel>[].obs;
  var inventoryCategories = <InventoryCategoryModel>[].obs;
  var inventoryItems = <InventoryItemModel>[].obs;
  var isLoading = false.obs;
  var isCategoryLoading = false.obs;
  var isTypeLoading = false.obs;
  var isinventoryLoading = false.obs;
  var isdocumentTypesLoading = false.obs;
  
  // Form fields
  var selectedDate = DateTime.now().obs;
  final Rx<CropModel> selectedCropType = CropModel(id: 0, name: '').obs;
  final RxList<CropModel> crop = <CropModel>[].obs;
  
  var selectedInventoryType = Rxn<int>();
  var selectedInventoryCategory = Rxn<int>();
  var selectedInventoryItem = Rxn<int>();
  var quantity = ''.obs;
  var description = ''.obs;
  var usageHours = ''.obs;
  var startKilometer = ''.obs;
  var endKilometer = ''.obs;
  var toolItems = ''.obs;
  var documents = <Document>[].obs;
  
  ConsumptionController();

  // Getter to check if current inventory type requires usage hours
  bool get requiresUsageHours {
    final typeId = selectedInventoryType.value;
    return typeId == 2 || typeId == 3 || typeId == 4 || typeId == 7;
  }
  
  // Getter to check if current inventory type requires kilometer fields
  bool get requiresKilometerFields {
    return selectedInventoryType.value == 1;
  }
  
  // Getter to check if current inventory type requires tool items
  bool get requiresToolItems {
    return selectedInventoryType.value == 3;
  }

  @override
  void onInit() {
    super.onInit();
    getCropList();
    fetchInventoryTypes();
    fetchDocumentTypes();
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  void setInventoryType(int typeId) {
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
  }

  void setInventoryCategory(int categoryId) {
    selectedInventoryCategory.value = categoryId;
    selectedInventoryItem.value = null;
    inventoryItems.clear();
  }

  void setInventoryItem(int itemId) {
    selectedInventoryItem.value = itemId;
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

  void addDocument(Document document) {
    documents.add(document);
  }

  void changeCrop(CropModel crop) {
    selectedCropType.value = crop;
  }

  void removeDocument(int index) {
    documents.removeAt(index);
  }

  Future<void> fetchInventoryTypes() async {
    final farmerId = _appDataController.userId.value;
    try {
      isTypeLoading(true);
      final types = await _repository.fetchInventoryTypes(farmerId);
      inventoryTypes.assignAll(types);
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
      final categories = await _repository.fetchInventoryCategories(inventoryTypeId);
      inventoryCategories.assignAll(categories);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to fetch inventory categories'.tr);
    } finally {
      isCategoryLoading(false);
    }
  }

  Future<void> fetchInventoryItems(int inventoryCategoryId) async {
    try {
      isinventoryLoading(true);
      final items = await _repository.fetchInventoryItems(inventoryCategoryId);
      inventoryItems.assignAll(items);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to fetch inventory items'.tr);
    } finally {
      isinventoryLoading(false);
    }
  }

  Future<void> fetchDocumentTypes() async {
    try {
      isdocumentTypesLoading(true);
      final docTypes = await _repository.fetchDocumentTypes();
      // documentTypes.assignAll(docTypes);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to fetch document types'.tr);
    } finally {
      isdocumentTypesLoading(false);
    }
  }

  Future<bool> submitConsumption() async {
    if (!isFormValid) {
      Fluttertoast.showToast(msg: 'Please fill all required fields'.tr);
      return false;
    }

    // Additional validation for conditional fields
    if (requiresUsageHours && usageHours.value.isEmpty) {
      Fluttertoast.showToast(msg: 'Usage hours is required'.tr);
      return false;
    }

    if (requiresKilometerFields && (startKilometer.value.isEmpty || endKilometer.value.isEmpty)) {
      Fluttertoast.showToast(msg: 'Start and end kilometer are required'.tr);
      return false;
    }

    if (requiresKilometerFields && double.parse(startKilometer.value) >= double.parse(endKilometer.value)) {
      Fluttertoast.showToast(msg: 'End kilometer must be greater than start kilometer'.tr);
      return false;
    }

    if (requiresToolItems && toolItems.value.isEmpty) {
      Fluttertoast.showToast(msg: 'Tool items are required'.tr);
      return false;
    }

    final String farmerId = _appDataController.userId.value;
    try {
      isLoading(true);
      
      // Prepare the request body based on inventory type
      final Map<String, dynamic> requestBody = {
        "date_of_consumption": selectedDate.value.toIso8601String().split('T')[0],
        "crop": selectedCropType.value.id,
        "inventory_type": selectedInventoryType.value.toString(),
        "inventory_category": selectedInventoryCategory.value!,
        "inventory_items": selectedInventoryItem.value!,
        "description": description.value,
        "farmer": farmerId,
        "quantity_utilized": quantity.value,
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
      if (documents.isNotEmpty) {
        requestBody["documents"] = documents.map((doc) => doc.toJson()).toList();
      }

      final success = await _repository.submitConsumption(requestBody);

      if (success) {
        Fluttertoast.showToast(msg: 'Consumption recorded successfully'.tr);
        clearForm();
        return true;
      } else {
        Fluttertoast.showToast(msg: 'Failed to record consumption'.tr);
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
      return false;
    } finally {
      isLoading(false);
    }
  }

  void clearForm() {
    selectedDate.value = DateTime.now();
    selectedCropType.value = crop.isNotEmpty ? crop.first : CropModel(id: 0, name: '');
    selectedInventoryType.value = null;
    selectedInventoryCategory.value = null;
    selectedInventoryItem.value = null;
    quantity.value = '';
    description.value = '';
    usageHours.value = '';
    startKilometer.value = '';
    endKilometer.value = '';
    toolItems.value = '';
    documents.clear();
  }

  bool get isFormValid {
    bool basicValid = selectedInventoryType.value != null &&
        selectedInventoryCategory.value != null &&
        selectedInventoryItem.value != null &&
        quantity.value.isNotEmpty &&
        selectedCropType.value.id != 0;

    // Add conditional validation
    if (requiresUsageHours) {
      basicValid = basicValid && usageHours.value.isNotEmpty;
    }

    if (requiresKilometerFields) {
      basicValid = basicValid && startKilometer.value.isNotEmpty && endKilometer.value.isNotEmpty;
    }

    if (requiresToolItems) {
      basicValid = basicValid && toolItems.value.isNotEmpty;
    }

    return basicValid;
  }
}