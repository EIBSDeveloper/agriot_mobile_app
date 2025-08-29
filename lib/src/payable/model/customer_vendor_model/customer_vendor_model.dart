// models/customer_vendor_model.dart

class CustomerVendorResponse<T> {
  final String detail;
  final T data;

  CustomerVendorResponse({required this.detail, required this.data});

  factory CustomerVendorResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return CustomerVendorResponse(
      detail: json['detail'],
      data: fromJsonT(json['data']),
    );
  }
}

class PayablesData {
  final List<VendorPayable> vendorPayables;
  final List<CustomerPayable> customerPayables;

  PayablesData({required this.vendorPayables, required this.customerPayables});

  factory PayablesData.fromJson(Map<String, dynamic> json) {
    return PayablesData(
      vendorPayables:
          (json['vendor_payables'] as List)
              .map((e) => VendorPayable.fromJson(e))
              .toList(),
      customerPayables:
          (json['customer_payables'] as List)
              .map((e) => CustomerPayable.fromJson(e))
              .toList(),
    );
  }
}

class ReceivablesData {
  final List<VendorReceivable> vendorReceivables;
  final List<CustomerReceivable> customerReceivables;

  ReceivablesData({
    required this.vendorReceivables,
    required this.customerReceivables,
  });

  factory ReceivablesData.fromJson(Map<String, dynamic> json) {
    return ReceivablesData(
      vendorReceivables:
          (json['vendor_receivables'] as List)
              .map((e) => VendorReceivable.fromJson(e))
              .toList(),
      customerReceivables:
          (json['customer_receivables'] as List)
              .map((e) => CustomerReceivable.fromJson(e))
              .toList(),
    );
  }
}

// Vendor Payable and Customer Payable - Assuming empty list so simple classes
class VendorPayable {
  // Define fields if any, here empty list in example so simple
  VendorPayable();

  factory VendorPayable.fromJson(Map<String, dynamic> json) {
    // Add parsing here if fields exist
    return VendorPayable();
  }
}

class CustomerPayable {
  CustomerPayable();

  factory CustomerPayable.fromJson(Map<String, dynamic> json) {
    return CustomerPayable();
  }
}

// Vendor Receivable & Customer Receivable with nested lists

class VendorReceivable {
  final int vendorId;
  final String vendorName;
  final String businessName;
  final String vendorImage;
  final List<FuelReceivable> fuelReceivables;
  final List<dynamic> seedReceivables;
  final List<dynamic> pesticideReceivables;
  final List<dynamic> fertilizerReceivables;
  final List<dynamic> vehicleReceivables;
  final List<dynamic> machineryReceivables;
  final List<dynamic> toolReceivables;

  VendorReceivable({
    required this.vendorId,
    required this.vendorName,
    required this.businessName,
    required this.vendorImage,
    required this.fuelReceivables,
    required this.seedReceivables,
    required this.pesticideReceivables,
    required this.fertilizerReceivables,
    required this.vehicleReceivables,
    required this.machineryReceivables,
    required this.toolReceivables,
  });

  factory VendorReceivable.fromJson(Map<String, dynamic> json) {
    return VendorReceivable(
      vendorId: json['vendor_id'],
      vendorName: json['vendor_name'],
      businessName: json['business_name'],
      vendorImage: json['vendor_image'],
      fuelReceivables:
          (json['fuel_receivables'] as List)
              .map((e) => FuelReceivable.fromJson(e))
              .toList(),
      seedReceivables: json['seed_receivables'] ?? [],
      pesticideReceivables: json['pesticide_receivables'] ?? [],
      fertilizerReceivables: json['fertilizer_receivables'] ?? [],
      vehicleReceivables: json['vehicle_receivables'] ?? [],
      machineryReceivables: json['machinery_receivables'] ?? [],
      toolReceivables: json['tool_receivables'] ?? [],
    );
  }
}

class FuelReceivable {
  final int fuelPurchaseId;
  final String purchaseDate;
  final String inventoryType;
  final String inventoryItem;
  final double totalPurchaseAmount;
  final double amountPaid;
  final double receivedAmount;
  final double toReceiveAmount;

  FuelReceivable({
    required this.fuelPurchaseId,
    required this.purchaseDate,
    required this.inventoryType,
    required this.inventoryItem,
    required this.totalPurchaseAmount,
    required this.amountPaid,
    required this.receivedAmount,
    required this.toReceiveAmount,
  });

  factory FuelReceivable.fromJson(Map<String, dynamic> json) {
    return FuelReceivable(
      fuelPurchaseId: json['fuel_purchase_id'],
      purchaseDate: json['purchase_date'],
      inventoryType: json['inventory_type'],
      inventoryItem: json['inventory_item'],
      totalPurchaseAmount: (json['total_purchase_amount'] as num).toDouble(),
      amountPaid: (json['amount_paid'] as num).toDouble(),
      receivedAmount: (json['received_amount'] as num).toDouble(),
      toReceiveAmount: (json['toreceive_amount'] as num).toDouble(),
    );
  }
}

class CustomerReceivable {
  final int customerId;
  final String customerName;
  final String shopName;
  final String customerImage;
  final List<Sale> sales;

  CustomerReceivable({
    required this.customerId,
    required this.customerName,
    required this.shopName,
    required this.customerImage,
    required this.sales,
  });

  factory CustomerReceivable.fromJson(Map<String, dynamic> json) {
    return CustomerReceivable(
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      shopName: json['shop_name'],
      customerImage: json['customer_image'],
      sales: (json['sales'] as List).map((e) => Sale.fromJson(e)).toList(),
    );
  }
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

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      salesId: json['sales_id'],
      salesDate: json['sales_date'],
      cropId: json['crop_id'],
      cropName: json['crop_name'],
      totalSalesAmount: (json['total_sales_amount'] as num).toDouble(),
      amountPaid: (json['amount_paid'] as num).toDouble(),
      receivedAmount: (json['received_amount'] as num).toDouble(),
      toPayAmount: (json['topay_amount'] as num).toDouble(),
    );
  }
}
