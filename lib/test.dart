// models/sales_model.dart
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'src/app/controller/app_controller.dart';
import 'src/app/modules/task/model/model.dart';
import 'src/app/modules/task/view/screens/screen.dart';
import 'src/app/utils/http/http_service.dart';
import 'src/routes/app_routes.dart';

class SalesListResponse {
  final int cropId;
  final String cropName;
  final int cropLandId;
  final String cropLand;
  final String cropImg;
  final double totalSalesAmount;
  final List<SalesItem> sales;

  SalesListResponse({
    required this.cropId,
    required this.cropName,
    required this.cropLandId,
    required this.cropLand,
    required this.cropImg,
    required this.totalSalesAmount,
    required this.sales,
  });

  factory SalesListResponse.fromJson(Map<String, dynamic> json) {
    return SalesListResponse(
      cropId: json['crop_id'] ?? 0,
      cropName: json['crop_name'] ?? '',
      cropLandId: json['crop_land_id'] ?? 0,
      cropLand: json['crop_land'] ?? '',
      cropImg: json['crop_img'] ?? '',
      totalSalesAmount: (json['total_sales_amount'] ?? 0.0).toDouble(),
      sales: (json['sales'] as List<dynamic>? ?? [])
          .map((item) => SalesItem.fromJson(item))
          .toList(),
    );
  }
}

class SalesItem {
  final int salesId;
  final String datesOfSales;
  final double salesQuantity;
  final SalesUnit salesUnit;
  final String quantityAmount;
  final String totalAmount;
  final double salesAmount;
  final String deductionAmount;
  final double totalSalesAmount;
  final String description;
  final int status;
  final Farmer farmer;
  final Customer myCustomer;
  final String createdAt;
  final String updatedAt;

