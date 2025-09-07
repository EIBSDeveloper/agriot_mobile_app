import 'dart:convert';

import 'package:argiot/consumption_model.dart';
import 'package:argiot/src/app/modules/expense/model/customer.dart';
import 'package:argiot/src/app/modules/expense/model/fertilizer_model.dart';
import 'package:argiot/src/app/modules/expense/model/fuel_entry_model.dart';
import 'package:argiot/src/app/modules/expense/model/machinery.dart';
import 'package:argiot/src/app/modules/expense/model/vehicle_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../doc.dart';
import '../../../../utils.dart';
import '../../../widgets/input_card_style.dart';

import '../../sales/model/model.dart';
import '../../task/view/screens/screen.dart';
import '../fuel.dart/purchases_add_repository.dart';

class PurchasesAddController extends GetxController {
  final PurchasesAddRepository _repository = PurchasesAddRepository();

  // Form fields
  var selectedInventoryType = Rxn<int>();
  var selectedInventoryCategory = Rxn<int>();
  var selectedInventoryItem = Rxn<int>();
  final RxString selectedDate = ''.obs;
  final RxString selectedType = ''.obs;
  final RxList<AddDocumentModel> documentItems = <AddDocumentModel>[].obs;

  final RxString purchaseAmount = ''.obs;
  final RxString paidAmount = ''.obs;
  final RxString litre = ''.obs;
  final RxString description = ''.obs;
  final RxList<String> documents = <String>[].obs;
  // var inventoryTypes = <InventoryTypeModel>[].obs;
  var inventoryCategories = <InventoryCategoryModel>[].obs;
  var inventoryItems = <InventoryItemModel>[].obs;
  final machineryType = 'Fuel'.obs;
  final fuelCapacityController = TextEditingController();
  // final purchaseAmountController = TextEditingController();
  final warrantyStartDateController = TextEditingController();
  final warrantyEndDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final regNoController = TextEditingController();
  final ownerNameController = TextEditingController();
  final dateOfRegController = TextEditingController();
  final regValidTillController = TextEditingController();
  final engineNoController = TextEditingController();
  final chasisNoController = TextEditingController();
  final runningKmController = TextEditingController();
  final serviceFrequencyController = TextEditingController();
  final averageMileageController = TextEditingController();
  final companyNameController = TextEditingController();
  final insuranceNoController = TextEditingController();
  final insuranceAmountController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final renewalDateController = TextEditingController();
  // Observables
  final showInsuranceDetails = false.obs;
  final serviceFrequencyUnit = 'KM'.obs;
  var vendorList = <Customer>[].obs;
  var selectedVendor = Rx<int?>(null);
  // Validation observables

  final formKey = GlobalKey<FormState>();
  // UI state
  final RxBool isLoading = false.obs;
  final RxBool isFormValid = false.obs;
  final RxBool isTypeLoading = false.obs;
  final RxBool isCategoryLoading = false.obs;
  final RxBool isInventoryLoading = false.obs;
  final RxList<Unit> unit = <Unit>[].obs;
  final Rx<Unit> selectedUnit = Unit(id: 0, name: '').obs;

  final isFuelCapacityVisible = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  final errors = <String, String>{}.obs;
  @override
  void onInit() {
    super.onInit();

    var arguments = Get.arguments;
    // if (arguments?["type"] != null) {
    //   inventoryType.value = arguments?["type"];
    // }
    // if (arguments?["category"] != null) {
    //   // inventoryCategory.value = arguments?["category"];
    // }
    // if (arguments?["item"] != null) {
    //   inventoryItem.value = arguments?["item"];
    // }
    selectedType.value = getType(arguments['id']);
    final DateTime picked = DateTime.now();
    selectedDate.value =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    fetchVendorList();
    fetchUnit();
    setInventoryType(arguments['id']);
    fetchInventoryCategories(arguments['id']);
  }

