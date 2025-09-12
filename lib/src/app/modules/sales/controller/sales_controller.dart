import 'dart:async';
import 'dart:io';

import 'package:argiot/src/app/modules/sales/model/deduction.dart';
import 'package:argiot/src/app/modules/sales/model/dropdown_item.dart';
import 'package:argiot/src/app/modules/sales/model/sales_by_date.dart';
import 'package:argiot/src/app/modules/sales/model/sales_detail_response.dart';
import 'package:argiot/src/app/modules/task/model/crop_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../service/utils/utils.dart';
import '../repostory/sales_repository.dart';

class SalesController extends GetxController {
  final SalesRepository _repository = Get.find();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isAdding = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;

  // Data
  final RxList<SalesByDate> salesList = <SalesByDate>[].obs;
  final Rxn<SalesDetailResponse> salesDetail = Rxn<SalesDetailResponse>();
  final RxList<DropdownItem> reasons = <DropdownItem>[].obs;
  final RxList<DropdownItem> rupees = <DropdownItem>[].obs;
  final RxInt totalSalesAmount = 0.obs;
  final selectedPeriod = 'month'.obs;
  // Form fields
  final RxString selectedDate = ''.obs;
  final RxInt selectedCropId = 0.obs;
  final RxString selectedCropName = ''.obs;
  final RxInt selectedCustomerId = 0.obs;
  final RxString selectedCustomerName = ''.obs;
  final RxInt selectedUnitId = 0.obs;
  final RxString selectedUnitName = ''.obs;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController amountPerUnitController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController deductionAmountController =
      TextEditingController();
  final TextEditingController netAmountController = TextEditingController();
  final TextEditingController paidAmountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Deductions
  final RxList<Deduction> deductions = <Deduction>[].obs;
  final RxList<Map<String, dynamic>> newDeductions =
      <Map<String, dynamic>>[].obs;

  // Documents
  final RxList<File> documentFiles = <File>[].obs;
  final RxList<Map<String, dynamic>> newDocuments =
      <Map<String, dynamic>>[].obs;

  // Dropdowns
  final RxList<DropdownItem> crops = <DropdownItem>[].obs;
  final RxList<DropdownItem> customers = <DropdownItem>[].obs;
  final RxList<DropdownItem> units = <DropdownItem>[].obs;
  var crop = <CropModel>[].obs;
  RxInt cropId = 0.obs;
  var selectedCropType = CropModel(id: 0, name: '').obs;
  void changeCrop(CropModel crop) {
    selectedCropType.value = crop;
    fetchSalesList();
  }

