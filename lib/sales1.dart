import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'src/app/controller/app_controller.dart';
import 'src/app/utils/http/http_service.dart';

class SalesResponse {
  final int cropId;
  final String cropName;
  final int cropLandId;
  final String cropLand;
  final String cropImg;
  final double totalSalesAmount;
  final List<Sale> sales;

  SalesResponse({
    required this.cropId,
    required this.cropName,
    required this.cropLandId,
    required this.cropLand,
    required this.cropImg,
    required this.totalSalesAmount,
    required this.sales,
  });

  factory SalesResponse.fromJson(Map<String, dynamic> json) {
    return SalesResponse(
      cropId: json['crop_id'],
      cropName: json['crop_name'],
      cropLandId: json['crop_land_id'],
      cropLand: json['crop_land'],
      cropImg: json['crop_img'],
      totalSalesAmount: double.parse(json['total_sales_amount'].toString()),
      sales: List<Sale>.from(json['sales'].map((x) => Sale.fromJson(x))),
    );
  }
}

class Sale {
  final int salesId;
  final String datesOfSales;
  final int salesQuantity;
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

  Sale({
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

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      salesId: json['sales_id'],
      datesOfSales: json['dates_of_sales'],
      salesQuantity: json['sales_quantity'],
      salesUnit: SalesUnit.fromJson(json['sales_unit']),
      quantityAmount: json['quantity_amount'],
      totalAmount: json['total_amount'],
      salesAmount: double.parse(json['sales_amount'].toString()),
      deductionAmount: json['deduction_amount'],
      totalSalesAmount: double.parse(json['total_sales_amount'].toString()),
      description: json['description'],
      status: json['status'],
      farmer: Farmer.fromJson(json['farmer']),
      myCustomer: Customer.fromJson(json['my_customer']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class SalesDetails {
  final int salesId;
  final Farmer farmer;
  final String datesOfSales;
  final Crop myCrop;
  final Customer myCustomer;
  final int salesQuantity;
  final SalesUnit salesUnit;
  final String quantityAmount;
  final String totalAmount;
  final double salesAmount;
  final String deductionAmount;
  final double totalSalesAmount;
  final double amountPaid;
  final String? description;
  final int status;
  final String createdAt;
  final String updatedAt;
  final List<Deduction> deductions;
  final List<DocumentCategory> documents;

  SalesDetails({
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

  factory SalesDetails.fromJson(Map<String, dynamic> json) {
    return SalesDetails(
      salesId: json['sales_id'],
      farmer: Farmer.fromJson(json['farmer']),
      datesOfSales: json['dates_of_sales'],
      myCrop: Crop.fromJson(json['my_crop']),
      myCustomer: Customer.fromJson(json['my_customer']),
      salesQuantity: json['sales_quantity'],
      salesUnit: SalesUnit.fromJson(json['sales_unit']),
      quantityAmount: json['quantity_amount'],
      totalAmount: json['total_amount'],
      salesAmount: double.parse(json['sales_amount'].toString()),
      deductionAmount: json['deduction_amount'],
      totalSalesAmount: double.parse(json['total_sales_amount'].toString()),
      amountPaid: double.parse(json['amount_paid'].toString()),
      description: json['description'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deductions: List<Deduction>.from(
          json['deductions'].map((x) => Deduction.fromJson(x))),
      documents: List<DocumentCategory>.from(
          json['documents'].map((x) => DocumentCategory.fromJson(x))),
    );
  }
}

class Farmer {
  final int id;
  final String name;

  Farmer({required this.id, required this.name});

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(id: json['id'], name: json['name']);
  }
}

class Customer {
  final int id;
  final String name;
  final String? village;
  final String? shopName;

  Customer({
    required this.id,
    required this.name,
    this.village,
    this.shopName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? json['customer_id'],
      name: json['name'] ?? json['customer_name'],
      village: json['village'],
      shopName: json['shop_name'],
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
      id: json['id'],
      name: json['name'],
      img: json['img'],
    );
  }
}

class SalesUnit {
  final int id;
  final String name;

  SalesUnit({required this.id, required this.name});

  factory SalesUnit.fromJson(Map<String, dynamic> json) {
    return SalesUnit(id: json['id'], name: json['name']);
  }
}

class Deduction {
  final int? deductionId;
  final Reason reason;
  final String charges;
  final Rupee rupee;

  Deduction({
    this.deductionId,
    required this.reason,
    required this.charges,
    required this.rupee,
  });

  factory Deduction.fromJson(Map<String, dynamic> json) {
    return Deduction(
      deductionId: json['deduction_id'],
      reason: Reason.fromJson(json['reason']),
      charges: json['charges'],
      rupee: Rupee.fromJson(json['rupee']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (deductionId != null) 'id': deductionId,
      'reason': reason.id,
      'charges': charges,
      'rupee': rupee.id,
    };
  }
}

class Reason {
  final int id;
  final String name;

  Reason({required this.id, required this.name});

  factory Reason.fromJson(Map<String, dynamic> json) {
    return Reason(id: json['id'], name: json['name']);
  }
}

class Rupee {
  final int id;
  final String name;

  Rupee({required this.id, required this.name});

  factory Rupee.fromJson(Map<String, dynamic> json) {
    return Rupee(id: json['id'], name: json['name']);
  }
}

class DocumentCategory {
  final String categoryId;
  final List<Document> documents;

  DocumentCategory({required this.categoryId, required this.documents});

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    return DocumentCategory(
      categoryId: json['category_id'],
      documents: List<Document>.from(
          json['documents'].map((x) => Document.fromJson(x))),
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
      id: json['id'],
      documentCategory: DocumentCategoryType.fromJson(json['document_category']),
      fileUpload: json['file_upload'],
    );
  }
}

class DocumentCategoryType {
  final int id;
  final String name;

  DocumentCategoryType({required this.id, required this.name});

  factory DocumentCategoryType.fromJson(Map<String, dynamic> json) {
    return DocumentCategoryType(id: json['id'], name: json['name']);
  }
}


class MySalesRepository {
  final HttpService _httpService = Get.find();

  final AppDataController _appDataController = Get.find();
  Future<SalesResponse> getSalesList({
  
    required int cropId,
    required String type,
  }) async {  final farmerId = _appDataController.userId;
    final response = await _httpService.post(
      '/get_sales_by_crop/$farmerId/',
       {'crop_id': cropId, 'type': type},
    );
    var response2 = json.decode(response.body);
    return SalesResponse.fromJson(response2);
  }

  Future<SalesDetails> getSalesDetails({
   
    required int salesId,
  }) async {  final farmerId = _appDataController.userId;
    final response = await _httpService.post(
      '/get_sales_details/$farmerId/',
      {'sales_id': salesId},
    );
    var response2 = json.decode(response.body);
    return SalesDetails.fromJson(response2);
  }

   addSale({
    
    required Map<String, dynamic> data,
  }) async {  final farmerId = _appDataController.userId;
    return await _httpService.post(
      '/add_sales_with_deductions/$farmerId',
      data,
    );
  }

  updateSale({
   
    required int salesId,
    required Map<String, dynamic> data,
  }) async {  final farmerId = _appDataController.userId;
    return await _httpService.post(
      '/update_sales_with_deductions/$farmerId/$salesId/',
       data,
    );
  }

   deleteSale({

    required int salesId,
  }) async {  final farmerId = _appDataController.userId;
    return await _httpService.post(
      '/deactivate_my_sale/$farmerId/',
   {'id': salesId},
    );
  }

  Future<List<Reason>> getReasons() async {
    final response = await _httpService.get('/reasons/');
    var response2 = json.decode(response.body);
    return List<Reason>.from(response2.map((x) => Reason.fromJson(x)));
  }

  Future<List<Rupee>> getRupees() async {
    final response = await _httpService.get('/rupees/');
    var response2 = json.decode(response.body);
    return List<Rupee>.from(response2.map((x) => Rupee.fromJson(x)));
  }

  Future<List<Customer>> getCustomers() async {  final farmerId = _appDataController.userId;
    final response = await _httpService.get('/get_customer_list/$farmerId/');
    var response2 = json.decode(response.body);
    return List<Customer>.from(response2.map((x) => Customer.fromJson(x)));
  }
}


class MySalesController extends GetxController {
  final MySalesRepository _repository = Get.find();

  var isLoading = false.obs;
  var salesResponse = Rx<SalesResponse?>(null);
  var selectedCropId = 1.obs;
  var selectedTimeRange = 'month'.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with default values or fetch from arguments
    final args = Get.arguments;
    if (args != null && args['cropId'] != null) {
      selectedCropId.value = args['cropId'];
      loadSales();
    }
  }

  Future<void> loadSales() async {
    try {
      isLoading(true);

      final response = await _repository.getSalesList(
        
        cropId: selectedCropId.value,
        type: selectedTimeRange.value,
      );
      salesResponse.value = response;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sales: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void changeCropFilter(int cropId) {
    selectedCropId.value = cropId;
    loadSales();
  }

  void changeTimeRangeFilter(String timeRange) {
    selectedTimeRange.value = timeRange;
    loadSales();
  }

  void navigateToDetails(Sale sale) {
    // Get.toNamed(
    //   Routes.SALES_DETAILS,
    //   arguments: {'sale': sale},
    // );
  }

  void navigateToAddSale() {
    // Get.toNamed(Routes.SALES_FORM);
  }
}

class SalesDetailsController extends GetxController {
  final MySalesRepository _repository = Get.find();

  var isLoading = false.obs;
  var salesDetails = Rx<SalesDetails?>(null);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['sale'] != null) {
      loadSalesDetails(args['sale'].salesId);
    }
  }

  Future<void> loadSalesDetails(int salesId) async {
    try {
      isLoading(true);

      final details = await _repository.getSalesDetails(
      
        salesId: salesId,
      );
      salesDetails.value = details;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sales details: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // void navigateToEdit() {
  //   if (salesDetails.value != null) {
  //     Get.toNamed(
  //     Routes.SALES_FORM,
  //       arguments: {'sale': salesDetails.value},
  //     );
  //   }
  // }

  Future<void> deleteSale() async {
    try {
      isLoading(true);
   
      final salesId = salesDetails.value?.salesId;
      if (salesId != null) {
        await _repository.deleteSale(
          salesId: salesId,
        );
        Get.back();
        Get.snackbar('Success', 'Sale deleted successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete sale: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
}
class SalesFormController extends GetxController {
  final MySalesRepository _repository = Get.find();

  var isLoading = false.obs;
  var isEditing = false.obs;
  var formKey = GlobalKey<FormState>();
  var salesDetails = Rx<SalesDetails?>(null);

  // Form fields
  var selectedCrop = Rx<Crop?>(null);
  var selectedCustomer = Rx<Customer?>(null);
  var selectedDate = Rx<DateTime?>(null);
  var quantity = Rx<String?>(null);
  var selectedUnit = Rx<SalesUnit?>(null);
  var amountPerUnit = Rx<String?>(null);
  var amountPaid = Rx<String?>(null);
  var description = Rx<String?>(null);
  var deductions = <Deduction>[].obs;
  var documents = <Map<String, dynamic>>[].obs;

  // Dropdown options
  var crops = <Crop>[].obs;
  var customers = <Customer>[].obs;
  var units = <SalesUnit>[].obs;
  var reasons = <Reason>[].obs;
  var rupees = <Rupee>[].obs;

  // Calculated values
  var totalAmount = 0.0.obs;
  var netAmount = 0.0.obs;

  @override
  void onInit() async {
    super.onInit();
    await loadDropdownOptions();

    final args = Get.arguments;
    if (args != null && args['sale'] != null) {
      isEditing.value = true;
      salesDetails.value = args['sale'];
      populateFormFromExistingSale();
    }
  }

  Future<void> loadDropdownOptions() async {
    try {
      isLoading(true);
     

      // Load reasons and rupees
      reasons.assignAll(await _repository.getReasons());
      rupees.assignAll(await _repository.getRupees());
      customers.assignAll(await _repository.getCustomers());

      // TODO: Load crops and units from appropriate endpoints
      // These are just placeholders
      crops.assignAll([
        Crop(id: 1, name: 'Coffee', img: ''),
        Crop(id: 2, name: 'Tomato', img: ''),
      ]);
      units.assignAll([
        SalesUnit(id: 1, name: 'Pieces'),
        SalesUnit(id: 2, name: 'Kilos'),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load options: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void populateFormFromExistingSale() {
    final sale = salesDetails.value;
    if (sale != null) {
      selectedCrop.value = sale.myCrop;
      selectedCustomer.value = sale.myCustomer;
      selectedDate.value = DateTime.parse(sale.datesOfSales);
      quantity.value = sale.salesQuantity.toString();
      selectedUnit.value = sale.salesUnit;
      amountPerUnit.value = sale.quantityAmount;
      amountPaid.value = sale.amountPaid.toString();
      description.value = sale.description;
      deductions.assignAll(sale.deductions);
      // TODO: Handle documents
      calculateTotals();
    }
  }

  void calculateTotals() {
    final qty = double.tryParse(quantity.value ?? '0') ?? 0;
    final amt = double.tryParse(amountPerUnit.value ?? '0') ?? 0;
    totalAmount.value = qty * amt;

    // Calculate deductions
    double totalDeductions = 0;
    for (var deduction in deductions) {
      totalDeductions += double.tryParse(deduction.charges) ?? 0;
    }

    netAmount.value = totalAmount.value - totalDeductions;
  }

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      selectedDate.value = pickedDate;
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading(true);

      final data = {
        'dates_of_sales': DateFormat('yyyy-MM-dd').format(selectedDate.value!),
        'my_crop': selectedCrop.value!.id,
        'my_customer': selectedCustomer.value!.id,
        'sales_quantity': quantity.value,
        'sales_unit': selectedUnit.value!.id,
        'quantity_amount': amountPerUnit.value,
        'sales_amount': totalAmount.value.toString(),
        'deduction_amount': (totalAmount.value - netAmount.value).toString(),
        'description': description.value,
        'amount_paid': amountPaid.value,
        'deductions': deductions.map((d) => d.toJson()).toList(),
        if (documents.isNotEmpty) 'file_data': documents,
      };

      if (isEditing.value) {
        final salesId = salesDetails.value!.salesId;
        await _repository.updateSale(
          salesId: salesId,
          data: data,
        );
        Get.back();
        Get.snackbar('Success', 'Sale updated successfully');
      } else {
        await _repository.addSale(
          data: data,
        );
        Get.back();
        Get.snackbar('Success', 'Sale added successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit form: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
}


class DeductionController extends GetxController {
  var selectedReason = Rx<Reason?>(null);
  var percentage = Rx<String?>(null);
  var amount = Rx<double?>(null);
  var selectedRupee = Rx<Rupee?>(null);
  var customReason = Rx<String?>(null);

  void calculateAmount(double grossAmount) {
    if (percentage.value != null) {
      final pct = double.tryParse(percentage.value!) ?? 0;
      amount.value = grossAmount * (pct / 100);
    }
  }

  Deduction? getDeduction() {
    if ((selectedReason.value == null && customReason.value == null) ||
        amount.value == null ||
        selectedRupee.value == null) {
      return null;
    }

    return Deduction(
      reason: selectedReason.value ??
          Reason(id: 0, name: customReason.value!),
      charges: amount.value!.toStringAsFixed(2),
      rupee: selectedRupee.value!,
    );
  }
}

class SalesListScreen extends GetView<MySalesController> {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterRow(),
          _buildTotalSales(),
          Expanded(child: _buildSalesList()),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: controller.navigateToAddSale,
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => DropdownButtonFormField<int>(
                  value: controller.selectedCropId.value,
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Coffee'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Tomato'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeCropFilter(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Product',
                    border: OutlineInputBorder(),
                  ),
                )),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedTimeRange.value,
                  items: [
                    DropdownMenuItem(
                      value: 'day',
                      child: Text('Today'),
                    ),
                    DropdownMenuItem(
                      value: 'week',
                      child: Text('This Week'),
                    ),
                    DropdownMenuItem(
                      value: 'month',
                      child: Text('Last 30 Days'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeTimeRangeFilter(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Time Range',
                    border: OutlineInputBorder(),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSales() {
    return Obx(() {
      final total = controller.salesResponse.value?.totalSalesAmount ?? 0;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Sales',
                style: Get.textTheme.titleLarge,
              ),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSalesList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final sales = controller.salesResponse.value?.sales ?? [];
      if (sales.isEmpty) {
        return const Center(child: Text('No sales found'));
      }

      return ListView.builder(
        itemCount: sales.length,
        itemBuilder: (context, index) {
          final sale = sales[index];
          return _buildSaleItem(sale);
        },
      );
    });
  }

  Widget _buildSaleItem(Sale sale) {
    final date = DateTime.parse(sale.datesOfSales);
    final formattedDate = '${date.day} ${_getMonthName(date.month)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: () => controller.navigateToDetails(sale),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formattedDate.split(' ')[0],
              style: Get.textTheme.titleLarge,
            ),
            Text(
              formattedDate.split(' ')[1],
              style: Get.textTheme.bodySmall,
            ),
          ],
        ),
        title: Text(sale.myCustomer.name),
        subtitle: Text(sale.myCustomer.village ?? ''),
        trailing: Text(
          '₹${sale.totalSalesAmount.toStringAsFixed(2)}',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    return [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ][month - 1];
  }
}
 

class SalesDetailsScreen extends GetView<SalesDetailsController> {
  const SalesDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
        actions: [
          IconButton(
            onPressed: (){
              // controller.navigateToEdit;
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: controller.deleteSale,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final sale = controller.salesDetails.value;
        if (sale == null) {
          return const Center(child: Text('Sale details not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductInfo(sale),
              const SizedBox(height: 16),
              _buildSaleInfo(sale),
              const SizedBox(height: 16),
              _buildDocuments(sale),
              const SizedBox(height: 16),
              _buildDescription(sale),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProductInfo(SalesDetails sale) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(sale.myCrop.img),
              radius: 30,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.myCrop.name,
                  style: Get.textTheme.titleLarge,
                ),
                Text(
                  'Quantity: ${sale.salesQuantity} ${sale.salesUnit.name}',
                  style: Get.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleInfo(SalesDetails sale) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Date', sale.datesOfSales),
            _buildInfoRow('Customer', sale.myCustomer.name),
            _buildInfoRow('Gross Sales', '₹${sale.salesAmount.toStringAsFixed(2)}'),
            _buildInfoRow('Deductions', '₹${sale.deductionAmount}'),
            _buildInfoRow('Net Sales', '₹${sale.totalSalesAmount.toStringAsFixed(2)}'),
            _buildInfoRow('Amount Paid', '₹${sale.amountPaid.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: Get.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildDocuments(SalesDetails sale) {
    if (sale.documents.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents',
          style: Get.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sale.documents.length,
            itemBuilder: (context, index) {
              final category = sale.documents[index];
              return _buildDocumentCategory(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCategory(DocumentCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.documents.first.documentCategory.name,
          style: Get.textTheme.bodySmall,
        ),
        SizedBox(
          width: 150,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: category.documents.length,
            itemBuilder: (context, index) {
              final doc = category.documents[index];
              return GestureDetector(
                onTap: () => _showDocumentPreview(doc.fileUpload),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.network(
                    doc.fileUpload,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(SalesDetails sale) {
    if (sale.description == null || sale.description!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Get.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(sale.description!),
      ],
    );
  }

  void _showDocumentPreview(String url) {
    Get.dialog(
      Dialog(
        child: InteractiveViewer(
          child: Image.network(url),
        ),
      ),
    );
  }
}



class SalesFormScreen extends GetView<SalesFormController> {
  const SalesFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing.value ? 'Edit Sale' : 'New Sale'),
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProductDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(context),
              const SizedBox(height: 16),
              _buildCustomerDropdown(),
              const SizedBox(height: 16),
              _buildQuantityInput(),
              const SizedBox(height: 16),
              _buildUnitDropdown(),
              const SizedBox(height: 16),
              _buildAmountPerUnit(),
              const SizedBox(height: 16),
              _buildTotalAmount(),
              const SizedBox(height: 16),
              _buildDeductionsSection(),
              const SizedBox(height: 16),
              _buildNetAmount(),
              const SizedBox(height: 16),
              _buildAmountPaid(),
              const SizedBox(height: 16),
              _buildDescription(),
              const SizedBox(height: 16),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDropdown() {
    return Obx(() => DropdownButtonFormField<Crop>(
          value: controller.selectedCrop.value,
          items: controller.crops
              .map((crop) => DropdownMenuItem(
                    value: crop,
                    child: Text(crop.name),
                  ))
              .toList(),
          onChanged: (value) => controller.selectedCrop.value = value,
          decoration: const InputDecoration(
            labelText: 'Product*',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null ? 'Please select a product' : null,
        ));
  }

  Widget _buildDatePicker(BuildContext context) {
    return Obx(() => TextFormField(
          readOnly: true,
          controller: TextEditingController(
            text: controller.selectedDate.value != null
                ? '${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}'
                : '',
          ),
          decoration: const InputDecoration(
            labelText: 'Date*',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () => controller.pickDate(context),
          validator: (value) =>
              controller.selectedDate.value == null ? 'Please select a date' : null,
        ));
  }

  Widget _buildCustomerDropdown() {
    return Obx(() => DropdownButtonFormField<Customer>(
          value: controller.selectedCustomer.value,
          items: controller.customers
              .map((customer) => DropdownMenuItem(
                    value: customer,
                    child: Text(customer.name),
                  ))
              .toList(),
          onChanged: (value) => controller.selectedCustomer.value = value,
          decoration: const InputDecoration(
            labelText: 'Customer*',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null ? 'Please select a customer' : null,
        ));
  }

  Widget _buildQuantityInput() {
    return Obx(() => TextFormField(
          controller: TextEditingController(text: controller.quantity.value),
          decoration: const InputDecoration(
            labelText: 'Quantity*',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            controller.quantity.value = value;
            controller.calculateTotals();
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter quantity' : null,
        ));
  }

  Widget _buildUnitDropdown() {
    return Obx(() => DropdownButtonFormField<SalesUnit>(
          value: controller.selectedUnit.value,
          items: controller.units
              .map((unit) => DropdownMenuItem(
                    value: unit,
                    child: Text(unit.name),
                  ))
              .toList(),
          onChanged: (value) => controller.selectedUnit.value = value,
          decoration: const InputDecoration(
            labelText: 'Unit*',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null ? 'Please select a unit' : null,
        ));
  }

  Widget _buildAmountPerUnit() {
    return Obx(() => TextFormField(
          controller:
              TextEditingController(text: controller.amountPerUnit.value),
          decoration: const InputDecoration(
            labelText: 'Amount per unit*',
            border: OutlineInputBorder(),
            prefixText: '₹',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            controller.amountPerUnit.value = value;
            controller.calculateTotals();
          },
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter amount per unit'
              : null,
        ));
  }

  Widget _buildTotalAmount() {
    return Obx(() => Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gross Sales Amount'),
                Text(
                  '₹${controller.totalAmount.value.toStringAsFixed(2)}',
                  style: Get.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildDeductionsSection() {
    return Obx(() => ExpansionTile(
          title: const Text('Deductions'),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDeductionDialog(),
          ),
          children: [
            if (controller.deductions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No deductions added'),
              )
            else
              ...controller.deductions.map((deduction) => ListTile(
                    title: Text(deduction.reason.name),
                    trailing: Text(
                      '-₹${deduction.charges}',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                    onTap: () => _showEditDeductionDialog(deduction),
                  )),
          ],
        ));
  }

  Widget _buildNetAmount() {
    return Obx(() => Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Sales Amount'),
                Text(
                  '₹${controller.netAmount.value.toStringAsFixed(2)}',
                  style: Get.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildAmountPaid() {
    return Obx(() => TextFormField(
          controller: TextEditingController(text: controller.amountPaid.value),
          decoration: const InputDecoration(
            labelText: 'Amount Paid*',
            border: OutlineInputBorder(),
            prefixText: '₹',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => controller.amountPaid.value = value,
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter amount paid' : null,
        ));
  }

  Widget _buildDescription() {
    return Obx(() => TextFormField(
          controller: TextEditingController(text: controller.description.value),
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) => controller.description.value = value,
        ));
  }

  Widget _buildSubmitButton() {
    return Obx(() => ElevatedButton(
          onPressed:
              controller.isLoading.value ? null : () => controller.submitForm(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12),
            child: Text(
              controller.isEditing.value ? 'Update Sale' : 'Add Sale',
              style: Get.textTheme.titleMedium,
            ),
          ),
        ));
  }

  void _showAddDeductionDialog() {
    Get.bottomSheet(
      DeductionForm(
        grossAmount: controller.totalAmount.value,
        onAddDeduction: (deduction) {
          if (deduction != null) {
            controller.deductions.add(deduction);
            controller.calculateTotals();
          }
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showEditDeductionDialog(Deduction deduction) {
    Get.bottomSheet(
      DeductionForm(
        grossAmount: controller.totalAmount.value,
        deduction: deduction,
        onAddDeduction: (updatedDeduction) {
          if (updatedDeduction != null) {
            final index = controller.deductions.indexOf(deduction);
            controller.deductions[index] = updatedDeduction;
            controller.calculateTotals();
          }
          Get.back();
        },
      ),
      isScrollControlled: true,
    );
  }
}


class DeductionForm extends GetView<DeductionController> {
  
  final  SalesFormController selescontroler = Get.find();
  final double grossAmount;
  final Deduction? deduction;
  final Function(Deduction?) onAddDeduction;

  DeductionForm({
    super.key,
    required this.grossAmount,
    this.deduction,
    required this.onAddDeduction,
  });

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Initialize controller with deduction if editing
    if (deduction != null) {
      controller.selectedReason.value = deduction!.reason;
      controller.percentage.value =
          ((double.parse(deduction!.charges) / grossAmount) * 100).toString();
      controller.amount.value = double.parse(deduction!.charges);
      controller.selectedRupee.value = deduction!.rupee;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              deduction == null ? 'Add Deduction' : 'Edit Deduction',
              style: Get.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildReasonDropdown(),
            const SizedBox(height: 16),
            _buildPercentageInput(),
            const SizedBox(height: 16),
            _buildAmountDisplay(),
            const SizedBox(height: 16),
            _buildRupeeDropdown(),
            const SizedBox(height: 16),
            _buildCustomReason(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonDropdown() {
    return Obx(() => DropdownButtonFormField<Reason>(
          value: controller.selectedReason.value,
          items: selescontroler.reasons
              .map((reason) => DropdownMenuItem(
                    value: reason,
                    child: Text(reason.name),
                  ))
              .toList(),
          onChanged: (value) {
            controller.selectedReason.value = value;
            controller.customReason.value = null;
          },
          decoration: const InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              (value == null && controller.customReason.value == null)
                  ? 'Please select or enter a reason'
                  : null,
        ));
  }

  Widget _buildPercentageInput() {
    return Obx(() => TextFormField(
          controller: TextEditingController(text: controller.percentage.value),
          decoration: const InputDecoration(
            labelText: 'Percentage',
            border: OutlineInputBorder(),
            suffixText: '%',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            controller.percentage.value = value;
            controller.calculateAmount(grossAmount);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter percentage';
            }
            final pct = double.tryParse(value) ?? 0;
            if (pct < 0 || pct > 100) {
              return 'Percentage must be between 0-100';
            }
            return null;
          },
        ));
  }

  Widget _buildAmountDisplay() {
    return Obx(() => Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Deduction Amount'),
                Text(
                  '₹${controller.amount.value?.toStringAsFixed(2) ?? '0.00'}',
                  style: Get.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildRupeeDropdown() {
    return Obx(() => DropdownButtonFormField<Rupee>(
          value: controller.selectedRupee.value,
          items: selescontroler.rupees
              .map((rupee) => DropdownMenuItem(
                    value: rupee,
                    child: Text(rupee.name),
                  ))
              .toList(),
          onChanged: (value) => controller.selectedRupee.value = value,
          decoration: const InputDecoration(
            labelText: 'Currency',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null ? 'Please select currency' : null,
        ));
  }

  Widget _buildCustomReason() {
    return Obx(() {
      if (controller.selectedReason.value != null) {
        return const SizedBox();
      }
      return TextFormField(
        controller: TextEditingController(text: controller.customReason.value),
        decoration: const InputDecoration(
          labelText: 'Custom Reason',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => controller.customReason.value = value,
        validator: (value) =>
            (value == null || value.isEmpty) && controller.selectedReason.value == null
                ? 'Please enter a reason'
                : null,
      );
    });
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'))),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                onAddDeduction(controller.getDeduction());
              }
            },
            child: Text(deduction == null ? 'Add' : 'Update')),
        ),
      ],
    );
  }
}

class SalesBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MySalesRepository());
    Get.lazyPut(() => MySalesController());
    Get.lazyPut(() => SalesDetailsController());
    Get.lazyPut(() => SalesFormController());
    Get.lazyPut(() => DeductionController(),fenix: true);
  }
}


