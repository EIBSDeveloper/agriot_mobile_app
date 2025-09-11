import 'package:argiot/src/app/modules/document/model/add_document_model.dart';
import 'package:argiot/src/app/modules/document/view/add_document_view.dart';
import 'package:argiot/src/app/modules/document/binding/document_binding.dart';
import 'package:argiot/src/app/modules/sales/model/sales_add_request.dart';
import 'package:argiot/src/app/modules/sales/repostory/new_sales_repository.dart';
import 'package:argiot/src/app/modules/sales/model/sales_update_request.dart';
import 'package:argiot/src/app/modules/expense/model/customer.dart';
import 'package:argiot/src/app/modules/sales/model/reason.dart';
import 'package:argiot/src/app/modules/sales/model/rupee.dart';
import 'package:argiot/src/app/modules/sales/model/sales_detail.dart';
import 'package:argiot/src/app/modules/sales/model/unit.dart';
import 'package:argiot/src/app/modules/task/model/crop_model.dart';
import 'package:get/get.dart';

import '../../../service/utils/enums.dart';
import '../../../service/utils/utils.dart';

class NewSalesController extends GetxController {
  final NewSalesRepository _salesRepository = Get.find<NewSalesRepository>();

  // Reactive variables
  var isLoading = false.obs;
  var salesDetail = Rx<SalesDetail?>(null);
  var reasonsList = <Reason>[].obs;
  var rupeesList = <Rupee>[].obs;
  var customerList = <Customer>[].obs;
  final RxList<CropModel> crop = <CropModel>[].obs;
  final RxList<Unit> unit = <Unit>[].obs;
  // Form variables
  final RxList<AddDocumentModel> documentItems = <AddDocumentModel>[].obs;

  final Rx<CropModel> selectedCropType = CropModel(id: 0, name: '').obs;
  final Rx<Reason> selectedReason = Reason(id: 0, name: '').obs;
  final Rx<Unit> selectedUnit = Unit(id: 0, name: '').obs;
  RxBool isNewReason = false.obs;
  var selectedCustomer = Rx<int?>(null);
  Rx<DateTime> selectedDate = DateTime.now().obs;
  var salesQuantity = Rx<int?>(0);
  // var selectedUnit = Rx<int?>(null);
  var quantityAmount = Rx<int>(0);
  var salesAmount = Rx<int>(0);
  var deductionAmount = Rx<int>(0);
  var netAmount = Rx<int>(0);
  var amountPaid = Rx<String>('');
  var description = Rx<String>('');
  var deductions = <Map<String, dynamic>>[].obs;
  var documents = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    var id = Get.arguments?["id"];
    var isNew = Get.arguments?["new"];

