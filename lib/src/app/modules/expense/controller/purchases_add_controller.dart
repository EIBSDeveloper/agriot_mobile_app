import 'dart:convert';

import 'package:argiot/src/app/modules/document/model/add_document_model.dart';
import 'package:argiot/src/app/modules/document/binding/document_binding.dart';
import 'package:argiot/src/app/modules/expense/model/customer.dart';
import 'package:argiot/src/app/modules/expense/model/fertilizer_model.dart';
import 'package:argiot/src/app/modules/expense/model/fuel_entry_model.dart';
import 'package:argiot/src/app/modules/expense/model/inventory_category_model.dart';
import 'package:argiot/src/app/modules/expense/model/inventory_item_model.dart';
import 'package:argiot/src/app/modules/expense/model/machinery.dart';
import 'package:argiot/src/app/modules/expense/model/vehicle_model.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../service/utils/enums.dart';
import '../../document/view/add_document_view.dart';
import '../../../service/utils/utils.dart';
import '../../../widgets/input_card_style.dart';

import '../../sales/model/unit.dart';
import '../repostroy/purchases_add_repository.dart';

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
  var inventoryCategories = <InventoryCategoryModel>[].obs;
  var inventoryItems = <InventoryItemModel>[].obs;
  final machineryType = 'Fuel'.obs;
  final fuelCapacityController = TextEditingController();
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
  final Rxn<int> inventoryType = Rxn<int>();
  final Rxn<int> inventoryCategory = Rxn<int>();
  final Rxn<int> inventoryItem = Rxn<int>();
  final isFuelCapacityVisible = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  final errors = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();

    var arguments = Get.arguments;
    if (arguments?["id"] != null) {
      inventoryType.value = arguments?["id"];
    }
    if (arguments?["category"] != null) {
      inventoryCategory.value = arguments?["category"];
    }
    if (arguments?["item"] != null) {
      inventoryItem.value = arguments?["item"];
    }
    selectedType.value = getType(arguments?['id'] ?? "");
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
      showError('Failed to fetch customers: $e');
    }
  }

  Future<void> fetchInventoryCategories(int inventoryTypeId) async {
    try {
      isCategoryLoading(true);
      final response = await _repository.fetchInventoryCategories(
        inventoryTypeId,
      );
      inventoryCategories.value = response;
      if (inventoryCategory.value != null) {
        selectedInventoryCategory.value = inventoryCategory.value;
        inventoryCategoryUpdate(inventoryCategory.value);
      } else if (inventoryCategories.isNotEmpty) {
        selectedInventoryCategory.value = inventoryCategories.first.id;
        inventoryCategoryUpdate(inventoryCategories.first.id);
      }
    } catch (e) {
   showError( 'Failed to fetch inventory categories');
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
      if (inventoryItem.value != null) {
        selectedInventoryItem.value = inventoryItem.value;
      }
    } finally {
      isInventoryLoading(false);
    }
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

  void toggleInsuranceDetails(bool? value) {
    showInsuranceDetails.value = value ?? false;
  }

  void setServiceFrequencyUnit(String unit) {
    serviceFrequencyUnit.value = unit;
  }

  Future<void> fetchUnit() async {
    final unitList = await _repository.getUnitList();
    unit.assignAll(unitList);

    if (unitList.isNotEmpty) {
      selectedUnit.value = unitList.first;
    }
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
      // print(documentItems.toString());
    });
  }

  void removeDocumentItem(int index) {
    documentItems.removeAt(index);
  }

  void changeUnit(Unit crop) {
    selectedUnit.value = crop;
  }

  void inventoryCategoryUpdate(int? value) {
    setInventoryCategory(value!);
    fetchInventoryItems(value);
  }

  //Submit Form

  Future<void> submitFuelForm() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    final documentItemsList = documentItems.map((doc) {
      var json = doc.toJson();
      return json;
    }).toList();
    try {
      final fuelEntry = FuelEntryModel(
        dateOfConsumption: selectedDate.value,
        vendor: selectedVendor.value ?? 0,
        inventoryType: selectedInventoryType.value!,
        inventoryCategory: selectedInventoryCategory.value!,
        inventoryItems: selectedInventoryItem.value!,
        quantity: litre.value,
        purchaseAmount: purchaseAmount.value,
        paidAmount: paidAmount.value,
        description: description.value.isNotEmpty ? description.value : null,
        document: documentItemsList,
      );

      final response = await _repository.addFuelEntry(fuelEntry);

      if (response['success'] == true) {
        Get.back(result: true);
        Get.toNamed(
          '/consumption-purchase',
          arguments: {
            "id": fuelEntry.inventoryType,
            'tab': 1,
            "category": selectedInventoryCategory.value,
            "item": selectedInventoryItem.value,
          },
          preventDuplicates: true,
        );
        showSuccess('fuel_added_success'.tr);
      } else {
        showError(response['message'] ?? 'error_occurred'.tr);
      }
    } catch (e) {
      showError('network_error'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitMachineryForm() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    final documentItemsList = documentItems.map((doc) {
      var json = doc.toJson();
      return json;
    }).toList();
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
        documents: documentItemsList,
      );

      final response = await _repository.addMachinery(machinery);

      if (response['success'] == true) {
        Get.back(result: true);
        Get.toNamed(
          '/consumption-purchase',
          arguments: {
            "id": selectedInventoryType.value,
            'tab': 1,
            "category": selectedInventoryCategory.value,
            "item": selectedInventoryItem.value,
          },
          preventDuplicates: true,
        );
        showSuccess( 'Machinery added successfully!'.tr);
      } else {
        showError(response['message'] ?? 'Failed to add machinery'.tr);
      }
    } catch (e) {
      showError('Network error: ${e.toString()}'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitVehicleForm() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    final documentItemsList = documentItems.map((doc) {
      var json = doc.toJson();
      return json;
    }).toList();
    try {
      final vehicle = VehicleModel(
        farmerId: appData.userId.value,
        dateOfConsumption: DateTime.parse(selectedDate.value),
        vendor: selectedVendor.value ?? 0,
        inventoryType: selectedInventoryType.value!, // Assuming default value
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
        documents:
            documentItemsList, // You would need to handle file uploads separately
      );

      final response = await _repository.addVehicle(vehicle);

      var status = json.decode(response);
      if (status['success']) {
        Get.back(result: true);
        Get.toNamed(
          '/consumption-purchase',
          arguments: {
            "id": selectedInventoryType.value,
            'tab': 1,
            "category": selectedInventoryCategory.value,
            "item": selectedInventoryItem.value,
          },
          preventDuplicates: true,
        );
       showSuccess( "Vehicle added successfully!",
        
        );
      } else {
        showError(response.message ?? "Failed to add vehicle");
      }
    } catch (e) {
      showError("Error: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitFertilizerForm() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    final documentItemsList = documentItems.map((doc) {
      var json = doc.toJson();
      return json;
    }).toList();
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
        documents: documentItemsList,
      );

      final response = await _repository.addFertilizer(fertilizer);

      if (response.success) {
        Get.back(result: true);

        Get.toNamed(
          '/consumption-purchase',
          arguments: {
            "id": selectedInventoryType.value,
            'tab': 1,
            "category": selectedInventoryCategory.value,
            "item": selectedInventoryItem.value,
          },
          preventDuplicates: true,
        );
       showError('fertilizer_add_success'.tr,
        
        );
      } else {
        showError( response.message,
          
        );
      }
    } catch (e) {
       showError( 'fertilizer_add_failed'.tr,
       
      );
    } finally {
      isLoading.value = false;
    }
  }

  //Submit Form

  //common Widget
  Widget buildLitreField() => Obx(
    () => Row(
      children: [
        Expanded(
          child: InputCardStyle(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: selectedInventoryType.value == 6
                    ? "${'litre'.tr} *"
                    : "${'quantity'.tr} *",
                border: InputBorder.none,
                // errorText: getErrorForField('litre'),
              ),
              keyboardType: TextInputType.number,
              initialValue: litre.value,
              validator: (value) => value!.isEmpty ? 'required_field'.tr : null,
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

  Widget buildUnitDropdown() => Obx(
    () => MyDropdown(
      items: unit,
      selectedItem: selectedUnit.value,
      onChanged: (unit) => changeUnit(unit!),
      label: 'Unit *',
      // disable: isEditing,
    ),
  );

  Widget buildPurchaseAmountField() => Obx(
    () => InputCardStyle(
      child: TextFormField(
        validator: (value) => value!.isEmpty ? 'required_field'.tr : null,
        decoration: InputDecoration(
          labelText: "${'purchase_amount'.tr} *",
          border: InputBorder.none,
          // errorText: ,
        ),
        keyboardType: TextInputType.number,
        onChanged: purchaseAmount.call,
        initialValue: purchaseAmount.value,
      ),
    ),
  );

  Widget buildPaidAmountField() => Obx(
    () => InputCardStyle(
      child: TextFormField(
        decoration: InputDecoration(
          labelText: "${'paid_amount'.tr} *",
          border: InputBorder.none,
          // errorText: ,
        ),
        validator: (value) => value!.isEmpty ? 'required_field'.tr : null,
        initialValue: paidAmount.value,
        keyboardType: TextInputType.number,
        onChanged: paidAmount.call,
      ),
    ),
  );

  Widget buildDocumentsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Documents',
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
              const SizedBox(height: 5),
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        "${index + 1}, ${documentItems[index].newFileType!}",
                      ),
                      const Icon(Icons.attach_file),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      removeDocumentItem(index);
                    },
                    color: Get.theme.primaryColor,
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Divider(),
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
        labelText: 'description'.tr,
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
                labelText: 'date'.tr,
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
              labelText: "${'Inventory Category'.tr} *",
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
              inventoryCategoryUpdate(value);
            },
          ),
        ),
        //  ErrorText(error: getErrorForField('vendor')),
      ],
    ),
  );

  Widget buildInventoryItemDropdown() => Obx(
    () => InputCardStyle(
      child: DropdownButtonFormField<int>(
        validator: (value) => value == null ? 'required_field'.tr : null,
        decoration: InputDecoration(
          labelText: "${'Inventory Item'.tr} *",
          border: InputBorder.none,
        ),
        initialValue: selectedInventoryItem.value,

        icon: const Icon(Icons.keyboard_arrow_down),
        items: inventoryItems
            .map(
              (item) =>
                  DropdownMenuItem<int>(value: item.id, child: Text(item.name)),
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
        child: Obx(
          () => InputCardStyle(
            child: DropdownButtonFormField<int>(
              validator: (value) => value == null ? 'required_field'.tr : null,
              decoration: const InputDecoration(
                labelText: 'Vendor *',
                border: InputBorder.none,
              ),

              icon: const Icon(Icons.keyboard_arrow_down),
              initialValue: selectedVendor.value,
              onChanged: (value) => selectedVendor.value = value,
              items: vendorList
                  .map(
                    (customer) => DropdownMenuItem<int>(
                      value: customer.id,
                      child: Text(customer.name),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
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
  //common  Widget

  void clearForm() {
    selectedDate.value = '';
    selectedVendor.value = 0;
    purchaseAmount.value = '';
    litre.value = '';
    description.value = '';
    documents.clear();
    fieldErrors.clear();
  }

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