  bool get requiresUnit {
    final typeId = selectedInventoryType.value;
    return typeId == 4 || typeId == 5 || typeId == 7;
  }

  Future<void> submitForm() async {
    // if (!isFormValid.value) return;
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;

    try {
      final fuelEntry = FuelEntryModel(
        dateOfConsumption: selectedDate.value,
        vendor: selectedVendor.value ?? 0,
        inventoryType: selectedInventoryType
            .value!, // Assuming fixed value based on API example
        inventoryCategory: selectedInventoryCategory
            .value!, // Assuming fixed value based on API example
        inventoryItems: selectedInventoryItem
            .value!, // Assuming fixed value based on API example
        quantity: litre.value,
        purchaseAmount: purchaseAmount.value,
        paidAmount: paidAmount.value,
        description: description.value.isNotEmpty ? description.value : null,
      );

      final response = await _repository.addFuelEntry(fuelEntry);

      if (response['success'] == true) {
        Get.back(result: true);
        Get.toNamed(
          '/consumption-purchase',
          arguments: {"id": fuelEntry.inventoryType, 'tab': 1},
          preventDuplicates: true,
        );
        Fluttertoast.showToast(msg: 'fuel_added_success'.tr);
      } else {
        Fluttertoast.showToast(msg: response['message'] ?? 'error_occurred'.tr);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'network_error'.tr);
    } finally {
      isLoading.value = false;
    }
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

  Future<void> fetchVendorList() async {
    try {
      final response = await _repository.getVendorList();
      vendorList.assignAll(response);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to fetch customers: $e');
    }
  }

  Future<void> fetchInventoryCategories(int inventoryTypeId) async {
    try {
      isCategoryLoading(true);
      final response = await _repository.fetchInventoryCategories(
        inventoryTypeId,
      );
      inventoryCategories.value = response;
      if (inventoryCategories.isNotEmpty) {
        selectedInventoryCategory.value = inventoryCategories.first.id;
        inventoryCategory(inventoryCategories.first.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch inventory categories');
    } finally {
      isCategoryLoading(false);
    }
  }

  Future<void> fetchInventoryItems(int inventoryCategoryId) async {
    try {
      isInventoryLoading(true);
      final response = await _repository.fetchInventoryItems(
        inventoryCategoryId,
      );

      inventoryItems.value = response;
    } finally {
      isInventoryLoading(false);
    }
  }

  Future<void> submitMachineryForm() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;

    try {
      final machinery = Machinery(
        dateOfConsumption: selectedDate.value,
        vendor: selectedVendor.value!,
        inventoryType:
            selectedInventoryType.value!, // Map to your actual values
        inventoryCategory: selectedInventoryCategory.value!,
        inventoryItems: selectedInventoryItem.value!,
        machineryType: machineryType.value == 'Fuel' ? '1' : '2',
        fuelCapacity: int.tryParse(fuelCapacityController.text) ?? 0,
        warrantyStartDate: warrantyStartDateController.text,
        warrantyEndDate: warrantyEndDateController.text,
        purchaseAmount: purchaseAmount.value,
        paidAmount: paidAmount.value,
        description: descriptionController.text,
        // documents: documents,
      );

      final response = await _repository.addMachinery(machinery);

      if (response['success'] == true) {
        Get.back(result: true);
        Get.toNamed(
          '/consumption-purchase',
          arguments: {"id": selectedInventoryType.value, 'tab': 1},
          preventDuplicates: true,
        );
        Fluttertoast.showToast(msg: 'Machinery added successfully!'.tr);
      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? 'Failed to add machinery'.tr,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Network error: ${e.toString()}'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    selectedDate.value = '';
    selectedVendor.value = 0;
    purchaseAmount.value = '';
    litre.value = '';
    description.value = '';
    documents.clear();
    fieldErrors.clear();
  }

  String? getErrorForField(String fieldName) => fieldErrors[fieldName];

  Future<void> selectDate1() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDate.value =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> selectDate(
    TextEditingController controller,
    BuildContext context,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty
          ? DateTime.parse(controller.text)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  //vehicle start
  void toggleInsuranceDetails(bool? value) {
    showInsuranceDetails.value = value ?? false;
  }

  void setServiceFrequencyUnit(String unit) {
    serviceFrequencyUnit.value = unit;
  }

  // Validation methods
  String? validateRequired(String value, String fieldName) {
    if (value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateNumeric(String value, String fieldName) {
    if (value.isNotEmpty) {
      final numericValue = double.tryParse(value);
      if (numericValue == null) {
        return '$fieldName must be a number';
      }
      if (numericValue <= 0) {
        return '$fieldName must be greater than 0';
      }
    }
    return null;
  }

  Future<void> submitVehicleForm() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;

    try {
      final vehicle = VehicleModel(
        farmerId: 1,
        dateOfConsumption: DateTime.parse(selectedDate.value),
        vendor: selectedVendor.value ?? 0,
        inventoryType: 1, // Assuming default value
        inventoryCategory: selectedInventoryCategory.value ?? 0,
        inventoryItems: selectedInventoryItem.value ?? 0,
        registerNumber: regNoController.text,
        paidAmount: paidAmount.value,
        ownerName: ownerNameController.text,
        dateOfRegistration: dateOfRegController.text.isNotEmpty
            ? DateTime.parse(dateOfRegController.text)
            : null,
        registrationValidTill: regValidTillController.text.isNotEmpty
            ? DateTime.parse(regValidTillController.text)
            : null,
        engineNumber: engineNoController.text.isNotEmpty
            ? engineNoController.text
            : null,
        chasisNumber: chasisNoController.text.isNotEmpty
            ? chasisNoController.text
            : null,
        runningKilometer: double.tryParse(runningKmController.text) ?? 0,
        serviceFrequency: serviceFrequencyController.text.isNotEmpty
            ? int.parse(serviceFrequencyController.text)
            : 0,
        serviceFrequencyUnit: serviceFrequencyUnit.value == 'KM' ? 0 : 1,
        fuelCapacity: fuelCapacityController.text.isNotEmpty
            ? double.parse(fuelCapacityController.text)
            : 0,
        averageMileage: averageMileageController.text.isNotEmpty
            ? double.parse(averageMileageController.text)
            : 0,
        purchaseAmount: double.parse(purchaseAmount.value),
        insurance: showInsuranceDetails.value,
        companyName: showInsuranceDetails.value
            ? companyNameController.text
            : '',
        insuranceNo: showInsuranceDetails.value
            ? insuranceNoController.text
            : null,
        insuranceAmount:
            showInsuranceDetails.value &&
                insuranceAmountController.text.isNotEmpty
            ? double.parse(insuranceAmountController.text)
            : null,
        insuranceStartDate:
            showInsuranceDetails.value && startDateController.text.isNotEmpty
            ? DateTime.parse(startDateController.text)
            : null,
        insuranceEndDate:
            showInsuranceDetails.value && endDateController.text.isNotEmpty
            ? DateTime.parse(endDateController.text)
            : null,
        insuranceRenewalDate:
            showInsuranceDetails.value && renewalDateController.text.isNotEmpty
            ? DateTime.parse(renewalDateController.text)
            : null,
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        documents: null, // You would need to handle file uploads separately
      );

      final response = await _repository.addVehicle(vehicle);

      var status = json.decode(response);
      if (status['success']) {
        Get.back();
        Get.toNamed(
          '/consumption-purchase',
          arguments: {"id": selectedInventoryType.value, 'tab': 1},
          preventDuplicates: true,
        );
        Fluttertoast.showToast(
          msg: "Vehicle added successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Get.back(result: true);
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? "Failed to add vehicle",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitFertilizerForm() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final fertilizer = FertilizerModel(
        dateOfConsumption: selectedDate.value,
        vendor: selectedVendor.value!,
        inventoryType: selectedInventoryType.value!,
        inventoryCategory: selectedInventoryCategory.value!,

        inventoryItems: selectedInventoryItem.value!,
        quantity: litre.value,
        quantityUnit: selectedUnit.value.id,
        paidAmount: paidAmount.value,
        purchaseAmount: purchaseAmount.value,
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
      );

      final response = await _repository.addFertilizer(fertilizer);

      if (response.success) {
        Get.back(result: true);

        Get.toNamed(
          '/consumption-purchase',
          arguments: {"id": selectedInventoryType.value, 'tab': 1},
          preventDuplicates: true,
        );
        Fluttertoast.showToast(
          msg: 'fertilizer_add_success'.tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      } else {
        Fluttertoast.showToast(
          msg: response.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'fertilizer_add_failed'.tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    } finally {
      isLoading.value = false;
    }
  }

  //

  //common start
  Widget buildLitreField() => Obx(
      () => Row(
        children: [
          Expanded(
            child: InputCardStyle(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: selectedInventoryType.value == 6
                      ? 'litre'.tr
                      : 'quantity'.tr,
                  border: InputBorder.none,
                  // errorText: getErrorForField('litre'),
                ),
                keyboardType: TextInputType.number,
                initialValue: litre.value,
                validator: (value) =>
                    value!.isEmpty ? 'required_field'.tr : null,
                onChanged: litre.call,
              ),
            ),
          ),

          if (requiresUnit) ...[
            const SizedBox(width: 10),
            Expanded(child: buildUnitDropdown()),
          ],
        ],
      ),
    );

  Widget buildUnitDropdown() => Obx(() => MyDropdown(
        items: unit,
        selectedItem: selectedUnit.value,
        onChanged: (unit) => changeUnit(unit!),
        label: 'Unit*',
        // disable: isEditing,
      ));

  Future<void> fetchUnit() async {
    final unitList = await _repository.getUnitList();
    unit.assignAll(unitList);

    if (unitList.isNotEmpty) {
      selectedUnit.value = unitList.first;
    }
  }

  void changeUnit(Unit crop) {
    selectedUnit.value = crop;
  }

  Widget buildPurchaseAmountField() => Obx(() => InputCardStyle(
        child: TextFormField(
          validator: (value) => value!.isEmpty ? 'required_field'.tr : null,
          decoration: InputDecoration(
            hintText: 'purchase_amount'.tr,
            border: InputBorder.none,
            // errorText: ,
          ),
          keyboardType: TextInputType.number,
          onChanged: purchaseAmount.call,
          initialValue: purchaseAmount.value,
        ),
      ));

  Widget buildPaidAmountField() => Obx(() => InputCardStyle(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: 'paid_amount'.tr,
            border: InputBorder.none,
            // errorText: ,
          ),
          validator: (value) => value!.isEmpty ? 'required_field'.tr : null,
          initialValue: paidAmount.value,
          keyboardType: TextInputType.number,
          onChanged: paidAmount.call,
        ),
      ));

  void addDocumentItem() {
    Get.to(
      const AddDocumentView(),
      binding: NewDocumentBinding(),
      arguments: {"id": 0},
    )?.then((result) {
      if (result != null && result is AddDocumentModel) {
        documentItems.add(result);
      }
      // print(documentItems.toString());
    });
  }

  void removeDocumentItem(int index) {
    documentItems.removeAt(index);
  }

  Widget buildDocumentsSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Land Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Card(
              color: Get.theme.primaryColor,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.add),
                onPressed: addDocumentItem,
                tooltip: 'Add Document',
              ),
            ),
          ],
        ),
        Obx(() {
          if (documentItems.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No documents added',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: documentItems.length,
            itemBuilder: (context, index) => Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "${index + 1}, ${documentItems[index].newFileType!}",
                      ),
                      const Icon(Icons.attach_file),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
          );
        }),
      ],
    );