    if (isNew != null) {
      await fetchReasons();
      await fetchRupees();
      await fetchCrop();
      await fetchUnit();
      await fetchCustomerList();
    }
    if (id == null) {
      return;
    }
    await fetchSalesDetails(id);
  }

  Future<void> fetchCrop() async {
    final cropList = await _salesRepository.getCropList();
    crop.assignAll(cropList);

    if (cropList.isNotEmpty) {
      selectedCropType.value = cropList.first;
    }
  }

  Future<void> fetchUnit() async {
    final unitList = await _salesRepository.getUnitList();
    unit.assignAll(unitList);

    if (unitList.isNotEmpty) {
      selectedUnit.value = unitList.first;
    }
  }

  Future<void> fetchSalesDetails(int salesId) async {
    try {
      isLoading(true);
      final response = await _salesRepository.getSalesDetails(salesId);
      salesDetail(response);
      selectedCropType.value = CropModel(
        id: response.myCrop.id,
        name: response.myCrop.name,
      );
      salesQuantity.value = response.salesQuantity;

      quantityAmount.value = response.quantityAmount;

      salesAmount.value = (quantityAmount.value * salesQuantity.value!);
      deductions.clear();
      for (var dedu in response.deductions) {
        final deduction = {
          "id": dedu.deductionId,
          "reason": dedu.reason.id,
          "charges": dedu.charges,
          "rupee": dedu.rupee.id.toString(),
        };
        addDeduction(deduction);
      }

      amountPaid.value = response.amountPaid.toString();
      selectedCustomer.value = response.myCustomer.id;
      selectedDate.value = DateTime.parse(response.createdAt);
    } catch (e) {
     showError( 'Failed to fetch sales details: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchReasons() async {
    try {
      final response = await _salesRepository.getReasons();
      reasonsList.assignAll(response);
      if (reasonsList.isNotEmpty) {
        selectedReason.value = reasonsList.first;
      }
    } catch (e) {
       showError('Failed to fetch reasons: $e');
    }
  }

  Future<void> fetchRupees() async {
    try {
      final response = await _salesRepository.getRupees();
      rupeesList.assignAll(response);
    } catch (e) {
       showError('Failed to fetch rupees: $e');
    }
  }

  Future<void> fetchCustomerList() async {
    try {
      final response = await _salesRepository.getCustomerList();
      customerList.assignAll(response);
    } catch (e) {
     showError( 'Failed to fetch customers: $e');
    }
  }

  void addDocumentItem() {
    Get.to(
      const AddDocumentView(),
      binding: DocumentBinding(),
      arguments: {"id": getDocTypeId(DocType.sales)},
    )?.then((result) {
      if (result != null && result is AddDocumentModel) {
        documentItems.add(result);
      }
      print(documentItems.toString());
    });
  }

  void removeDocumentItem(int index) {
    documentItems.removeAt(index);
  }

  Future<bool> addSales() async {
    try {
      isLoading(true);
      final documentItemsList = documentItems.map((doc) {
        var json = doc.toJson();
        return json;
      }).toList();
      final request = SalesAddRequest(
        datesOfSales: selectedDate.value.toIso8601String().split('T')[0],
        myCrop: selectedCropType.value.id,
        myCustomer: selectedCustomer.value ?? 0,
        salesQuantity: salesQuantity.value ?? 0,
        salesUnit: selectedUnit.value.id,
        quantityAmount: quantityAmount.value.toString(),
        salesAmount: salesAmount.value.toString(),
        deductionAmount: deductionAmount.value.toString(),
        description: description.value,
        amountPaid: amountPaid.value,
        deductions: deductions,
        fileData: documentItemsList,
      );

      final response = await _salesRepository.addSales(request);

      if (response['success'] == true) {
        showSuccess( response['message'] ?? 'Sales added successfully!',
        );
        clearForm();
        return true;
      } else {
        showError( response['message'] ?? 'Failed to add sales',
        );
        return false;
      }
    } catch (e) {
       showError( 'Failed to add sales: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateSales(int salesId) async {
    try {
      isLoading(true);

      final request = SalesUpdateRequest(
        id: salesId.toString(),
        datesOfSales: selectedDate.value.toIso8601String().split('T')[0],
        myCrop: selectedCropType.value.id,
        myCustomer: selectedCustomer.value ?? 0,
        salesQuantity: salesQuantity.value ?? 0,
        salesUnit: selectedUnit.value.id,
        quantityAmount: quantityAmount.value,
        salesAmount: salesAmount.value,
        deductionAmount: deductionAmount.value,
        description: description.value,
        amountPaid: amountPaid.value,
        deductions: deductions,
        fileData: documents,
      );

      final response = await _salesRepository.updateSales(salesId, request);

      if (response['success'] == true) {
         showError(response['message'] ?? 'Sales updated successfully!',
        );
        return true;
      } else {
         showError( response['message'] ?? 'Failed to update sales',
        );
        return false;
      }
    } catch (e) {
       showError( 'Failed to update sales: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteSales(int salesId) async {
    try {
      isLoading(true);
      final response = await _salesRepository.deleteSales(salesId);

      if (response['message'] != null) {
        showSuccess( response['message']);
        return true;
      } else {
         showError( 'Failed to delete sales');
        return false;
      }
    } catch (e) {
       showError( 'Failed to delete sales: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  void changeCrop(CropModel crop) {
    selectedCropType.value = crop;
  }

  void changeUnit(Unit crop) {
    selectedUnit.value = crop;
  }

  void changeResion(Reason crop) {
    selectedReason.value = crop;
  }

  void addDeduction(Map<String, dynamic> deduction) {
    deductions.add(deduction);
    calculateTotalDeduction();
  }

  void removeDeduction(int index) {
    deductions.removeAt(index);
    calculateTotalDeduction();
  }

  void calculateTotalDeduction() {
    int total = 0;
    for (var deduction in deductions) {
      final charges = int.tryParse(deduction['charges'] ?? '0') ?? 0;
      if (deduction['rupee'] == '1') {
        // Rupee
        total += charges;
      } else if (deduction['rupee'] == '2') {
        // Percentage
        final salesAmt = salesAmount.value;
        total += (salesAmt * charges / 100).round();
      }
    }
    deductionAmount.value = total;
    // netAmount.value=
  }

  void clearForm() {
    selectedCustomer.value = null;
    selectedDate.value = DateTime.now();
    salesQuantity.value = null;
    // selectedUnit.value = null;
    quantityAmount.value = 0;
    salesAmount.value = 0;
    deductionAmount.value = 0;
    amountPaid.value = '';
    description.value = '';
    deductions.clear();
    documents.clear();
  }

  void prefillForm(SalesDetail detail) {
    // selectedCrop.value = detail.myCrop.id;
    selectedCustomer.value = detail.myCustomer.id;
    selectedDate.value = DateTime.parse(detail.datesOfSales);
    salesQuantity.value = detail.salesQuantity;
    // selectedUnit.value = detail.salesUnit.id;
    quantityAmount.value = detail.quantityAmount;
    salesAmount.value = detail.salesAmount;
    deductionAmount.value = detail.deductionAmount;
    amountPaid.value = detail.amountPaid.toString();
    description.value = detail.description ?? '';

    // Convert deductions to form format
    deductions.assignAll(
      detail.deductions
          .map(
            (d) => {
              'id': d.deductionId,
              'reason': d.reason.id.toString(),
              'charges': d.charges,
              'rupee': d.rupee.id.toString(),
            },
          )
          .toList(),
    );

    // Convert documents to form format (simplified)
    // documents.assignAll(
    //   detail.documents
    //       .expand(
    //         (category) => category.documents.map(
    //           (doc) => {
    //             'document_id': doc.id,
    //             'file_type': category.categoryId,
    //             'file_url': doc.fileUpload,
    //           },
    //         ),
    //       )
    //       .toList(),
    // );
  }
}
