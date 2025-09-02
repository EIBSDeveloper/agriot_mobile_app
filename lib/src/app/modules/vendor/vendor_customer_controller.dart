import 'package:argiot/item.dart';
import 'package:argiot/src/app/modules/registration/model/address_model.dart';
import 'package:argiot/src/sercis/address_service.dart';
import 'package:argiot/src/app/modules/vendor/vendor_customer_model.dart';
import 'package:argiot/src/app/modules/vendor/vendor_customer_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils.dart';

class VendorCustomerController extends GetxController {
  final VendorCustomerRepository _repository = VendorCustomerRepository();
  final AddressService _addressService = Get.find();
  final RxString selectedFilter = 'both'.obs;
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
  final RxList<CountryModel> countries = <CountryModel>[].obs;
  final RxList<StateModel> states = <StateModel>[].obs;
  final RxList<CityModel> cities = <CityModel>[].obs;
  final RxList<TalukModel> taluks = <TalukModel>[].obs;
  final RxList<VillageModel> villages = <VillageModel>[].obs;

  // final RxList<MarketModel> selectedMarkets = <MarketModel>[].obs;
  // final RxList<InventoryTypeModel> selectedInventoryTypes = <InventoryTypeModel>[].obs;

  // Selected values
  final Rx<CountryModel?> selectedCountry = Rx<CountryModel?>(null);
  final Rx<StateModel?> selectedState = Rx<StateModel?>(null);
  final Rx<CityModel?> selectedCity = Rx<CityModel?>(null);
  final Rx<TalukModel?> selectedTaluk = Rx<TalukModel?>(null);
  final Rx<VillageModel?> selectedVillage = Rx<VillageModel?>(null);

  // Loading states
  final markets = <Market>[].obs;
  final selectedMarket = Rxn<Market>();
  final isMARKETLoading = false.obs;
  final searchController = TextEditingController();
  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingCountries = false.obs;
  final RxBool isLoadingStates = false.obs;
  final RxBool isLoadingCities = false.obs;
  final RxBool isLoadingTaluks = false.obs;
  final RxBool isLoadingVillages = false.obs;

  final RxBool isImageUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    var type= Get.arguments?["type"];
    if(type != null ){
      selectedType.value = type;
    }
    fetchVendorCustomerList();

