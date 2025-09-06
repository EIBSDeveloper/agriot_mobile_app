// lib/models/customer_sales_model.dart
class CustomerSalesModel {
  final List<CustomerPayable> payables;
  final List<CustomerReceivable> receivables;

  CustomerSalesModel({required this.payables, required this.receivables});

  factory CustomerSalesModel.fromJson(Map<String, dynamic> json) => CustomerSalesModel(
      payables:
          json['customer_sales']['payables'] != null
              ? List<CustomerPayable>.from(
                json['customer_sales']['payables'].map(
                  (x) => CustomerPayable.fromJson(x),
                ),
              )
              : [],
      receivables:
          json['customer_sales']['receivables'] != null
              ? List<CustomerReceivable>.from(
                json['customer_sales']['receivables'].map(
                  (x) => CustomerReceivable.fromJson(x),
                ),
              )
              : [],
    );
}

// ---------- Payables ----------
class CustomerPayable {
  final int customerId;
  final String customerName;
  final String shopName;
  final String customerImage;
  final List<SalesData> sales;

  CustomerPayable({
    required this.customerId,
    required this.customerName,
    required this.shopName,
    required this.customerImage,
    required this.sales,
  });

  factory CustomerPayable.fromJson(Map<String, dynamic> json) => CustomerPayable(
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      shopName: json['shop_name'] ?? '',
      customerImage: json['customer_image'] ?? '',
      sales:
          (json['sales'] as List<dynamic>?)
              ?.map((e) => SalesData.fromJson(e))
              .toList() ??
          [],
    );
}

// ---------- Receivables ----------
class CustomerReceivable {
  final int customerId;
  final String customerName;
  final String shopName;
  final String customerImage;
  final List<SalesData> sales;

  CustomerReceivable({
    required this.customerId,
    required this.customerName,
    required this.shopName,
    required this.customerImage,
    required this.sales,
  });

  factory CustomerReceivable.fromJson(Map<String, dynamic> json) => CustomerReceivable(
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      shopName: json['shop_name'] ?? '',
      customerImage: json['customer_image'] ?? '',
      sales:
          (json['sales'] as List<dynamic>?)
              ?.map((e) => SalesData.fromJson(e))
              .toList() ??
          [],
    );
}

// ---------- Common Sales ----------
class SalesData {
  final int salesId;
  final String salesDate;
  final int cropId;
  final String cropName;
  final double totalSalesAmount;
  final double amountPaid;
  final double receivedAmount;
  final double topayAmount;

  SalesData({
    required this.salesId,
    required this.salesDate,
    required this.cropId,
    required this.cropName,
    required this.totalSalesAmount,
    required this.amountPaid,
    required this.receivedAmount,
    required this.topayAmount,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) => SalesData(
      salesId: json['sales_id'] ?? 0,
      salesDate: json['sales_date'] ?? '',
      cropId: json['crop_id'] ?? 0,
      cropName: json['crop_name'] ?? '',
      totalSalesAmount: (json['total_sales_amount'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      receivedAmount: (json['received_amount'] ?? 0).toDouble(),
      topayAmount: (json['topay_amount'] ?? 0).toDouble(),
    );
}

// lib/models/customer_sales_model.dart
