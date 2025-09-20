import '../../expense/model/inventory_item.dart';
import '../../expense/model/vendor.dart';
import 'inventory_item.dart';

class InventoryRecord {
  int id;
  String dateOfConsumption;
  String purchaseAmount;
  Vendor vendor;
  InventoryType inventoryType;
  InventoryItem inventoryItems;
  String? quantityUnit;
  int status;
  String? registerNumber;
  String? ownerName;
  String? dateOfRegistration;
  String? engineNumber;
  String? chasisNumber;
  int runningKilometer;
  int averageMileage;
  String? insurance;
  String? companyName;
  String? insuranceNo;
  int insuranceAmount;
  String? insuranceStartDate;
  String? insuranceEndDate;
  String? insuranceRenewalDate;
  int fuelCapacity;
  String? warrantyStartDate;
  String? warrantyEndDate;
  String? description;
  List<dynamic> documents;
  String quantity;
  String unitType;

  InventoryRecord({
    required this.id,
    required this.dateOfConsumption,
    required this.purchaseAmount,
    required this.vendor,
    required this.inventoryType,
    required this.inventoryItems,
    this.quantityUnit,
    required this.status,
    this.registerNumber,
    this.ownerName,
    this.dateOfRegistration,
    this.engineNumber,
    this.chasisNumber,
    required this.runningKilometer,
    required this.averageMileage,
    this.insurance,
    this.companyName,
    this.insuranceNo,
    required this.insuranceAmount,
    this.insuranceStartDate,
    this.insuranceEndDate,
    this.insuranceRenewalDate,
    required this.fuelCapacity,
    this.warrantyStartDate,
    this.warrantyEndDate,
    this.description,
    required this.documents,
    required this.quantity,
    required this.unitType,
  });

  factory InventoryRecord.fromJson(Map<String, dynamic> json) => InventoryRecord(
      id: json['id'],
      dateOfConsumption: json['date_of_consumption'],
      purchaseAmount: json['purchase_amount'],
      vendor: Vendor.fromJson(json['vendor']),
      inventoryType: InventoryType.fromJson(json['inventory_type']),
      inventoryItems: InventoryItem.fromJson(json['inventory_items']),
      quantityUnit: json['quantity_unit'],
      status: json['status'],
      registerNumber: json['register_number'],
      ownerName: json['owner_name'],
      dateOfRegistration: json['date_of_registration'],
      engineNumber: json['engine_number'],
      chasisNumber: json['chasis_number'],
      runningKilometer: json['running_kilometer'],
      averageMileage: json['average_mileage'],
      insurance: json['insurance'],
      companyName: json['company_name'],
      insuranceNo: json['insurance_no'],
      insuranceAmount: json['insurance_amount'],
      insuranceStartDate: json['insurance_start_date'],
      insuranceEndDate: json['insurance_end_date'],
      insuranceRenewalDate: json['insurance_renewal_date'],
      fuelCapacity: json['fuel_capacity'],
      warrantyStartDate: json['warranty_start_date'],
      warrantyEndDate: json['warranty_end_date'],
      description: json['description'],
      documents: List<dynamic>.from(json['documents'] ?? []),
      quantity: json['quantity'],
      unitType: json['unit_type'],
    );

}