  // Other
  // final RxInt farmerId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    cropId.value = Get.arguments?['crop_id'] ?? 0;
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      // await Future.wait([
      await fetechCrop();
      await fetchSalesList();
      fetchReasons();
      fetchRupees();
      // ]);
    } catch (e) {
      showError('Failed to load initial data');
    } finally {}
  }

  Future fetechCrop() async {
    isLoading.value = true;
    final croplist = await _repository.getCropList();
    crop.assignAll(croplist);
    if (croplist.isNotEmpty) {
      if (cropId.value != 0) {
        selectedCropType.value = croplist.firstWhere(
          (crop) => crop.id == cropId.value,
        );
        // changeCrop( selectedCropType.value);
      } else {
        selectedCropType.value = croplist.first;
      }
    }
    isLoading.value = false;
    return;
  }

  Future fetchSalesList() async {
    isLoading.value = true;
    totalSalesAmount.value = 0;
    try {
      final response = await _repository.getSalesList(
        cropId: selectedCropType.value.id,
        type: selectedPeriod.value,
      );
      totalSalesAmount.value = response.totalSalesAmount.toInt();
      salesList.assignAll(response.salesByDate);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      showError('Failed to fetch sales list');
      rethrow;
    }
  }

  Future<void> fetchSalesDetails(int salesId) async {
    isLoading.value = true;
    try {
      final response = await _repository.getSalesDetails(salesId: salesId);
      salesDetail.value = response;
    } catch (e) {
      showError('Failed to fetch sales details');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReasons() async {
    try {
      final response = await _repository.getReasons();
      reasons.assignAll(response);
    } catch (e) {
      showError('Failed to fetch reasons');
      rethrow;
    }
  }

  void changePeriod(String? period) {
    if (period != null) {
      selectedPeriod(period);
      fetchSalesList();
    }
  }

  Future<void> fetchRupees() async {
    try {
      final response = await _repository.getRupees();
      rupees.assignAll(response);
    } catch (e) {
      showError('Failed to fetch rupee types');
      rethrow;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate.value = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> pickDocument() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        documentFiles.add(File(pickedFile.path));
      }
    } catch (e) {
      showError('Failed to pick document');
    }
  }

  void calculateTotalAmount() {
    if (quantityController.text.isNotEmpty &&
        amountPerUnitController.text.isNotEmpty) {
      final quantity = int.tryParse(quantityController.text) ?? 0;
      final amountPerUnit =
          double.tryParse(amountPerUnitController.text) ?? 0.0;
      final totalAmount = quantity * amountPerUnit;
      totalAmountController.text = totalAmount.toStringAsFixed(2);
      calculateNetAmount();
    }
  }

  void calculateDeductionAmount() {
    double totalDeduction = 0.0;
    for (final deduction in deductions) {
      final amount = double.tryParse(deduction.charges) ?? 0.0;
      totalDeduction += amount;
    }
    deductionAmountController.text = totalDeduction.toStringAsFixed(2);
    calculateNetAmount();
  }

  void calculateNetAmount() {
    final totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
    final totalDeduction =
        double.tryParse(deductionAmountController.text) ?? 0.0;
    final netAmount = totalAmount - totalDeduction;
    netAmountController.text = netAmount.toStringAsFixed(2);
  }

  void addDeduction({
    int? reasonId,
    String? newReason,
    required String charges,
    required int rupeeId,
  }) {
    final deduction = {
      if (reasonId != null) 'reason': reasonId,
      if (newReason != null) 'new_reason': newReason,
      'charges': charges,
      'rupee': rupeeId,
    };
    newDeductions.add(deduction);
    calculateDeductionAmount();
  }

  void removeDeduction(int index) {
    newDeductions.removeAt(index);
    calculateDeductionAmount();
  }

  void addDocument({
    int? fileTypeId,
    String? newFileType,
    required List<String> documents,
  }) {
    final document = {
      if (fileTypeId != null) 'file_type': fileTypeId,
      if (newFileType != null) 'new_file_type': newFileType,
      'documents': documents,
    };
    newDocuments.add(document);
  }

  void removeDocument(int index) {
    newDocuments.removeAt(index);
  }

  Future<void> deleteSales(int salesId) async {
    isDeleting.value = true;
    try {
      await _repository.deleteSales(salesId: salesId);

      // 🔄 Remove the sale from the grouped list
      for (var i = 0; i < salesList.length; i++) {
        final group = salesList[i];
        group.sales.removeWhere((sale) => sale.salesId == salesId);

        // 🧹 If the group is empty after removal, remove the entire group
        if (group.sales.isEmpty) {
          salesList.removeAt(i);
          break;
        }
      }

      Get.back();
      showSuccess('Sales deleted successfully');
    } catch (e) {
      showError('Failed to delete sales');
      rethrow;
    } finally {
      isDeleting.value = false;
    }
  }

  void resetForm() {
    selectedDate.value = '';
    selectedCropId.value = 0;
    selectedCropName.value = '';
    selectedCustomerId.value = 0;
    selectedCustomerName.value = '';
    selectedUnitId.value = 0;
    selectedUnitName.value = '';
    quantityController.clear();
    amountPerUnitController.clear();
    totalAmountController.clear();
    deductionAmountController.clear();
    netAmountController.clear();
    paidAmountController.clear();
    descriptionController.clear();
    deductions.clear();
    newDeductions.clear();
    documentFiles.clear();
    newDocuments.clear();
  }

  void initEditForm(SalesDetailResponse detail) {
    resetForm();
    selectedDate.value = detail.datesOfSales;
    selectedCropId.value = detail.myCrop.id;
    selectedCropName.value = detail.myCrop.name;
    selectedCustomerId.value = detail.myCustomer.id;
    selectedCustomerName.value = detail.myCustomer.name;
    selectedUnitId.value = detail.salesUnit.id;
    selectedUnitName.value = detail.salesUnit.name;
    quantityController.text = detail.salesQuantity.toString();
    amountPerUnitController.text = detail.quantityAmount;
    totalAmountController.text = detail.totalAmount;
    deductionAmountController.text = detail.deductionAmount;
    netAmountController.text = detail.totalSalesAmount.toString();
    paidAmountController.text = detail.amountPaid.toString();
    descriptionController.text = detail.description ?? '';
    deductions.assignAll(detail.deductions);
  }
}
