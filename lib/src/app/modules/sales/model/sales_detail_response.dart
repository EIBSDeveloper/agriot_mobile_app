import 'package:argiot/src/app/modules/expense/model/document_category.dart';
import 'package:argiot/src/app/modules/expense/model/customer.dart';
import 'package:argiot/src/app/modules/expense/model/farmer.dart';
import 'package:argiot/src/app/modules/forming/model/crop.dart';
import 'package:argiot/src/app/modules/sales/model/deduction.dart';
import 'package:argiot/src/app/modules/sales/model/unit.dart';


class SalesDetailResponse {
  final int salesId;
  final Farmer farmer;
  final String datesOfSales;
  final Crop myCrop;
  final Customer myCustomer;
  final int salesQuantity;
  final Unit salesUnit;
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

  SalesDetailResponse({
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

  factory SalesDetailResponse.fromJson(Map<String, dynamic> json) => SalesDetailResponse(
      salesId: json['sales_id'],
      farmer: Farmer.fromJson(json['farmer']),
      datesOfSales: json['dates_of_sales'],
      myCrop: Crop.fromJson(json['my_crop']),
      myCustomer: Customer.fromJson(json['my_customer']),
      salesQuantity: json['sales_quantity'],
      salesUnit: Unit.fromJson(json['sales_unit']),
      quantityAmount: json['quantity_amount'],
      totalAmount: json['total_amount'],
      salesAmount: json['sales_amount']?.toDouble() ?? 0.0,
      deductionAmount: json['deduction_amount'],
      totalSalesAmount: json['total_sales_amount']?.toDouble() ?? 0.0,
      amountPaid: json['amount_paid']?.toDouble() ?? 0.0,
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