  SalesItem({
    required this.salesId,
    required this.datesOfSales,
    required this.salesQuantity,
    required this.salesUnit,
    required this.quantityAmount,
    required this.totalAmount,
    required this.salesAmount,
    required this.deductionAmount,
    required this.totalSalesAmount,
    required this.description,
    required this.status,
    required this.farmer,
    required this.myCustomer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    return SalesItem(
      salesId: json['sales_id'] ?? 0,
      datesOfSales: json['dates_of_sales'] ?? '',
      salesQuantity: (json['sales_quantity'] ?? 0.0).toDouble(),
      salesUnit: SalesUnit.fromJson(json['sales_unit'] ?? {}),
      quantityAmount: json['quantity_amount'] ?? '',
      totalAmount: json['total_amount'] ?? '',
      salesAmount: (json['sales_amount'] ?? 0.0).toDouble(),
      deductionAmount: json['deduction_amount'] ?? '',
      totalSalesAmount: (json['total_sales_amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      farmer: Farmer.fromJson(json['farmer'] ?? {}),
      myCustomer: Customer.fromJson(json['my_customer'] ?? {}),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class SalesDetail {
  final int salesId;
  final Farmer farmer;
  final String datesOfSales;
  final Crop myCrop;
  final Customer myCustomer;
  final int salesQuantity;
  final SalesUnit salesUnit;
  final int quantityAmount;
  final String totalAmount;
  final int salesAmount;
  final int deductionAmount;
  final double totalSalesAmount;
  final double amountPaid;
  final String? description;
  final int status;
  final String createdAt;
  final String updatedAt;
  final List<Deduction> deductions;
  final List<DocumentCategory> documents;

  SalesDetail({
    required this.salesId,
    required this.farmer,
    required this.datesOfSales,
    required this.myCrop,
    required this.myCustomer,
    required this.salesQuantity,
    required this.salesUnit,
    required this.quantityAmount,
    required this.totalAmount,
    required this.salesAmount,
    required this.deductionAmount,
    required this.totalSalesAmount,
    required this.amountPaid,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deductions,
    required this.documents,
  });

  factory SalesDetail.fromJson(Map<String, dynamic> json) {
    return SalesDetail(
      salesId: json['sales_id'] ?? 0,
      farmer: Farmer.fromJson(json['farmer'] ?? {}),
      datesOfSales: json['dates_of_sales'] ?? '',
      myCrop: Crop.fromJson(json['my_crop'] ?? {}),
      myCustomer: Customer.fromJson(json['my_customer'] ?? {}),
      salesQuantity: (json['sales_quantity'] ?? 0.0).toDouble(),
      salesUnit: SalesUnit.fromJson(json['sales_unit'] ?? {}),
      quantityAmount: json['quantity_amount'] ?? '',
      totalAmount: json['total_amount'] ?? '',
      salesAmount: (json['sales_amount'] ?? 0.0).toDouble(),
      deductionAmount: json['deduction_amount'] ?? '',
      totalSalesAmount: (json['total_sales_amount'] ?? 0.0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0.0).toDouble(),
      description: json['description'],
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deductions: (json['deductions'] as List<dynamic>? ?? [])
          .map((item) => Deduction.fromJson(item))
          .toList(),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((item) => DocumentCategory.fromJson(item))
          .toList(),
    );
  }
}

class Farmer {
  final int id;
  final String name;

  Farmer({required this.id, required this.name});

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class Customer extends NamedItem {
  @override
  final int id;
  @override
  final String name;
  final String village;
  final String shopName;

  Customer({
    required this.id,
    required this.name,
    this.village = '',
    this.shopName = '',
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['customer_name'] ?? '',
      village: json['village'] ?? '',
      shopName: json['shop_name'] ?? '',
    );
  }
}

class Crop {
  final int id;
  final String name;
  final String img;

  Crop({required this.id, required this.name, required this.img});

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      img: json['img'] ?? '',
    );
  }
}

class SalesUnit {
  final int id;
  final String name;

  SalesUnit({required this.id, required this.name});

  factory SalesUnit.fromJson(Map<String, dynamic> json) {
    return SalesUnit(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class Deduction {
  final int deductionId;
  final Reason reason;
  final String charges;
  final Rupee rupee;

  Deduction({
    required this.deductionId,
    required this.reason,
    required this.charges,
    required this.rupee,
  });

  factory Deduction.fromJson(Map<String, dynamic> json) {
    return Deduction(
      deductionId: json['deduction_id'] ?? 0,
      reason: Reason.fromJson(json['reason'] ?? {}),
      charges: json['charges'] ?? '',
      rupee: Rupee.fromJson(json['rupee'] ?? {}),
    );
  }
}

class Reason extends NamedItem {
  @override
  final int id;
  @override
  final String name;

  Reason({required this.id, required this.name});

  factory Reason.fromJson(Map<String, dynamic> json) {
    return Reason(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class Unit extends NamedItem {
  @override
  final int id;
  @override
  final String name;

  Unit({required this.id, required this.name});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class Rupee {
  final int id;
  final String name;

  Rupee({required this.id, required this.name});

  factory Rupee.fromJson(Map<String, dynamic> json) {
    return Rupee(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class DocumentCategory {
  final String categoryId;
  final List<Document> documents;

  DocumentCategory({required this.categoryId, required this.documents});

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    return DocumentCategory(
      categoryId: json['category_id'] ?? '',
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((item) => Document.fromJson(item))
          .toList(),
    );
  }
}

class Document {
  final int id;
  final DocumentCategoryType documentCategory;
  final String fileUpload;

  Document({
    required this.id,
    required this.documentCategory,
    required this.fileUpload,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? 0,
      documentCategory: DocumentCategoryType.fromJson(
        json['document_category'] ?? {},
      ),
      fileUpload: json['file_upload'] ?? '',
    );
  }
}

class DocumentCategoryType {
  final int id;
  final String name;

  DocumentCategoryType({required this.id, required this.name});

  factory DocumentCategoryType.fromJson(Map<String, dynamic> json) {
    return DocumentCategoryType(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class SalesAddRequest {
  final String datesOfSales;
  final int myCrop;
  final int myCustomer;
  final int salesQuantity;
  final int salesUnit;
  final int quantityAmount;
  final int salesAmount;
  final int deductionAmount;
  final String description;
  final String amountPaid;
  final List<Map<String, dynamic>> deductions;
  final List<Map<String, dynamic>> fileData;

  SalesAddRequest({
    required this.datesOfSales,
    required this.myCrop,
    required this.myCustomer,
    required this.salesQuantity,
    required this.salesUnit,
    required this.quantityAmount,
    required this.salesAmount,
    required this.deductionAmount,
    required this.description,
    required this.amountPaid,
    required this.deductions,
    required this.fileData,
  });

  Map<String, dynamic> toJson() {
    return {
      'dates_of_sales': datesOfSales,
      'my_crop': myCrop,
      'my_customer': myCustomer,
      'sales_quantity': salesQuantity,
      'sales_unit': salesUnit,
      'quantity_amount': quantityAmount,
      'sales_amount': salesAmount,
      'deduction_amount': deductionAmount,
      'description': description,
      'amount_paid': amountPaid,
      'deductions': deductions,
      if (fileData.isNotEmpty) 'file_data': fileData,
    };
  }
}

class SalesUpdateRequest {
  final String id;
  final String datesOfSales;
  final int myCrop;
  final int myCustomer;
  final int salesQuantity;
  final int salesUnit;
  final int quantityAmount;
  final int salesAmount;
  final int deductionAmount;
  final String description;
  final String amountPaid;
  final List<Map<String, dynamic>> deductions;
  final List<Map<String, dynamic>> fileData;

  SalesUpdateRequest({
    required this.id,
    required this.datesOfSales,
    required this.myCrop,
    required this.myCustomer,
    required this.salesQuantity,
    required this.salesUnit,
    required this.quantityAmount,
    required this.salesAmount,
    required this.deductionAmount,
    required this.description,
    required this.amountPaid,
    required this.deductions,
    required this.fileData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dates_of_sales': datesOfSales,
      'my_crop': myCrop,
      'my_customer': myCustomer,
      'sales_quantity': salesQuantity,
      'sales_unit': salesUnit,
      'quantity_amount': quantityAmount,
      'sales_amount': salesAmount,
      'deduction_amount': deductionAmount,
      'description': description,
      'amount_paid': amountPaid,
      'deductions': deductions,
      'file_data': fileData,
    };
  }
}

// repositories/sales_repository.dart

class NewSalesRepository {
  final HttpService _httpService = Get.find<HttpService>();

  final AppDataController _appDataController = Get.find();
  Future<SalesListResponse> getSalesByCrop(int cropId, String type) async {
    try {
      final farmerId = _appDataController.userId;
      final response = await _httpService.post(
        '/get_sales_by_crop/$farmerId/',
        {'crop_id': cropId, 'type': type},
      );
      return SalesListResponse.fromJson(json.decode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CropModel>> getCropList() async {
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.get(
        '/land-and-crop-details/$farmerId',
      );
      final lands = json.decode(response.body)['lands'] as List;

      final allCrops = lands
          .expand((land) => land['crops'] as List)
          .map((crop) => CropModel.fromJson(crop))
          .toSet()
          .toList();

      return allCrops;
    } catch (e) {
      throw Exception('Failed to load crops: ${e.toString()}');
    }
  }

  Future<List<Unit>> getUnitList() async {
    try {
      final response = await _httpService.get('/area_units');
      final lands = json.decode(response.body)["data"] as List;

      final allCrops = lands
          .map((crop) => Unit.fromJson(crop))
          .toSet()
          .toList();

      return allCrops;
    } catch (e) {
      throw Exception('Failed to load crops: ${e.toString()}');
    }
  }

  Future<SalesDetail> getSalesDetails(int salesId) async {
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.post(
        '/get_sales_details/$farmerId/',
        {'sales_id': salesId},
      );
      return SalesDetail.fromJson(json.decode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addSales(SalesAddRequest request) async {
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.post(
        '/add_sales_with_deductions/$farmerId',
        request.toJson(),
      );
      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateSales(
    int salesId,
    SalesUpdateRequest request,
  ) async {
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.post(
        '/update_sales_with_deductions/$farmerId/$salesId/',
        request.toJson(),
      );
      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteSales(int salesId) async {
    try {
      final farmerId = _appDataController.userId;
      final response = await _httpService.post(
        '/deactivate_my_sale/$farmerId/',
        {'id': salesId},
      );
      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Reason>> getReasons() async {
    try {
      final response = await _httpService.get('/reasons/');
      var decode = json.decode(response.body);
      var list = decode.map<Reason>((item) => Reason.fromJson(item)).toList();
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Rupee>> getRupees() async {
    try {
      final response = await _httpService.get('/rupees/');
      var decode = json.decode(response.body);
      var map = decode.map<Rupee>((item) => Rupee.fromJson(item)).toList();
      return map;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Customer>> getCustomerList() async {
    try {
      final farmerId = _appDataController.userId;
      final response = await _httpService.get('/get_customer_list/$farmerId');
      var decode = json.decode(response.body);
      var map = decode
          .map<Customer>((item) => Customer.fromJson(item))
          .toList();
      return map;
    } catch (e) {
      rethrow;
    }
  }
}

class NewSalesController extends GetxController {
  final NewSalesRepository _salesRepository = Get.find<NewSalesRepository>();

  // Reactive variables
  var isLoading = false.obs;
  var salesList = Rx<SalesListResponse?>(null);
  var salesDetail = Rx<SalesDetail?>(null);
  var reasonsList = <Reason>[].obs;
  var rupeesList = <Rupee>[].obs;
  var customerList = <Customer>[].obs;
  final RxList<CropModel> crop = <CropModel>[].obs;
  final RxList<Unit> unit = <Unit>[].obs;
  // Form variables

  final Rx<CropModel> selectedCropType = CropModel(id: 0, name: '').obs;
  final Rx<Reason> selectedResion = Reason(id: 0, name: '').obs;
  final Rx<Unit> selectedUnit = Unit(id: 0, name: '').obs;
  RxBool isNewResion = false.obs;
  var selectedCustomer = Rx<int?>(null);
  Rx<DateTime>  selectedDate = DateTime.now().obs;
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
    fetchReasons();
    fetchRupees();
    fetchCrop();
    fetchUnit();
    fetchCustomerList();
  }

  Future<void> fetchSalesByCrop(int cropId, String type) async {
    try {
      isLoading(true);
      final response = await _salesRepository.getSalesByCrop(cropId, type);
      salesList(response);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to fetch sales: $e');
    } finally {
      isLoading(false);
    }
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
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to fetch sales details: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchReasons() async {
    try {
      final response = await _salesRepository.getReasons();
      reasonsList.assignAll(response);
      if (reasonsList.isNotEmpty) {
        selectedResion.value = reasonsList.first;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to fetch reasons: $e');
    }
  }

  Future<void> fetchRupees() async {
    try {
      final response = await _salesRepository.getRupees();
      rupeesList.assignAll(response);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to fetch rupees: $e');
    }
  }

  Future<void> fetchCustomerList() async {
    try {
      final response = await _salesRepository.getCustomerList();
      customerList.assignAll(response);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to fetch customers: $e');
    }
  }

  Future<bool> addSales() async {
    try {
      isLoading(true);

      final request = SalesAddRequest(
        datesOfSales: selectedDate.value.toIso8601String().split('T')[0] ?? '',
        myCrop: selectedCropType.value.id,
        myCustomer: selectedCustomer.value ?? 0,
        salesQuantity: salesQuantity.value ?? 0,
        salesUnit: selectedUnit.value.id,
        quantityAmount: quantityAmount.value,
        salesAmount: salesAmount.value,
        deductionAmount: deductionAmount.value,
        description: description.value,
        amountPaid: amountPaid.value,
        deductions: deductions.value,
        fileData: documents,
      );

      final response = await _salesRepository.addSales(request);

      if (response['success'] == true) {
        Fluttertoast.showToast(
          msg: response['message'] ?? 'Sales added successfully!',
        );
        clearForm();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? 'Failed to add sales',
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to add sales: $e');
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
        datesOfSales: selectedDate.value.toIso8601String().split('T')[0] ?? '',
        myCrop: selectedCropType.value.id ?? 0,
        myCustomer: selectedCustomer.value ?? 0,
        salesQuantity: salesQuantity.value ?? 0,
        salesUnit: selectedUnit.value.id ?? 0,
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
        Fluttertoast.showToast(
          msg: response['message'] ?? 'Sales updated successfully!',
        );
        return true;
      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? 'Failed to update sales',
        );
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to update sales: $e');
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
        Fluttertoast.showToast(msg: response['message']);
        return true;
      } else {
        Fluttertoast.showToast(msg: 'Failed to delete sales');
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to delete sales: $e');
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
    selectedResion.value = crop;
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
        final salesAmt = salesAmount.value ?? 0;
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
    documents.assignAll(
      detail.documents
          .expand(
            (category) => category.documents.map(
              (doc) => {
                'document_id': doc.id,
                'file_type': category.categoryId,
                'file_url': doc.fileUpload,
              },
            ),
          )
          .toList(),
    );
  }
}

// bindings/sales_binding.dart
class NewSalesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewSalesRepository>(() => NewSalesRepository());
    Get.lazyPut<NewSalesController>(() => NewSalesController());
  }
}

// views/sales/sales_details_view.dart

class NewSalesDetailsView extends StatefulWidget {

  const NewSalesDetailsView({super.key});

  @override
  State<NewSalesDetailsView> createState() => _NewSalesDetailsViewState();
}

class _NewSalesDetailsViewState extends State<NewSalesDetailsView> {
  final NewSalesController controller = Get.find<NewSalesController>();

  @override
  void initState() {
    super.initState();
    // Load sales details when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSalesDetails(Get.arguments["id"]);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Sales Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.toNamed(
                Routes.EDIT_SALES,
                arguments: controller.salesDetail.value?.salesId,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final salesDetail = controller.salesDetail.value;
        if (salesDetail == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Header
              _buildProductHeader(salesDetail),
              const SizedBox(height: 20),

              // Sales Details Card
              _buildSalesDetailsCard(salesDetail),
              const SizedBox(height: 20),

              // Deductions Section
              if (salesDetail.deductions.isNotEmpty)
                _buildDeductionsSection(salesDetail),
              if (salesDetail.deductions.isNotEmpty) const SizedBox(height: 20),

              // Documents Section
              if (salesDetail.documents.isNotEmpty)
                _buildDocumentsSection(salesDetail),
              if (salesDetail.documents.isNotEmpty) const SizedBox(height: 20),

              // Description Section
              if (salesDetail.description != null)
                _buildDescriptionSection(salesDetail),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProductHeader(SalesDetail salesDetail) {
    return Row(
      children: [
        CachedNetworkImage(
          imageUrl: salesDetail.myCrop.img,
          width: 50,
          height: 50,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        const SizedBox(width: 16),
        Text(salesDetail.myCrop.name, style: Get.textTheme.headlineSmall),
      ],
    );
  }

  Widget _buildSalesDetailsCard(SalesDetail salesDetail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Date', salesDetail.datesOfSales),
            _buildDetailRow('Customer Name', salesDetail.myCustomer.name),
            _buildDetailRow('Gross Sales', '₹${salesDetail.salesAmount}'),
            _buildDetailRow('Deduction', '₹${salesDetail.deductionAmount}'),
            _buildDetailRow('Net Sales', '₹${salesDetail.totalSalesAmount}'),
            _buildDetailRow('Amount Paid', '₹${salesDetail.amountPaid}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Get.textTheme.bodyMedium),
          Text(value, style: Get.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildDeductionsSection(SalesDetail salesDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Deductions', style: Get.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...salesDetail.deductions.map(
          (deduction) => Card(
            child: ListTile(
              title: Text(deduction.reason.name),
              subtitle: Text('${deduction.charges} ${deduction.rupee.name}'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(SalesDetail salesDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Uploaded Documents', style: Get.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: salesDetail.documents
              .expand((category) => category.documents)
              .map(
                (document) => GestureDetector(
                  onTap: () {
                    // Handle document preview
                  },
                  child: CachedNetworkImage(
                    imageUrl: document.fileUpload,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.document_scanner),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(SalesDetail salesDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: Get.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(salesDetail.description ?? ''),
      ],
    );
  }
}

class NewSalesView extends StatelessWidget {
  final NewSalesController controller = Get.find<NewSalesController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NewSalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('New Sales Entry'),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Picker
                _buildDatePicker(),
                const SizedBox(height: 16),
                // Product Dropdown
                _buildProductDropdown(),
                const SizedBox(height: 16),

                // Customer Dropdown
                _buildCustomerDropdown(),
                const SizedBox(height: 16),

                // Sales Quantity
                Row(
                  children: [
                    Expanded(child: _buildSalesQuantityField()),
                    const SizedBox(width: 16),

                    // Unit Dropdown
                    Expanded(child: _buildUnitDropdown()),
                  ],
                ),
                const SizedBox(height: 16),

                // Quantity Amount
                _buildQuantityAmountField(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text("Total"),
                    Spacer(),
                    Text("${controller.salesAmount.value}"),
                  ],
                ),
                // // Sales Amount
                // _buildSalesAmountField(),
                const SizedBox(height: 16),

                // Deductions Section
                _buildDeductionsSection(),
                const SizedBox(height: 16),

                // Amount Paid
                Row(
                  children: [
                    Text("Total"),
                    Spacer(),
                    Text(
                      "${controller.salesAmount.value - controller.deductionAmount.value}",
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAmountPaidField(),
                const SizedBox(height: 16),

                // Description
                _buildDescriptionField(),
                const SizedBox(height: 16),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProductDropdown() {
    return // Crop Type Dropdown
    Obx(() {
      return MyDropdown(
        items: controller.crop,
        selectedItem: controller.selectedCropType.value,
        onChanged: (land) => controller.changeCrop(land!),
        label: 'Crop*',
        // disable: isEditing,
      );
    });
  }

  Widget _buildCustomerDropdown() {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Customer',
        border: OutlineInputBorder(),
      ),
      value: controller.selectedCustomer.value,
      onChanged: (value) => controller.selectedCustomer.value = value,
      items: controller.customerList.map((customer) {
        return DropdownMenuItem<int>(
          value: customer.id,
          child: Text(customer.name),
        );
      }).toList(),
      validator: (value) => value == null ? 'Please select a customer' : null,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: Get.context!,
          initialDate: controller.selectedDate.value,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (selected != null) {
          controller.selectedDate.value = selected;
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesQuantityField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Sales Quantity',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        controller.salesQuantity.value = int.tryParse(value);
        controller.salesAmount.value =
            (controller.quantityAmount.value * controller.salesQuantity.value!);
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter quantity' : null,
    );
  }

  Widget _buildUnitDropdown() {
    return Obx(() {
      return MyDropdown(
        items: controller.unit,
        selectedItem: controller.selectedUnit.value,
        onChanged: (unit) => controller.changeUnit(unit!),
        label: 'Unit*',
        // disable: isEditing,
      );
    });
  }

  Widget _buildQuantityAmountField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Amount per unit*',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        controller.quantityAmount.value = int.tryParse(value)!;
        controller.salesAmount.value =
            (controller.quantityAmount.value * controller.salesQuantity.value!);
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter amount' : null,
    );
  }

  Widget _buildSalesAmountField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Sales Amount',
        border: OutlineInputBorder(),
      ),
      enabled: false,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        controller.salesAmount.value = int.tryParse(value) ?? 0;
        controller.calculateTotalDeduction();
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter sales amount' : null,
    );
  }

  Widget _buildDeductionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Deductions', style: Get.textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.toNamed(Routes.ADD_DEDUCTION),
            ),
          ],
        ),
        Obx(
          () => Column(
            children: controller.deductions
                .map(
                  (deduction) => ListTile(
                    title: Text(deduction['reason']?.toString() ?? ''),
                    subtitle: Text(
                      '${deduction['charges']} ${deduction['rupee'] == '1' ? '₹' : '%'}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        final index = controller.deductions.indexOf(deduction);
                        controller.removeDeduction(index);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Obx(
          () => Text(
            'Total Deduction: ₹${controller.deductionAmount.value}',
            style: Get.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountPaidField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Amount Paid',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) => controller.amountPaid.value = value,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter amount paid' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) => controller.description.value = value,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final success = await controller.addSales();
            if (success) {
              Get.back();
            }
          }
        },
        child: const Text('Submit'),
      ),
    );
  }
}

// views/sales/edit_sales_view.dart

class NewEditSalesView extends StatefulWidget {
  final int salesId;

  const NewEditSalesView({super.key, required this.salesId});

  @override
  State<NewEditSalesView> createState() => _NewEditSalesViewState();
}

class _NewEditSalesViewState extends State<NewEditSalesView> {
  final NewSalesController controller = Get.find<NewSalesController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load sales details when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSalesDetails(widget.salesId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Edit Sales Entry'),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.salesDetail.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Dropdown
                // _buildProductDropdown(),
                const SizedBox(height: 16),

                // Customer Dropdown
                _buildCustomerDropdown(),
                const SizedBox(height: 16),

                // Date Picker
                _buildDatePicker(),
                const SizedBox(height: 16),

                // Sales Quantity
                _buildSalesQuantityField(),
                const SizedBox(height: 16),

                // Unit Dropdown
                // _buildUnitDropdown(),
                const SizedBox(height: 16),

                // Quantity Amount
                _buildQuantityAmountField(),
                const SizedBox(height: 16),

                // Sales Amount
                _buildSalesAmountField(),
                const SizedBox(height: 16),

                // Deductions Section
                _buildDeductionsSection(),
                const SizedBox(height: 16),

                // Amount Paid
                _buildAmountPaidField(),
                const SizedBox(height: 16),

                // Description
                _buildDescriptionField(),
                const SizedBox(height: 16),

                // Update Button
                _buildUpdateButton(),
              ],
            ),
          ),
        );
      }),
    );
  }

  // All the form field methods are similar to NewSalesView
  // Widget _buildProductDropdown() {
  //   return DropdownButtonFormField<int>(
  //     decoration: const InputDecoration(
  //       labelText: 'Product',
  //       border: OutlineInputBorder(),
  //     ),
  //     value: controller.selectedCrop.value,
  //     onChanged: (value) => controller.selectedCrop.value = value,
  //     items: const [
  //       DropdownMenuItem(value: 1, child: Text('Tomato')),
  //       DropdownMenuItem(value: 2, child: Text('Coffee')),
  //     ],
  //     validator: (value) => value == null ? 'Please select a product' : null,
  //   );
  // }

  Widget _buildCustomerDropdown() {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Customer',
        border: OutlineInputBorder(),
      ),
      value: controller.selectedCustomer.value,
      onChanged: (value) => controller.selectedCustomer.value = value,
      items: controller.customerList.map((customer) {
        return DropdownMenuItem<int>(
          value: customer.id,
          child: Text(customer.name),
        );
      }).toList(),
      validator: (value) => value == null ? 'Please select a customer' : null,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: Get.context!,
          initialDate: controller.selectedDate.value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (selected != null) {
          controller.selectedDate.value = selected;
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesQuantityField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Sales Quantity',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      initialValue: controller.salesQuantity.value?.toString(),
      onChanged: (value) =>
          controller.salesQuantity.value = int.tryParse(value) ?? 0,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter quantity' : null,
    );
  }

  // Widget _buildUnitDropdown() {
  //   return DropdownButtonFormField<int>(
  //     decoration: const InputDecoration(
  //       labelText: 'Unit',
  //       border: OutlineInputBorder(),
  //     ),
  //     value: controller.selectedUnit.value,
  //     onChanged: (value) => controller.selectedUnit.value = value,
  //     items: const [
  //       DropdownMenuItem(value: 1, child: Text('Pieces')),
  //       DropdownMenuItem(value: 2, child: Text('Kg')),
  //     ],
  //     validator: (value) => value == null ? 'Please select a unit' : null,
  //   );
  // }

  Widget _buildQuantityAmountField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Quantity Amount',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      initialValue: controller.quantityAmount.value.toString(),
      onChanged: (value) =>
          controller.quantityAmount.value = int.tryParse(value) ?? 0,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter amount' : null,
    );
  }

  Widget _buildSalesAmountField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Sales Amount',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      initialValue: controller.salesAmount.value.toString(),
      onChanged: (value) {
        controller.salesAmount.value = int.tryParse(value) ?? 0;
        controller.calculateTotalDeduction();
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter sales amount' : null,
    );
  }

  Widget _buildDeductionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Deductions', style: Get.textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.toNamed(Routes.ADD_DEDUCTION),
            ),
          ],
        ),
        Obx(
          () => Column(
            children: controller.deductions
                .map(
                  (deduction) => ListTile(
                    title: Text(deduction['reason']?.toString() ?? ''),
                    subtitle: Text(
                      '${deduction['charges']} ${deduction['rupee'] == '1' ? '₹' : '%'}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        final index = controller.deductions.indexOf(deduction);
                        controller.removeDeduction(index);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Obx(
          () => Text(
            'Total Deduction: ₹${controller.deductionAmount.value}',
            style: Get.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountPaidField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Amount Paid',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      initialValue: controller.amountPaid.value,
      onChanged: (value) => controller.amountPaid.value = value,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter amount paid' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      initialValue: controller.description.value,
      onChanged: (value) => controller.description.value = value,
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final success = await controller.updateSales(widget.salesId);
            if (success) {
              Get.back();
            }
          }
        },
        child: const Text('Update'),
      ),
    );
  }
}

// views/sales/add_deduction_view.dart

class AddDeductionView extends StatelessWidget {
  final NewSalesController controller = Get.find<NewSalesController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _chargesController = TextEditingController();
  final RxString _selectedType = '1'.obs; // 1 for Rupee, 2 for Percentage

  AddDeductionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Add Deduction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reason Input
              _buildReasonInput(),
              const SizedBox(height: 16),

              // Charges Input
              _buildChargesInput(),
              const SizedBox(height: 16),

              // Type Selector
              _buildTypeSelector(),
              const SizedBox(height: 16),

              // Add Button
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonInput() {
    return Obx(() {
      return Row(
        children: [
          if (!controller.isNewResion.value)
            Expanded(
              child: MyDropdown(
                items: controller.reasonsList,
                selectedItem: controller.selectedResion.value,
                onChanged: (land) => controller.changeResion(land!),
                label: 'Reason*',
                // disable: isEditing,
              ),
            ),
          if (controller.isNewResion.value)
            Expanded(
              child: TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Deduction',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a reason'
                    : null,
              ),
            ),
          IconButton.filled(
            onPressed: () {
              controller.isNewResion.value = !controller.isNewResion.value;
            },
            icon: Icon(Icons.add),
          ),
        ],
      );
    });
  }

  Widget _buildChargesInput() {
    return TextFormField(
      controller: _chargesController,
      decoration: const InputDecoration(
        labelText: 'Deduction Amount',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter deduction amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Deduction must be greater than 0';
        }
        if (_selectedType.value == '2' && amount > 100) {
          return 'Percentage cannot exceed 100%';
        }
        return null;
      },
    );
  }

  Widget _buildTypeSelector() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: ListTile(
              title: const Text('₹'),
              leading: Radio<String>(
                value: '1',
                groupValue: _selectedType.value,
                onChanged: (value) => _selectedType.value = value!,
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              title: const Text('%'),
              leading: Radio<String>(
                value: '2',
                groupValue: _selectedType.value,
                onChanged: (value) => _selectedType.value = value!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final deduction = {
              if (!controller.isNewResion.value)
                'reason': controller.selectedResion.value.id,
              if (controller.isNewResion.value)
                'new_reason': _reasonController.text,
              'charges': _chargesController.text,
              'rupee': _selectedType.value,
            };

            controller.addDeduction(deduction);
            Get.back();
          }
        },
        child: const Text('Add Deduction'),
      ),
    );
  }
}
