// models/sales_model.dart
import 'dart:convert';

import 'package:argiot/src/app/modules/expense/model/customer.dart';
import 'package:argiot/src/app/modules/sales/controller/new_sales_controller.dart';
import 'package:argiot/src/app/modules/sales/model/reason.dart';
import 'package:argiot/src/app/modules/sales/model/rupee.dart';
import 'package:argiot/sales_detail.dart';
import 'package:argiot/src/app/modules/sales/model/sales_list_response.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'src/app/controller/app_controller.dart';
import 'src/app/modules/near_me/views/widget/widgets.dart';
import 'src/app/modules/sales/model/model.dart';
import 'src/app/modules/task/model/model.dart';
import 'src/app/modules/task/view/screens/screen.dart';
import 'src/app/utils/http/http_service.dart';
import 'src/core/app_style.dart';
import 'src/routes/app_routes.dart';

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

  Map<String, dynamic> toJson() => {
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
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: 'Sales Details',
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Get.toNamed(
              Routes.newSales,
              arguments: {
                "id": controller.salesDetail.value?.salesId,
                "new": true,
              },
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
            const SizedBox(height: 10),

            // Sales Details Card
            _buildSalesDetailsCard(salesDetail),
            const SizedBox(height: 10),

            // Deductions Section
            if (salesDetail.deductions.isNotEmpty)
              _buildDeductionsSection(salesDetail),
            if (salesDetail.deductions.isNotEmpty) const SizedBox(height: 20),

            // Documents Section
            if (salesDetail.documents.isNotEmpty)
              _buildDocumentsSection(salesDetail),
            if (salesDetail.documents.isNotEmpty) const SizedBox(height: 20),

            // Description Section
            if (salesDetail.description != null &&
                salesDetail.description != '')
              _buildDescriptionSection(salesDetail),
          ],
        ),
      );
    }),
  );

  Widget _buildProductHeader(SalesDetail salesDetail) => Row(
    children: [
      CachedNetworkImage(
        imageUrl: salesDetail.myCrop.img,
        width: 80,
        height: 80,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      const SizedBox(width: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText(salesDetail.myCrop.name),
          Text(salesDetail.myLand.name),
        ],
      ),
    ],
  );

  Widget _buildSalesDetailsCard(SalesDetail salesDetail) => Card(
    margin: EdgeInsets.zero,
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Date', salesDetail.datesOfSales),
          _buildDetailRow('Customer Name', salesDetail.myCustomer.name),
          _buildDetailRow('Gross Sales', '₹${salesDetail.salesAmount}'),
          // _buildDetailRow('Deduction', '₹${salesDetail.deductionAmount}'),
          _buildDetailRow('Net Sales', '₹${salesDetail.totalSalesAmount}'),
          _buildDetailRow('Amount Paid', '₹${salesDetail.amountPaid}'),
        ],
      ),
    ),
  );

  Widget _buildDetailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Get.textTheme.bodyMedium),
        Text(value, style: Get.textTheme.bodyLarge),
      ],
    ),
  );

  Widget _buildDeductionsSection(SalesDetail salesDetail) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const TitleText('Deductions'),
      const SizedBox(height: 8),
      ...salesDetail.deductions.map(
        (deduction) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          child: ListTile(
            title: Text(deduction.reason.name),
            subtitle: Text('${deduction.charges} ${deduction.rupee.name}'),
          ),
        ),
      ),
    ],
  );

  Widget _buildDocumentsSection(SalesDetail salesDetail) => Column(
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
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(document.documentCategory.name),
                    CachedNetworkImage(
                      imageUrl: document.uploadDocument,
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
                    //  Positioned(
                    //   bottom: 2,
                    //   right: 2,
                    //   child: SizedBox(width: 76,child: InputCardStyle(
                    //     noHeight: true,
                    //     child: Text(document.documentCategory.name)),)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    ],
  );

  Widget _buildDescriptionSection(SalesDetail salesDetail) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Description', style: Get.textTheme.titleMedium),
      const SizedBox(height: 8),
      Text(salesDetail.description ?? ''),
    ],
  );
}

class NewSalesView extends StatefulWidget {
  const NewSalesView({super.key});

  @override
  State<NewSalesView> createState() => _NewSalesViewState();
}

