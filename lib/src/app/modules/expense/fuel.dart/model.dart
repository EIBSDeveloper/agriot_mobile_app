import '../../task/view/screens/screen.dart';

class Machinery {
  final String dateOfConsumption;
  final int vendor;
  final int inventoryType;
  final int inventoryCategory;
  final int inventoryItems;
  final String machineryType;
  final String fuelCapacity;
  final String warrantyStartDate;
  final String warrantyEndDate;
  final String purchaseAmount;
  final String paidAmount;
  final String description;
  // final List<Document> documents;

  Machinery({
    required this.dateOfConsumption,
    required this.vendor,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.inventoryItems,
    required this.machineryType,
    required this.fuelCapacity,
    required this.paidAmount,
    required this.warrantyStartDate,
    required this.warrantyEndDate,
    required this.purchaseAmount,
    required this.description,
    // required this.documents,
  });

  Map<String, dynamic> toJson() {
    return {
      'date_of_consumption': dateOfConsumption,
      'vendor': vendor,
      'inventory_type': inventoryType,
      'inventory_category': inventoryCategory,
      'inventory_items': inventoryItems,
      'machinery_type': machineryType,
      'fuel_capacity': fuelCapacity,
      'warranty_start_date': warrantyStartDate,
      'warranty_end_date': warrantyEndDate,
      "paid_amount": paidAmount,
      'purchase_amount': purchaseAmount,
      'description': description,
      // 'documents': documents.map((doc) => doc.toJson()).toList(),
    };
  }
}

class Customer extends NamedItem {
  @override
  final int id;
  @override
  final String name;
  final String shopName;

  Customer({required this.id, required this.name, this.shopName = ''});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['customer_name'] ?? '',
      shopName: json['shop_name'] ?? '',
    );
  }
}

class VehicleModel {
  final int? id;
  final int farmerId;
  final DateTime dateOfConsumption;
  final int vendor;
  final int inventoryType;
  final int inventoryCategory;
  final int inventoryItems;
  final String registerNumber;
  final String ownerName;
  final DateTime? dateOfRegistration;
  final DateTime? registrationValidTill;
  final String? engineNumber;
  final String? chasisNumber;
  final double runningKilometer;
  final int? serviceFrequency;
  final int? serviceFrequencyUnit;
  final double? fuelCapacity;
  final double? averageMileage;
  final double purchaseAmount;
  final bool insurance;
  final String? companyName;
  final String? insuranceNo;
  final double? insuranceAmount;
  final DateTime? insuranceStartDate;
  final DateTime? insuranceEndDate;
  final DateTime? insuranceRenewalDate;
  final String paidAmount;
  final String? description;
  final List<DocumentModel>? documents;

  VehicleModel({
    this.id,
    required this.farmerId,
    required this.dateOfConsumption,
    required this.vendor,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.inventoryItems,
    required this.registerNumber,
    required this.ownerName,
    this.dateOfRegistration,
    this.registrationValidTill,
    required this.paidAmount,
    this.engineNumber,
    this.chasisNumber,
    required this.runningKilometer,
    this.serviceFrequency,
    this.serviceFrequencyUnit,
    this.fuelCapacity,
    this.averageMileage,
    required this.purchaseAmount,
    required this.insurance,
    this.companyName,
    this.insuranceNo,
    this.insuranceAmount,
    this.insuranceStartDate,
    this.insuranceEndDate,
    this.insuranceRenewalDate,
    this.description,
    this.documents,
  });

  Map<String, dynamic> toJson() {
    return {
      'farmer_id': farmerId,
      'date_of_consumption': dateOfConsumption.toIso8601String().split('T')[0],
      'vendor': vendor,
      'inventory_type': inventoryType,
      'inventory_category': inventoryCategory,
      'inventory_items': inventoryItems,
      'register_number': registerNumber,
      'owner_name': ownerName,
      'date_of_registration': dateOfRegistration?.toIso8601String().split(
        'T',
      )[0],
      'registration_valid_till': registrationValidTill?.toIso8601String().split(
        'T',
      )[0],

      'engine_number': engineNumber,
      'chasis_number': chasisNumber,
      'running_kilometer': runningKilometer,
      'service_frequency': serviceFrequency,
      'service_frequency_unit': serviceFrequencyUnit,
      'fuel_capacity': fuelCapacity,
      'average_mileage': averageMileage,
      'purchase_amount': purchaseAmount,
      "paid_amount": paidAmount,
      'insurance': insurance,
      if (insurance) 'company_name': companyName,
      if (insurance) 'insurance_no': insuranceNo,
      if (insurance) 'insurance_amount': insuranceAmount,
      if (insurance)
        'insurance_start_date': insuranceStartDate?.toIso8601String().split(
          'T',
        )[0],
      if (insurance)
        'insurance_end_date': insuranceEndDate?.toIso8601String().split('T')[0],
      if (insurance)
        'insurance_renewal_date': insuranceRenewalDate?.toIso8601String().split(
          'T',
        )[0],
      'description': description,
      'documents': documents?.map((x) => x.toJson()).toList(),
    };
  }
}

