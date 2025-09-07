class SalesEditRequest {
  final int salesId;
  final String datesOfSales;
  final int myCrop;
  final int myCustomer;
  final int salesQuantity;
  final int salesUnit;
  final String quantityAmount;
  final String salesAmount;
  final String deductionAmount;
  final String description;
  final String amountPaid;
  final List<Map<String, dynamic>> deductions;
  final List<Map<String, dynamic>> fileData;

  SalesEditRequest({
    required this.salesId,
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
    'sales_id': salesId,
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
