// lib/model/payables_receivables_model.dart
class PayableCustomer {
  int id;
  String customerName;
  String shopName;
  bool isCredit;
  double openingBalance;

  PayableCustomer({
    required this.id,
    required this.customerName,
    required this.shopName,
    required this.isCredit,
    required this.openingBalance,
  });

  factory PayableCustomer.fromJson(Map<String, dynamic> json) =>
      PayableCustomer(
        id: json['id'],
        customerName: json['customer_name'],
        shopName: json['shop_name'],
        isCredit: json['is_credit'],
        openingBalance: (json['opening_balance'] as num).toDouble(),
      );
}

class ReceivableCustomer {
  int id;
  String customerName;
  String shopName;
  bool isCredit;
  double openingBalance;

  ReceivableCustomer({
    required this.id,
    required this.customerName,
    required this.shopName,
    required this.isCredit,
    required this.openingBalance,
  });

  factory ReceivableCustomer.fromJson(Map<String, dynamic> json) =>
      ReceivableCustomer(
        id: json['id'],
        customerName: json['customer_name'],
        shopName: json['shop_name'],
        isCredit: json['is_credit'],
        openingBalance: (json['opening_balance'] as num).toDouble(),
      );
}

class PayableVendor {
  int id;
  String vendorName;
  String businessName;
  bool isCredit;
  double openingBalance;

  PayableVendor({
    required this.id,
    required this.vendorName,
    required this.businessName,
    required this.isCredit,
    required this.openingBalance,
  });

  factory PayableVendor.fromJson(Map<String, dynamic> json) => PayableVendor(
    id: json['id'],
    vendorName: json['vendor_name'],
    businessName: json['business_name'],
    isCredit: json['is_credit'],
    openingBalance: (json['opening_balance'] as num).toDouble(),
  );
}

class ReceivableVendor {
  int id;
  String vendorName;
  String businessName;
  bool isCredit;
  double openingBalance;

  ReceivableVendor({
    required this.id,
    required this.vendorName,
    required this.businessName,
    required this.isCredit,
    required this.openingBalance,
  });

  factory ReceivableVendor.fromJson(Map<String, dynamic> json) =>
      ReceivableVendor(
        id: json['id'],
        vendorName: json['vendor_name'],
        businessName: json['business_name'],
        isCredit: json['is_credit'],
        openingBalance: (json['opening_balance'] as num).toDouble(),
      );
}

class BothCustomerVendor {
  int id;
  String? customerName;
  String? shopName;
  String? vendorName;
  String? businessName;
  bool isCredit;
  double openingBalance;

  BothCustomerVendor({
    required this.id,
    this.customerName,
    this.shopName,
    this.vendorName,
    this.businessName,
    required this.isCredit,
    required this.openingBalance,
  });

  factory BothCustomerVendor.fromJson(Map<String, dynamic> json) =>
      BothCustomerVendor(
        id: json['id'],
        customerName: json['customer_name'],
        shopName: json['shop_name'],
        vendorName: json['vendor_name'],
        businessName: json['business_name'],
        isCredit: json['is_credit'],
        openingBalance: (json['opening_balance'] as num).toDouble(),
      );
}

class PayablesReceivablesList {
  List<PayableCustomer> customerPayables;
  List<ReceivableCustomer> customerReceivables;
  List<PayableVendor> vendorPayables;
  List<ReceivableVendor> vendorReceivables;

  // Add both_customer_vendor lists (assuming same structure as Customer for example)
  List<BothCustomerVendor> bothCustomerVendorPayables;
  List<BothCustomerVendor> bothCustomerVendorReceivables;

  PayablesReceivablesList({
    required this.customerPayables,
    required this.customerReceivables,
    required this.vendorPayables,
    required this.vendorReceivables,
    required this.bothCustomerVendorPayables,
    required this.bothCustomerVendorReceivables,
  });

  factory PayablesReceivablesList.fromJson(Map<String, dynamic> json) {
    final customerList = json['customer_list'] ?? {};
    final vendorList = json['vendor_list'] ?? {};
    final bothList = json['both_customer_vendor'] ?? {};

    return PayablesReceivablesList(
      customerPayables:
          (customerList['payables'] as List<dynamic>?)
              ?.map((e) => PayableCustomer.fromJson(e))
              .toList() ??
          [],
      customerReceivables:
          (customerList['receivables'] as List<dynamic>?)
              ?.map((e) => ReceivableCustomer.fromJson(e))
              .toList() ??
          [],
      vendorPayables:
          (vendorList['payables'] as List<dynamic>?)
              ?.map((e) => PayableVendor.fromJson(e))
              .toList() ??
          [],
      vendorReceivables:
          (vendorList['receivables'] as List<dynamic>?)
              ?.map((e) => ReceivableVendor.fromJson(e))
              .toList() ??
          [],
      bothCustomerVendorPayables:
          (bothList['payables'] as List<dynamic>?)
              ?.map((e) => BothCustomerVendor.fromJson(e))
              .toList() ??
          [],
      bothCustomerVendorReceivables:
          (bothList['receivables'] as List<dynamic>?)
              ?.map((e) => BothCustomerVendor.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CustomerReceivable {
  final int customerId;
  final String? customerName;
  final String? shopName;
  final String? customerImage;
  final List<Sale> sales;

  CustomerReceivable({
    required this.customerId,
    this.customerName,
    this.shopName,
    this.customerImage,
    required this.sales,
  });

  factory CustomerReceivable.fromJson(Map<String, dynamic> json) =>
      CustomerReceivable(
        customerId: json["customer_id"],
        customerName: json["customer_name"],
        shopName: json["shop_name"],
        customerImage: json["customer_image"],
        sales: (json["sales"] as List).map((s) => Sale.fromJson(s)).toList(),
      );
}

class Sale {
  final int salesId;
  final String salesDate;
  final int cropId;
  final String cropName;
  final double totalSalesAmount;
  final double amountPaid;
  final double receivedAmount;
  final double toPayAmount;

  Sale({
    required this.salesId,
    required this.salesDate,
    required this.cropId,
    required this.cropName,
    required this.totalSalesAmount,
    required this.amountPaid,
    required this.receivedAmount,
    required this.toPayAmount,
  });

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
    salesId: json["sales_id"],
    salesDate: json["sales_date"],
    cropId: json["crop_id"],
    cropName: json["crop_name"],
    totalSalesAmount: (json["total_sales_amount"] as num).toDouble(),
    amountPaid: (json["amount_paid"] as num).toDouble(),
    receivedAmount: (json["received_amount"] as num).toDouble(),
    toPayAmount: (json["topay_amount"] as num).toDouble(),
  );
}