class FuelEntryModel {
  final String dateOfConsumption;
  final int vendor;
  final int inventoryType;
  final int inventoryCategory;
  final int inventoryItems;
  final String quantity;
  final String purchaseAmount;
  final String paidAmount;
  final String? description;

  FuelEntryModel({
    required this.dateOfConsumption,
    required this.vendor,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.inventoryItems,
    required this.quantity,
    required this.purchaseAmount,
    required this.paidAmount,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'date_of_consumption': dateOfConsumption,
      'vendor': vendor,
      'inventory_type': inventoryType,
      'inventory_category': inventoryCategory,
      'inventory_items': inventoryItems,
      'quantity': quantity,
      'purchase_amount': purchaseAmount,
      "paid_amount": paidAmount,
      'description': description,
    };
  }
}

class DocumentModel {
  final int fileType;
  final List<String> documents;

  DocumentModel({required this.fileType, required this.documents});

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      fileType: json['file_type'],
      documents: List<String>.from(json['documents']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'file_type': fileType, 'documents': documents};
  }
}

class FertilizerModel {
  final String dateOfConsumption;
  final int vendor;
  final int inventoryType;
  final int inventoryCategory;
  final int inventoryItems;
  final String quantity;
  final int quantityUnit;
  final String purchaseAmount;
  final String paidAmount;
  final String? description;

  FertilizerModel({
    required this.dateOfConsumption,
    required this.vendor,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.inventoryItems,
    required this.quantity,
    required this.quantityUnit,
    required this.paidAmount,
    required this.purchaseAmount,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'date_of_consumption': dateOfConsumption,
      'vendor': vendor,
      'inventory_type': inventoryType,
      'inventory_category': inventoryCategory,
      'inventory_items': inventoryItems,
      'quantity': quantity,
      'quantity_unit': quantityUnit,
      'purchase_amount': purchaseAmount,
      "paid_amount": paidAmount,
      'description': description,
    };
  }
}

class FertilizerResponse {
  final bool success;
  final String message;

  FertilizerResponse({required this.success, required this.message});

  factory FertilizerResponse.fromJson(Map<String, dynamic> json) {
    return FertilizerResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class InventoryCategory {
  final int id;
  final String name;
  final String type;

  InventoryCategory({required this.id, required this.name, required this.type});

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    return InventoryCategory(
      id: json['id'],
      name: json['name'],
      type: json['inventory_type']?['name'] ?? '',
    );
  }
}

class InventoryItem {
  final int id;
  final String name;

  InventoryItem({required this.id, required this.name});

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(id: json['id'], name: json['name']);
  }
}

class ConsumptionRecord {
  final int id;
  final double quantityUtilized;
  final DateTime dateOfConsumption;
  final String description;
  final String crop;
  final double availableQuantity;

  ConsumptionRecord({
    required this.id,
    required this.quantityUtilized,
    required this.dateOfConsumption,
    required this.description,
    required this.crop,
    required this.availableQuantity,
  });

  factory ConsumptionRecord.fromJson(Map<String, dynamic> json) {
    return ConsumptionRecord(
      id: json['id'],
      crop: json['crop_name'],
      quantityUtilized:
          double.tryParse(json['quantity_utilized']?.toString() ?? '0') ?? 0,
      dateOfConsumption: DateTime.parse(json['date_of_consumption']),
      description: json['description'] ?? '',
      availableQuantity:
          double.tryParse(json['available_quans']?.toString() ?? '0') ?? 0,
    );
  }
}

class PurchaseRecord {
  final int id;
  final String vendorName;
  final double quantity;
  final String quantityUnit;
  final double purchaseAmount;
  final DateTime date;
  final String description;

  PurchaseRecord({
    required this.id,
    required this.vendorName,
    required this.quantity,
    required this.quantityUnit,
    required this.purchaseAmount,
    required this.date,
    required this.description,
  });

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: json['id'],
      vendorName: json['vendor']?['name'] ?? 'Unknown',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      quantityUnit: json['quantity_unit'] ?? '',
      purchaseAmount:
          double.tryParse(json['purchase_amount']?.toString() ?? '0') ?? 0,
      date: DateTime.parse(json['created_at']),
      description: json['description'] ?? '',
    );
  }
}

class InventoryData {
  final List<ConsumptionRecord> consumptionRecords;
  final List<PurchaseRecord> purchaseRecords;

  InventoryData({
    required this.consumptionRecords,
    required this.purchaseRecords,
  });
}
