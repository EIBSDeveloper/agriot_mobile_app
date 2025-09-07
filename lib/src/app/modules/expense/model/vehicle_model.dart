import 'package:argiot/src/app/modules/expense/model/document_model.dart';

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

  Map<String, dynamic> toJson() => {
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
      'fuel_capacity': fuelCapacity ?? 0,
      'average_mileage': averageMileage ?? 0,
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