class _NewSalesViewState extends State<NewSalesView> {
  final NewSalesController controller = Get.find<NewSalesController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller.loadData();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'New Sales', showBackButton: true),

    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
              _buildDatePicker(),
              const SizedBox(height: 10),
              // Product Dropdown
              _buildProductDropdown(),
              const SizedBox(height: 10),

              // Customer Dropdown
              _buildCustomerDropdown(),
              const SizedBox(height: 10),

              // Sales Quantity
              Row(
                children: [
                  Expanded(child: _buildSalesQuantityField()),
                  const SizedBox(width: 10),

                  // Unit Dropdown
                  Expanded(child: _buildUnitDropdown()),
                ],
              ),
              const SizedBox(height: 10),

              // Quantity Amount
              _buildQuantityAmountField(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: Get.textTheme.bodyLarge),

                  Text(
                    "${controller.salesAmount.value}",
                    style: Get.textTheme.bodyLarge,
                  ),
                ],
              ),
              // // Sales Amount
              // _buildSalesAmountField(),
              const SizedBox(height: 10),
              const Divider(), const SizedBox(height: 16),

              // Deductions Section
              _buildDeductionsSection(),

              const SizedBox(height: 5),
              const Divider(),
              const SizedBox(height: 5),
              // Amount Paid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Net sale', style: Get.textTheme.bodyLarge),

                  Text(
                    "${controller.salesAmount.value - controller.deductionAmount.value}",
                    style: Get.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildAmountPaidField(),
              const SizedBox(height: 10),
              _buildDocumentsSection(), const SizedBox(height: 10),
              // Description
              _buildDescriptionField(),
              const SizedBox(height: 20),

              // Submit Button
              _buildSubmitButton(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    }),
  );

  Widget _buildDocumentsSection() => Column(
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
              onPressed: controller.addDocumentItem,
              tooltip: 'Add Document',
            ),
          ),
        ],
      ),
      Obx(() {
        if (controller.documentItems.isEmpty) {
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
          itemCount: controller.documentItems.length,
          itemBuilder: (context, index) => Column(
            children: [
              Row(
                children: [
                  Text(
                    "${index + 1}, ${controller.documentItems[index].newFileType!}",
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

  Widget _buildProductDropdown() => Obx(
    () => MyDropdown(
      items: controller.crop,
      selectedItem: controller.selectedCropType.value,
      onChanged: (land) => controller.changeCrop(land!),
      label: 'Crop*',
      // disable: isEditing,
    ),
  );

  Widget _buildCustomerDropdown() => Row(
    children: [
      Expanded(
        child: InputCardStyle(
          child: DropdownButtonFormField<int>(
            icon: const Icon(Icons.keyboard_arrow_down),
            decoration: const InputDecoration(
              hintText: 'Customer * ',

              border: InputBorder.none,
            ),
            value: controller.selectedCustomer.value,
            onChanged: (value) => controller.selectedCustomer.value = value,
            items: controller.customerList
                .map(
                  (customer) => DropdownMenuItem<int>(
                    value: customer.id,
                    child: Text(customer.name),
                  ),
                )
                .toList(),
            validator: (value) =>
                value == null ? 'Please select a customer' : null,
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
              // arguments: {"type": 'vendor'},
            )?.then((result) {
              controller.fetchCustomerList();
            });
          },
          icon: const Icon(Icons.add),
        ),
      ),
    ],
  );

  Widget _buildDatePicker() => InputCardStyle(
    child: InkWell(
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
          hintText: 'Date',
          border: InputBorder.none,
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
    ),
  );

  Widget _buildSalesQuantityField() => InputCardStyle(
    child: TextFormField(
      decoration: const InputDecoration(
        hintText: 'Sales Quantity',
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
      initialValue: controller.salesQuantity.value.toString(),
      onChanged: (value) {
        controller.salesQuantity.value = int.tryParse(value);
        controller.salesAmount.value =
            (controller.quantityAmount.value * controller.salesQuantity.value!);
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter quantity' : null,
    ),
  );

  Widget _buildUnitDropdown() => Obx(
    () => MyDropdown(
      items: controller.unit,
      selectedItem: controller.selectedUnit.value,
      onChanged: (unit) => controller.changeUnit(unit!),
      label: 'Unit*',
      // disable: isEditing,
    ),
  );

  Widget _buildQuantityAmountField() => InputCardStyle(
    child: TextFormField(
      decoration: const InputDecoration(
        hintText: 'Amount per unit*',
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
      initialValue: controller.quantityAmount.value.toString(),
      onChanged: (value) {
        controller.quantityAmount.value = int.tryParse(value)!;
        controller.salesAmount.value =
            (controller.quantityAmount.value * controller.salesQuantity.value!);
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter amount' : null,
    ),
  );

  Widget _buildDeductionsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Deductions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Card(
            color: Get.theme.primaryColor,
            child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.add),
              onPressed: () => Get.toNamed(Routes.addDeduction),
            ),
          ),
        ],
      ),
      Obx(
        () => Column(
          children: controller.deductions
              .map(
                (deduction) => ListTile(
                  title: Text(
                    (deduction['new_reason'] ?? deduction['reason_name']) ?? '',
                  ),
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
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 16),
      Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total Deduction:', style: Get.textTheme.bodyLarge),
            Text(
              controller.deductionAmount.value.toString(),
              style: Get.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildAmountPaidField() => InputCardStyle(
    child: TextFormField(
      decoration: const InputDecoration(
        hintText: 'Amount Paid*',
        border: InputBorder.none,
      ),
      initialValue: controller.amountPaid.value,
      keyboardType: TextInputType.number,
      onChanged: (value) => controller.amountPaid.value = value,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter amount paid' : null,
    ),
  );

  Widget _buildDescriptionField() => Container(
    decoration: AppStyle.decoration.copyWith(
      color: const Color.fromARGB(137, 221, 234, 234),
      boxShadow: const [],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

    child: TextFormField(
      decoration: const InputDecoration(
        hintText: 'Description',
        border: InputBorder.none,
      ),
      maxLines: 3,
      onChanged: (value) => controller.description.value = value,
    ),
  );

  Widget _buildSubmitButton() => SizedBox(
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
