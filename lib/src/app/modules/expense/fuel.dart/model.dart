
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
      'company_name': companyName,
      'insurance_no': insuranceNo,
      'insurance_amount': insuranceAmount,
      'insurance_start_date': insuranceStartDate?.toIso8601String().split(
        'T',
      )[0],
      'insurance_end_date': insuranceEndDate?.toIso8601String().split('T')[0],
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

