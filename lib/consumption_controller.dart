import 'dart:convert';
import 'package:argiot/consumption_model.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/task/model/model.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class ConsumptionController extends GetxController {
  // final FuelConsumptionRepository _repository = FuelConsumptionRepository();
  final HttpService _httpService = Get.find<HttpService>();
  final AppDataController _appDataController = Get.find();
  var inventoryTypes = <InventoryTypeModel>[].obs;
  var inventoryCategories = <InventoryCategoryModel>[].obs;
  var inventoryItems = <InventoryItemModel>[].obs;
  var isinventoryLoading = false.obs;
  var documentTypes = <DocumentTypeModel>[].obs;
  var isdocumentTypesLoading = false.obs;
  var isCategoryLoading = false.obs;
  var isTypeLoading = false.obs;

  var isLoading = false.obs;
  var selectedDate = DateTime.now().obs;
  var selectedCrop = Rxn<int>();
  final Rx<CropModel> selectedCropType = CropModel(id: 0, name: '').obs;

  final RxList<CropModel> crop = <CropModel>[].obs;

  var selectedInventoryType = Rxn<int>();
  var selectedInventoryCategory = Rxn<int>();
  var selectedInventoryItem = Rxn<int>();
  var quantity = ''.obs;
  var description = ''.obs;
  var documents = <Document>[].obs;

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

  void setCrop(int cropId) {
    selectedCrop.value = cropId;
  }

  void setInventoryType(int typeId) {
    selectedInventoryType.value = typeId;
    selectedInventoryCategory.value = null;
    selectedInventoryItem.value = null;
  }

  void setInventoryCategory(int categoryId) {
    selectedInventoryCategory.value = categoryId;
    selectedInventoryItem.value = null;
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
    final farmerId = _appDataController.userId;
    try {
      isTypeLoading(true);
      final response = await _httpService.get('/purchase_list/$farmerId/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        inventoryTypes.clear();

        data.forEach((key, value) {
          if (key != 'language' && value is Map<String, dynamic>) {
            inventoryTypes.add(InventoryTypeModel.fromJson(key, value));
          }
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch inventory types');
    } finally {
      isTypeLoading(false);
    }
  }

  Future<void> getCropList() async {
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.get(
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
      final response = await _httpService.get(
        '/get_inventory_category/$inventoryTypeId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        inventoryCategories.value = data
            .map((json) => InventoryCategoryModel.fromJson(json))
            .toList();
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
      final response = await _httpService.get(
        '/get_inventory_items/$inventoryCategoryId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        inventoryItems.value = data
            .map((json) => InventoryItemModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch inventory items');
    } finally {
      isinventoryLoading(false);
    }
  }

  Future<void> fetchDocumentTypes() async {
    try {
      isdocumentTypesLoading(true);
      // Replace with your actual document types endpoint
      final response = await _httpService.get('/document_categories');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        documentTypes.value = data
            .map((json) => DocumentTypeModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch document types');
    } finally {
      isdocumentTypesLoading(false);
    }
  }

  Future<bool> submitConsumption() async {
    if (selectedInventoryType.value == null ||
        selectedInventoryCategory.value == null ||
        selectedInventoryItem.value == null ||
        quantity.value.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all required fields');
      return false;
    }

    final String farmerId = _appDataController.userId.value;
    try {
      isLoading(true);
      final consumption = FuelConsumptionModel(
        dateOfConsumption: selectedDate.value.toIso8601String().split('T')[0],
        crop: selectedCropType.value.id,
        inventoryType: selectedInventoryType.value!,
        inventoryCategory: selectedInventoryCategory.value!,
        inventoryItems: selectedInventoryItem.value!,
        description: description.value,
        farmer: farmerId,
        quantityUtilized: double.parse(quantity.value),
        documents: documents,
      );

      var json = consumption.toJson();
      final response = await _httpService.post('/create_consumption/', json);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(msg: 'Consumption recorded successfully');
        clearForm();
        return true;
      } else {
        Fluttertoast.showToast(msg: 'Failed to record consumption');
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
    selectedCrop.value = null;
    selectedInventoryType.value = null;
    selectedInventoryCategory.value = null;
    selectedInventoryItem.value = null;
    quantity.value = '';
    description.value = '';
    documents.clear();
  }

  bool get isFormValid {
    return selectedCrop.value != null &&
        selectedInventoryType.value != null &&
        selectedInventoryCategory.value != null &&
        selectedInventoryItem.value != null &&
        quantity.value.isNotEmpty;
  }
}