  Widget buildDescriptionField() => InputCardStyle(
      noHeight: true,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'description'.tr,
          border: InputBorder.none,

          // counterText: '${description.value.length}/250',
        ),
        // maxLength: 250,
        initialValue: description.value,
        maxLines: 3,
        onChanged: description.call,
      ),
    );

  Widget buildDateField() => Obx(
      () => Column(
        children: [
          InputCardStyle(
            child: InkWell(
              onTap: () => selectDate1(),
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: 'date'.tr,
                  border: InputBorder.none,
                  // errorText: getErrorForField('date'),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate.isNotEmpty
                          ? selectedDate.value
                          : 'select_date'.tr,
                      style: Get.theme.textTheme.bodyLarge,
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

  Widget buildInventoryCategoryDropdown() => Obx(
      () => Column(
        children: [
          InputCardStyle(
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                hintText: 'Inventory Category'.tr,
                border: InputBorder.none,
              ),
              
                icon: const Icon(Icons.keyboard_arrow_down),
              initialValue: selectedInventoryCategory.value,
              items: inventoryCategories
                  .map(
                    (category) => DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                inventoryCategory(value);
              },
            ),
          ),
          //  ErrorText(error: getErrorForField('vendor')),
        ],
      ),
    );

  void inventoryCategory(int? value) {
    setInventoryCategory(value!);
    fetchInventoryItems(value);
  }

  Widget buildInventoryItemDropdown() => Obx(
      () => InputCardStyle(
        child: DropdownButtonFormField<int>(
          validator: (value) => value == null ? 'required_field'.tr : null,
          decoration: InputDecoration(
            hintText: 'Inventory Item'.tr,
            border: InputBorder.none,
          ),
          initialValue: selectedInventoryItem.value,

                icon: const Icon(Icons.keyboard_arrow_down),
          items: inventoryItems
              .map(
                (item) => DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(item.name),
                ),
              )
              .toList(),
          onChanged: (value) => selectedInventoryCategory.value != null
              ? setInventoryItem(value!)
              : null,
        ),
      ),
    );

  Widget buildVendorDropdown() => Row(
      children: [
        Expanded(
          child: Obx(() => InputCardStyle(
              child: DropdownButtonFormField<int>(
                validator: (value) =>
                    value == null ? 'required_field'.tr : null,
                decoration: const InputDecoration(
                  hintText: 'Vendor*',
                  border: InputBorder.none,
                ),
                
                icon: const Icon(Icons.keyboard_arrow_down),
                initialValue: selectedVendor.value,
                onChanged: (value) => selectedVendor.value = value,
                items: vendorList.map((customer) => DropdownMenuItem<int>(
                    value: customer.id,
                    child: Text(customer.name),
                  )).toList(),
              ),
            )),
        ),
        Card(
          color: Get.theme.primaryColor,
          child: IconButton(
            color: Colors.white,
            onPressed: () {
              Get.toNamed(
                '/add-vendor-customer',
                arguments: {"type": 'vendor'},
              )?.then((result) {
                fetchVendorList();
              });
            },
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  //common  end

  @override
  void onClose() {
    // dateController.dispose();
    fuelCapacityController.dispose();
    // purchaseAmountController.dispose();
    warrantyStartDateController.dispose();
    warrantyEndDateController.dispose();
    descriptionController.dispose();
    regNoController.dispose();
    ownerNameController.dispose();
    dateOfRegController.dispose();
    regValidTillController.dispose();
    engineNoController.dispose();
    chasisNoController.dispose();
    runningKmController.dispose();
    serviceFrequencyController.dispose();
    averageMileageController.dispose();
    companyNameController.dispose();
    insuranceNoController.dispose();
    insuranceAmountController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    renewalDateController.dispose();
    super.onClose();
  }
}
