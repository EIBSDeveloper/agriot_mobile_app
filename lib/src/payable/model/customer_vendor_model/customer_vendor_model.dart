// lib/model/vendor_customer_model.dart

class VendorCustomerResponse {
  final String detail;
  final VendorCustomerData data;

  VendorCustomerResponse({required this.detail, required this.data});

  factory VendorCustomerResponse.fromJson(Map<String, dynamic> json) {
    return VendorCustomerResponse(
      detail: json['detail'] ?? '',
      data: VendorCustomerData.fromJson(json['data'] ?? {}),
    );
  }
}

class VendorCustomerData {
  final List<VendorReceivable> vendorReceivables;
  final List<CustomerReceivable> customerReceivables;

  VendorCustomerData({
    required this.vendorReceivables,
    required this.customerReceivables,
  });

  factory VendorCustomerData.fromJson(Map<String, dynamic> json) {
    return VendorCustomerData(
      vendorReceivables:
          (json['vendor_receivables'] ?? json['vendor_payables'] ?? [])
              .map<VendorReceivable>((e) => VendorReceivable.fromJson(e))
              .toList(),
      customerReceivables:
          (json['customer_receivables'] ?? json['customer_payables'] ?? [])
              .map<CustomerReceivable>((e) => CustomerReceivable.fromJson(e))
              .toList(),
    );
  }
}

// ================== VENDOR ==================
class VendorReceivable {
  final int vendorId;
  final String vendorName;
  final String businessName;
  final String vendorImage;
  final List<FuelReceivable> fuelReceivables;
  final List<SeedReceivable> seedReceivables;
  final List<PesticideReceivable> pesticideReceivables;
  final List<FertilizerReceivable> fertilizerReceivables;
  final List<VehicleReceivable> vehicleReceivables;
  final List<MachineryReceivable> machineryReceivables;
  final List<ToolReceivable> toolReceivables;

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
      vendorId: json['vendor_id'] ?? 0,
      vendorName: json['vendor_name'] ?? '',
      businessName: json['business_name'] ?? '',
      vendorImage: json['vendor_image'] ?? '',
      fuelReceivables:
          (json['fuel_receivables'] ?? json['fuel_payables'] ?? [])
              .map<FuelReceivable>((e) => FuelReceivable.fromJson(e))
              .toList(),
      seedReceivables:
          (json['seed_receivables'] ?? json['seed_payables'] ?? [])
              .map<SeedReceivable>((e) => SeedReceivable.fromJson(e))
              .toList(),
      pesticideReceivables:
          (json['pesticide_receivables'] ?? json['pesticide_payables'] ?? [])
              .map<PesticideReceivable>((e) => PesticideReceivable.fromJson(e))
              .toList(),
      fertilizerReceivables:
          (json['fertilizer_receivables'] ?? json['fertilizer_payables'] ?? [])
              .map<FertilizerReceivable>(
                (e) => FertilizerReceivable.fromJson(e),
              )
              .toList(),
      vehicleReceivables:
          (json['vehicle_receivables'] ?? json['vehicle_payables'] ?? [])
              .map<VehicleReceivable>((e) => VehicleReceivable.fromJson(e))
              .toList(),
      machineryReceivables:
          (json['machinery_receivables'] ?? json['machinery_payables'] ?? [])
              .map<MachineryReceivable>((e) => MachineryReceivable.fromJson(e))
              .toList(),
      toolReceivables:
          (json['tool_receivables'] ?? json['tool_payables'] ?? [])
              .map<ToolReceivable>((e) => ToolReceivable.fromJson(e))
              .toList(),
    );
  }
}

// Generic structure for all purchase types
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
      fuelPurchaseId: json['fuel_purchase_id'] ?? 0,
      purchaseDate: json['purchase_date'] ?? '',
      inventoryType: json['inventory_type'] ?? '',
      inventoryItem: json['inventory_item'] ?? '',
      totalPurchaseAmount: (json['total_purchase_amount'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      receivedAmount: (json['received_amount'] ?? 0).toDouble(),
      toReceiveAmount: (json['toreceive_amount'] ?? 0).toDouble(),
    );
  }
}

