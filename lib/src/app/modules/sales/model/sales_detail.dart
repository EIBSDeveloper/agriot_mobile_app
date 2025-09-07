// models/sales_model.dart

import 'package:argiot/src/app/modules/expense/model/document_category.dart';
import 'package:argiot/src/app/modules/expense/model/customer.dart';
import 'package:argiot/src/app/modules/forming/model/crop.dart';
import 'package:argiot/src/app/modules/sales/model/deduction.dart';
import 'package:argiot/src/app/modules/near_me/model/models.dart';
import 'package:argiot/src/app/modules/sales/model/unit.dart';

class SalesDetail {
  final int salesId;
  final String datesOfSales;
  final Crop myCrop;
  final Land myLand;
  final Customer myCustomer;
  final int salesQuantity;
  final Unit salesUnit;
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
    required this.datesOfSales,
    required this.myCrop,
    required this.myLand,
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

  factory SalesDetail.fromJson(Map<String, dynamic> json) => SalesDetail(
    salesId: json['sales_id'] ?? 0,
    datesOfSales: json['dates_of_sales'] ?? '',
    myCrop: Crop.fromJson(json['my_crop'] ?? {}),
    myLand: Land.fromJson(json['land'] ?? {}),
    myCustomer: Customer.fromJson(json['my_customer'] ?? {}),
    salesQuantity: (json['sales_quantity'] ?? 0.0).round(),
    salesUnit: Unit.fromJson(json['sales_unit'] ?? {}),
    quantityAmount: int.tryParse(json['quantity_amount']) ?? 0,
    totalAmount: json['total_amount'] ?? '',
    salesAmount: (json['sales_amount'] ?? 0.0).round(),
    deductionAmount: int.tryParse(json['deduction_amount']) ?? 0,
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
