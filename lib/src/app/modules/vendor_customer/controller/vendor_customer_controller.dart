import 'package:argiot/src/app/modules/vendor_customer/model/market.dart';
import 'package:argiot/src/app/modules/vendor_customer/model/vendor_customer.dart';
import 'package:argiot/src/app/modules/vendor_customer/model/vendor_customer_form_data.dart';

import 'package:argiot/src/app/modules/vendor_customer/repository/vendor_customer_repository.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../inventory/model/inventory_item.dart';

class VendorCustomerController extends GetxController {
  final VendorCustomerRepository _repository = VendorCustomerRepository();
  // final AddressService _addressService = Get.find();
  final RxInt selectedFilter = 0.obs;
  final RxList<VendorCustomer?> vendorCustomerList = <VendorCustomer>[].obs;
  final RxBool isLoading = false.obs;
  // Should be set from auth or previous screen

  // Form controllers
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final shopNameController = TextEditingController();
  final doorNoController = TextEditingController();
  final pincodeController = TextEditingController();
  final gstNoController = TextEditingController();
  final taxNoController = TextEditingController();
  final openingBalanceController = TextEditingController();
  final descriptionController = TextEditingController();
  RxBool isCredit = true.obs;
  final RxString selectedType = 'customer'.obs;
  final RxString? selectedInventoryType = ''.obs;
  final RxString imagePath = ''.obs;
  final RxString imageBase64 = ''.obs;

  // Location dropdowns

  // Dropdown data
  // final RxList<CountryModel> countries = <CountryModel>[].obs;
  // final RxList<StateModel> states = <StateModel>[].obs;
  // final RxList<CityModel> cities = <CityModel>[].obs;
  // final RxList<TalukModel> taluks = <TalukModel>[].obs;
  // final RxList<VillageModel> villages = <VillageModel>[].obs;

  // Loading states
  final markets = <Market>[].obs;
  final selectedMarket = Rxn<Market>();
  final isMARKETLoading = false.obs;
  final searchController = TextEditingController();
  final RxBool isSubmitting = false.obs;

  final RxBool isImageUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    var type = Get.arguments?["type"];
    if (type != null) {
      selectedType.value = type;
    }
    fetchVendorCustomerList();
    loadPurchaseList();
    loadMarkets();
  }

  Future<void> deleteDetails(int id, String type) async {
    try {
      isLoading(true);

      final result = await _repository.daleteDetails(id, type);
      await fetchVendorCustomerList();
      Get.back();
      showSuccess(result["message"]);
    } catch (e) {
      showError('Failed to deleted details');
    } finally {
      isLoading(false);
    }
  }

  //inventory
  Rxn<List<InventoryType>> purchaseModel = Rxn<List<InventoryType>>();
  RxSet<String> selectedKeys = <String>{}.obs;
  RxBool isinveroryLoading = false.obs;

  Future<void> loadPurchaseList() async {
    try {
      isinveroryLoading.value = true;
      final result = await _repository.getInventory();
      purchaseModel.value = result;
    } catch (e) {
      print('Error loading purchase list: $e');
    } finally {
      isinveroryLoading.value = false;
    }
  }

  void toggleSelection(String key) {
    if (selectedKeys.contains(key)) {
      selectedKeys.remove(key);
    } else {
      selectedKeys.add(key);
    }
  }

  void setSelectedKeys(Set<String> keys) {
    selectedKeys.assignAll(keys);
  }

  ////inventory end
  //Market

  Future<void> loadMarkets() async {
    try {
      isLoading(true);
      final marketList = await _repository.getMarkets();
      markets.assignAll(marketList);
    } catch (e) {
      showError(e.toString());
    } finally {
      isLoading(false);
    }
  }

  List<Market> get filteredMarkets {
    if (searchController.text.isEmpty) {
      return markets;
    }
    return markets
        .where(
          (market) => market.name.toLowerCase().contains(
            searchController.text.toLowerCase(),
          ),
        )
        .toList();
  }

  void showError(String message) {
    showError(message);
  }

  //Market end

  Future<void> fetchVendorCustomerList() async {
    try {
      isLoading.value = true;
      vendorCustomerList.clear();
      final response = await _repository.getVendorCustomerList(
        selectedFilter.value,
      );

      if (response.isNotEmpty) {
        // Properly convert each item in the list to VendorCustomer
        vendorCustomerList.assignAll(
          response
              .map<VendorCustomer>((item) => VendorCustomer.fromJson(item))
              .toList(),
        );
      }
    } catch (e) {
      showError('Failed to fetch list');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        isImageUploading.value = true;
        imagePath.value = pickedFile.path;
      }
    } catch (e) {
      showError('Failed to pick image');
    } finally {
      isImageUploading.value = false;
    }
  }

  Future<void> submitForm({int? id}) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting.value = true;

      final formData = VendorCustomerFormData(
        id: id,
        type: selectedType.value,
        customerName: selectedType.value == 'customer'
            ? nameController.text
            : null,
        vendorName: selectedType.value == 'vendor' ? nameController.text : null,
        shopName: shopNameController.text,
        businessName: selectedType.value == 'vendor'
            ? shopNameController.text
            : null,
        mobileNo: mobileController.text,
        email: emailController.text,
        doorNo: doorNoController.text,
        gstNo: gstNoController.text,
        taxNo: taxNoController.text,
        postCode: int.tryParse(pincodeController.text) ?? 0,
        isCredit: isCredit.value,
        openingBalance: double.tryParse(openingBalanceController.text) ?? 0,
        description: descriptionController.text,
        marketIds: selectedMarket.value?.id != null
            ? [selectedMarket.value!.id]
            : [],
        inventoryTypeIds: selectedType.value == 'vendor'
            ? [
                ...purchaseModel.value!
                    .where((inventory) => selectedKeys.contains(inventory.name))
                    .map((inventory) => inventory.id),
              ]
            : null,
      );
      int newId = 0;
      if (id != null) {
        if (selectedType.value == 'customer') {
          newId = await _repository.editCustomer(formData);
        } else if (selectedType.value == 'vendor') {
          newId = await _repository.editVendor(formData);
        } else {
          newId = await _repository.editBoth(formData);
        }
      } else {
        if (selectedType.value == 'customer') {
          newId = await _repository.addCustomer(formData);
        } else if (selectedType.value == 'vendor') {
          newId = await _repository.addVendor(formData);
        } else {
          newId = await _repository.addBoth(formData);
        }
      }

      if (newId > 0) {
        Get.back();
        fetchVendorCustomerList();
        showSuccess('Added successfully');
      }
    } catch (e) {
      showError('Failed to submit');
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    formKey.currentState?.reset();
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    shopNameController.clear();
    doorNoController.clear();
    pincodeController.clear();
    gstNoController.clear();
    taxNoController.clear();
    openingBalanceController.clear();
    descriptionController.clear();
    imagePath.value = '';
    imageBase64.value = '';
  }

  // @override
  // void onClose() {
  //   nameController.dispose();
  //   mobileController.dispose();
  //   emailController.dispose();
  //   shopNameController.dispose();
  //   doorNoController.dispose();
  //   pincodeController.dispose();
  //   gstNoController.dispose();
  //   taxNoController.dispose();
  //   openingBalanceController.dispose();
  //   descriptionController.dispose();
  //   searchController.dispose();
  //   super.onClose();
  // }
}