    loadCountries();
    loadMarkets();
    loadPurchaseList();
    _setupDropdownListeners();
  }

  void _setupDropdownListeners() {
    ever(selectedCountry, (_) => _onCountryChanged());
    ever(selectedState, (_) => _onStateChanged());
    ever(selectedCity, (_) => _onCityChanged());
    ever(selectedTaluk, (_) => _onTalukChanged());
  }

  void _onCountryChanged() {
    selectedState.value = null;
    selectedCity.value = null;
    selectedTaluk.value = null;
    selectedVillage.value = null;

    if (selectedCountry.value != null) {
      loadStates(selectedCountry.value!.id!);
    } else {
      states.clear();
      cities.clear();
      taluks.clear();
      villages.clear();
    }
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

  void _onStateChanged() {
    selectedCity.value = null;
    selectedTaluk.value = null;
    selectedVillage.value = null;

    if (selectedState.value != null) {
      loadCities(selectedState.value!.id!);
    } else {
      cities.clear();
      taluks.clear();
      villages.clear();
    }
  }

  void _onCityChanged() {
    selectedTaluk.value = null;
    selectedVillage.value = null;

    if (selectedCity.value != null) {
      loadTaluks(selectedCity.value!.id!);
    } else {
      taluks.clear();
      villages.clear();
    }
  }

  void _onTalukChanged() {
    selectedVillage.value = null;

    if (selectedTaluk.value != null) {
      loadVillages(selectedTaluk.value!.id!);
    } else {
      villages.clear();
    }
  }

  Future<void> loadCountries() async {
    try {
      isLoadingCountries(true);
      final result = await _addressService.getCountries();
      countries.assignAll(result);
    } catch (e) {
      showError('Failed to load countries');
    } finally {
      isLoadingCountries(false);
    }
  }

  Future<void> loadStates(int countryId) async {
    try {
      isLoadingStates(true);
      final result = await _addressService.getStates(countryId);
      states.assignAll(result);
    } catch (e) {
      showError('Failed to load states');
    } finally {
      isLoadingStates(false);
    }
  }

  Future<void> loadCities(int stateId) async {
    try {
      isLoadingCities(true);
      final result = await _addressService.getCities(stateId);
      cities.assignAll(result);
    } catch (e) {
      showError('Failed to load cities');
    } finally {
      isLoadingCities(false);
    }
  }

  Future<void> loadTaluks(int cityId) async {
    try {
      isLoadingTaluks(true);
      final result = await _addressService.getTaluks(cityId);
      taluks.assignAll(result);
    } catch (e) {
      showError('Failed to load taluks');
    } finally {
      isLoadingTaluks(false);
    }
  }

  Future<void> loadVillages(int talukId) async {
    try {
      isLoadingVillages(true);
      final result = await _addressService.getVillages(talukId);
      villages.assignAll(result);
    } catch (e) {
      showError('Failed to load villages');
    } finally {
      isLoadingVillages(false);
    }
  }
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
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  //Market end

  //inventory
  Rxn<PurchaseModel> purchaseModel = Rxn<PurchaseModel>();
  RxSet<String> selectedKeys = <String>{}.obs;
  RxBool isinveroryLoading = false.obs;

  Future<void> loadPurchaseList() async {
    try {
      isinveroryLoading.value = true;
      final result = await _repository.fetchPurchaseList();
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
    selectedKeys.value = keys;
  }

  ////inventory end

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
        // Convert to base64 (you'll need to implement this)
        // imageBase64.value = await convertImageToBase64(pickedFile.path);
      }
    } catch (e) {
      showError('Failed to pick image');
    } finally {
      isImageUploading.value = false;
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting.value = true;

      final formData = VendorCustomerFormData(
        type: selectedType.value,
        customerName:
            selectedType.value == 'customer' || selectedType.value == 'both'
            ? nameController.text
            : null,
        vendorName: selectedType.value == 'vendor' ? nameController.text : null,
        shopName: shopNameController.text,
        businessName:
            selectedType.value == 'vendor' || selectedType.value == 'both'
            ? shopNameController.text
            : null,
        mobileNo: mobileController.text,
        email: emailController.text,
        doorNo: doorNoController.text,
        countryId: selectedCountry.value?.id??1,
        stateId: selectedState.value?.id??1,
        cityId: selectedCity.value?.id??1,
        talukId: selectedTaluk.value?.id??1,
        villageId: selectedVillage.value?.id??1,
        gstNo: gstNoController.text,
        taxNo: taxNoController.text,
        postCode: int.tryParse(pincodeController.text) ?? 0,
        isCredit: isCredit.value,
        openingBalance: double.tryParse(openingBalanceController.text) ?? 0,
        description: descriptionController.text,
        marketIds: [selectedMarket.value!.id],
        inventoryTypeIds: selectedType.value == 'vendor'||selectedType.value == 'both'
            ? (purchaseModel.value != null)
                  ? selectedKeys
                        .where(
                          (key) => purchaseModel.value!.items.containsKey(key),
                        )
                        .map((key) => purchaseModel.value!.items[key]!.id)
                        .toList()
                  : null
            : null,
        // imageBase64: imageBase64.value,
      );

      int newId;
      if (selectedType.value == 'customer') {
        newId = await _repository.addCustomer(formData);
      } else if (selectedType.value == 'vendor') {
        newId = await _repository.addVendor(formData);
      } else {
        newId = await _repository.addBoth(formData);
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
    selectedCountry.value = null;
    selectedState.value = null;
    selectedCity.value = null;
    selectedTaluk.value = null;
    selectedVillage.value = null;
    // selectedMarkets.clear();
    // selectedInventoryTypes.clear();
    imagePath.value = '';
    imageBase64.value = '';
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    shopNameController.dispose();
    doorNoController.dispose();
    pincodeController.dispose();
    gstNoController.dispose();
    taxNoController.dispose();
    openingBalanceController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
