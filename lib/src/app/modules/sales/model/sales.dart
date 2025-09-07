import 'package:argiot/src/app/modules/expense/model/customer.dart';
import 'package:argiot/src/app/modules/expense/model/farmer.dart';
import 'package:argiot/src/app/modules/sales/model/unit.dart';

class Sales {
  final int salesId;
  final String datesOfSales;
  final int salesQuantity;
  final Unit salesUnit;
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

  Sales({
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

  factory Sales.fromJson(Map<String, dynamic> json) => Sales(
      salesId: json['sales_id'],
      datesOfSales: json['dates_of_sales'],
      salesQuantity: json['sales_quantity'],
      salesUnit: Unit.fromJson(json['sales_unit']),
      quantityAmount: json['quantity_amount'],
      totalAmount: json['total_amount'],
      salesAmount: json['sales_amount']?.toDouble() ?? 0.0,
      deductionAmount: json['deduction_amount'],
      totalSalesAmount: json['total_sales_amount']?.toDouble() ?? 0.0,
      description: json['description'],
      status: json['status'],
      farmer: Farmer.fromJson(json['farmer']),
      myCustomer: Customer.fromJson(json['my_customer']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
}
