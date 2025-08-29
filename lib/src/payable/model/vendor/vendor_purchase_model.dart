// lib/model/vendor_purchase_model.dart
class VendorPurchaseResponse {
  final String detail;
  final VendorInventoryData vendorInventoryData;

  VendorPurchaseResponse({
    required this.detail,
    required this.vendorInventoryData,
  });

  factory VendorPurchaseResponse.fromJson(Map<String, dynamic> json) {
    return VendorPurchaseResponse(
      detail: json['detail'] ?? '',
      vendorInventoryData: VendorInventoryData.fromJson(
        json['vendor_inventory_data'] ?? {},
      ),
    );
  }
}

class VendorInventoryData {
  final List<VendorPayable>? payables;
  final List<VendorPayable>? receivables;

  VendorInventoryData({this.payables, this.receivables});

  factory VendorInventoryData.fromJson(Map<String, dynamic> json) {
    return VendorInventoryData(
      payables:
          json['payables'] != null
              ? List<VendorPayable>.from(
                json['payables'].map((x) => VendorPayable.fromJson(x)),
              )
              : [],
      receivables:
          json['receivables'] != null
              ? List<VendorPayable>.from(
                json['receivables'].map((x) => VendorPayable.fromJson(x)),
              )
              : [],
    );
  }
}

class VendorPayable {
  final int vendorId;
  final String vendorName;
  final String businessName;
  final String vendorImage;
  final List<Purchase> fuelPurchases;
  final List<Purchase> seedPurchases;
  final List<Purchase> pesticidePurchases;
  final List<Purchase> fertilizerPurchases;
  final List<Purchase> vehiclePurchases;
  final List<Purchase> machineryPurchases;
  final List<Purchase> toolPurchases;

  VendorPayable({
    required this.vendorId,
    required this.vendorName,
    required this.businessName,
    required this.vendorImage,
    required this.fuelPurchases,
    required this.seedPurchases,
    required this.pesticidePurchases,
    required this.fertilizerPurchases,
    required this.vehiclePurchases,
    required this.machineryPurchases,
    required this.toolPurchases,
  });

  factory VendorPayable.fromJson(Map<String, dynamic> json) {
    return VendorPayable(
      vendorId: json['vendor_id'] ?? 0,
      vendorName: json['vendor_name'] ?? '',
      businessName: json['business_name'] ?? '',
      vendorImage: json['vendor_image'] ?? '',
      fuelPurchases:
          json['fuel_purchases'] != null
              ? List<Purchase>.from(
                json['fuel_purchases'].map((x) => Purchase.fromJson(x)),
              )
              : json['fuel_receivables'] != null
              ? List<Purchase>.from(
                json['fuel_receivables'].map((x) => Purchase.fromJson(x)),
              )
              : [],
      seedPurchases:
          json['seed_purchases'] != null
              ? List<Purchase>.from(
                json['seed_purchases'].map((x) => Purchase.fromJson(x)),
              )
              : json['seed_receivables'] != null
              ? List<Purchase>.from(
                json['seed_receivables'].map((x) => Purchase.fromJson(x)),
              )
              : [],
      pesticidePurchases:
          json['pesticide_purchases'] != null
              ? List<Purchase>.from(
                json['pesticide_purchases'].map((x) => Purchase.fromJson(x)),
              )
              : json['pesticide_receivables'] != null
              ? List<Purchase>.from(
                json['pesticide_receivables'].map((x) => Purchase.fromJson(x)),
              )
              : [],
      fertilizerPurchases:
          json['fertilizer_purchases'] != null
              ? List<Purchase>.from(
                json['fertilizer_purchases'].map((x) => Purchase.fromJson(x)),
              )
              : json['fertilizer_receivables'] != null
              ? List<Purchase>.from(
                json['fertilizer_receivables'].map((x) => Purchase.fromJson(x)),
              )
              : [],
      vehiclePurchases:
          json['vehicle_purchases'] != null
              ? List<Purchase>.from(
                json['vehicle_purchases'].map((x) => Purchase.fromJson(x)),
              )
              : json['vehicle_receivables'] != null
              ? List<Purchase>.from(
                json['vehicle_receivables'].map((x) => Purchase.fromJson(x)),
              )
              : [],
      machineryPurchases:
          json['machinery_purchases'] != null
              ? List<Purchase>.from(
                json['machinery_purchases'].map((x) => Purchase.fromJson(x)),
              )
              : json['machinery_receivables'] != null
              ? List<Purchase>.from(
                json['machinery_receivables'].map((x) => Purchase.fromJson(x)),
              )
              : [],
      toolPurchases:
          json['tool_purchases'] != null
              ? List<Purchase>.from(
                json['tool_purchases'].map((x) => Purchase.fromJson(x)),
              )
              : json['tool_receivables'] != null
              ? List<Purchase>.from(
                json['tool_receivables'].map((x) => Purchase.fromJson(x)),
              )
              : [],
    );
  }
}

class Purchase {
  final int id;

  final String purchaseDate;
  final String inventoryType;
  final String inventoryItem;
  final double totalPurchaseAmount;
  final double amountPaid;
  final double receivedAmount;
  final double topayAmount;

  Purchase({
    required this.id,

    required this.purchaseDate,
    required this.inventoryType,
    required this.inventoryItem,
    required this.totalPurchaseAmount,
    required this.amountPaid,
    required this.receivedAmount,
    required this.topayAmount,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],

      purchaseDate: json['purchase_date'] ?? '',
      inventoryType: json['inventory_type'] ?? '',
      inventoryItem: json['inventory_item'] ?? '',
      totalPurchaseAmount: (json['total_purchase_amount'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      receivedAmount: (json['received_amount'] ?? 0).toDouble(),
      topayAmount:
          ((json['topay_amount'] ?? json['toreceive_amount']) ?? 0).toDouble(),
    );
  }
}