class SeedReceivable {
  final int seedPurchaseId;
  final String purchaseDate;
  final String inventoryType;
  final String inventoryItem;
  final double totalPurchaseAmount;
  final double amountPaid;
  final double receivedAmount;
  final double toReceiveAmount;

  SeedReceivable({
    required this.seedPurchaseId,
    required this.purchaseDate,
    required this.inventoryType,
    required this.inventoryItem,
    required this.totalPurchaseAmount,
    required this.amountPaid,
    required this.receivedAmount,
    required this.toReceiveAmount,
  });

  factory SeedReceivable.fromJson(Map<String, dynamic> json) {
    return SeedReceivable(
      seedPurchaseId: json['seed_purchase_id'] ?? 0,
      purchaseDate: json['purchase_date'] ?? '',
      inventoryType: json['inventory_type'] ?? '',
      inventoryItem: json['inventory_item'] ?? '',
      totalPurchaseAmount: (json['total_purchase_amount'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      receivedAmount: (json['received_amount'] ?? 0).toDouble(),
      toReceiveAmount: (json['toreceive_amount'] ?? 0).toDouble(),
    );
  }
}

class PesticideReceivable {
  final int pesticidePurchaseId;
  final String purchaseDate;
  final String inventoryType;
  final String inventoryItem;
  final double totalPurchaseAmount;
  final double amountPaid;
  final double receivedAmount;
  final double toReceiveAmount;

  PesticideReceivable({
    required this.pesticidePurchaseId,
    required this.purchaseDate,
    required this.inventoryType,
    required this.inventoryItem,
    required this.totalPurchaseAmount,
    required this.amountPaid,
    required this.receivedAmount,
    required this.toReceiveAmount,
  });

  factory PesticideReceivable.fromJson(Map<String, dynamic> json) {
    return PesticideReceivable(
      pesticidePurchaseId: json['pesticide_purchase_id'] ?? 0,
      purchaseDate: json['purchase_date'] ?? '',
      inventoryType: json['inventory_type'] ?? '',
      inventoryItem: json['inventory_item'] ?? '',
      totalPurchaseAmount: (json['total_purchase_amount'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      receivedAmount: (json['received_amount'] ?? 0).toDouble(),
      toReceiveAmount: (json['toreceive_amount'] ?? 0).toDouble(),
    );
  }
}

class FertilizerReceivable {
  final int fertilizerPurchaseId;
  final String purchaseDate;
  final String inventoryType;
  final String inventoryItem;
  final double totalPurchaseAmount;
  final double amountPaid;
  final double receivedAmount;
  final double toReceiveAmount;

  FertilizerReceivable({
    required this.fertilizerPurchaseId,
    required this.purchaseDate,
    required this.inventoryType,
    required this.inventoryItem,
    required this.totalPurchaseAmount,
    required this.amountPaid,
    required this.receivedAmount,
    required this.toReceiveAmount,
  });

  factory FertilizerReceivable.fromJson(Map<String, dynamic> json) {
    return FertilizerReceivable(
      fertilizerPurchaseId: json['fertilizer_purchase_id'] ?? 0,
      purchaseDate: json['purchase_date'] ?? '',
      inventoryType: json['inventory_type'] ?? '',
      inventoryItem: json['inventory_item'] ?? '',
      totalPurchaseAmount: (json['total_purchase_amount'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      receivedAmount: (json['received_amount'] ?? 0).toDouble(),
      toReceiveAmount: (json['toreceive_amount'] ?? 0).toDouble(),
    );
  }
}

class VehicleReceivable {
  final int vehiclePurchaseId;
  final String purchaseDate;
  final String inventoryType;
  final String inventoryItem;
  final double totalPurchaseAmount;
  final double amountPaid;
  final double receivedAmount;
  final double toReceiveAmount;

  VehicleReceivable({
    required this.vehiclePurchaseId,
    required this.purchaseDate,
    required this.inventoryType,
    required this.inventoryItem,
    required this.totalPurchaseAmount,
    required this.amountPaid,
    required this.receivedAmount,
    required this.toReceiveAmount,
  });

  factory VehicleReceivable.fromJson(Map<String, dynamic> json) {
    return VehicleReceivable(
      vehiclePurchaseId: json['vehicle_purchase_id'] ?? 0,
      purchaseDate: json['purchase_date'] ?? '',
      inventoryType: json['inventory_type'] ?? '',
      inventoryItem: json['inventory_item'] ?? '',
      totalPurchaseAmount: (json['total_purchase_amount'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      receivedAmount: (json['received_amount'] ?? 0).toDouble(),
      toReceiveAmount: (json['toreceive_amount'] ?? 0).toDouble(),
    );
  }
}

class MachineryReceivable {
  final int machineryPurchaseId;
  final String purchaseDate;
  final String inventoryType;
  final String inventoryItem;
  final double totalPurchaseAmount;
  final double amountPaid;
  final double receivedAmount;
  final double toReceiveAmount;

  MachineryReceivable({
    required this.machineryPurchaseId,
    required this.purchaseDate,
    required this.inventoryType,
    required this.inventoryItem,
    required this.totalPurchaseAmount,
    required this.amountPaid,
    required this.receivedAmount,
    required this.toReceiveAmount,
  });

  factory MachineryReceivable.fromJson(Map<String, dynamic> json) {
    return MachineryReceivable(
      machineryPurchaseId: json['machinery_purchase_id'] ?? 0,
      purchaseDate: json['purchase_date'] ?? '',
      inventoryType: json['inventory_type'] ?? '',
      inventoryItem: json['inventory_item'] ?? '',
      totalPurchaseAmount: (json['total_purchase_amount'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      receivedAmount: (json['received_amount'] ?? 0).toDouble(),
      toReceiveAmount: (json['toreceive_amount'] ?? 0).toDouble(),
    );
  }
}

class ToolReceivable {
  final int toolPurchaseId;
  final String purchaseDate;
  final String inventoryType;
  final String inventoryItem;
  final double totalPurchaseAmount;
  final double amountPaid;
  final double receivedAmount;
  final double toReceiveAmount;

  ToolReceivable({
    required this.toolPurchaseId,
    required this.purchaseDate,
    required this.inventoryType,
    required this.inventoryItem,
    required this.totalPurchaseAmount,
    required this.amountPaid,
    required this.receivedAmount,
    required this.toReceiveAmount,
  });

  factory ToolReceivable.fromJson(Map<String, dynamic> json) {
    return ToolReceivable(
      toolPurchaseId: json['tool_purchase_id'] ?? 0,
      purchaseDate: json['purchase_date'] ?? '',
      inventoryType: json['inventory_type'] ?? '',
      inventoryItem: json['inventory_item'] ?? '',
      totalPurchaseAmount: (json['total_purchase_amount'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      receivedAmount: (json['received_amount'] ?? 0).toDouble(),
      toReceiveAmount: (json['toreceive_amount'] ?? 0).toDouble(),
    );
  }
}

// ================== CUSTOMER ==================
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
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      shopName: json['shop_name'] ?? '',
      customerImage: json['customer_image'] ?? '',
      sales:
          (json['sales'] as List<dynamic>?)
              ?.map((e) => Sale.fromJson(e))
              .toList() ??
          [],
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
      salesId: json['sales_id'] ?? 0,
      salesDate: json['sales_date'] ?? '',
      cropId: json['crop_id'] ?? 0,
      cropName: json['crop_name'] ?? '',
      totalSalesAmount: (json['total_sales_amount'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      receivedAmount: (json['received_amount'] ?? 0).toDouble(),
      toPayAmount: (json['topay_amount'] ?? 0).toDouble(),
    );
  }
}
