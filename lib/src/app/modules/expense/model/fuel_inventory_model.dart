
class PurchaseDetailModel {
    final int? id;
    final DateTime? dateOfConsumption;
    final String? purchaseAmount;
    final InventoryItems? vendor;
    final InventoryItems? inventoryType;
    final InventoryItems? inventoryItems;
    final dynamic quantityUnit;
    final int? status;
    final dynamic registerNumber;
    final dynamic ownerName;
    final dynamic dateOfRegistration;
    final dynamic engineNumber;
    final dynamic chasisNumber;
    final int? runningKilometer;
    final int? averageMileage;
    final dynamic insurance;
    final dynamic companyName;
    final dynamic insuranceNo;
    final int? insuranceAmount;
    final dynamic insuranceStartDate;
    final dynamic insuranceEndDate;
    final dynamic insuranceRenewalDate;
    final int? fuelCapacity;
    final dynamic warrantyStartDate;
    final dynamic warrantyEndDate;
    final dynamic description;
    final List<dynamic>? documents;
    final String? quantity;
    final String? unitType;

    PurchaseDetailModel({
        this.id,
        this.dateOfConsumption,
        this.purchaseAmount,
        this.vendor,
        this.inventoryType,
        this.inventoryItems,
        this.quantityUnit,
        this.status,
        this.registerNumber,
        this.ownerName,
        this.dateOfRegistration,
        this.engineNumber,
        this.chasisNumber,
        this.runningKilometer,
        this.averageMileage,
        this.insurance,
        this.companyName,
        this.insuranceNo,
        this.insuranceAmount,
        this.insuranceStartDate,
        this.insuranceEndDate,
        this.insuranceRenewalDate,
        this.fuelCapacity,
        this.warrantyStartDate,
        this.warrantyEndDate,
        this.description,
        this.documents,
        this.quantity,
        this.unitType,
    });

    factory PurchaseDetailModel.fromJson(Map<String, dynamic> json) => PurchaseDetailModel(
        id: json["id"],
        dateOfConsumption: json["date_of_consumption"] == null ? null : DateTime.parse(json["date_of_consumption"]),
        purchaseAmount: json["purchase_amount"],
        vendor: json["vendor"] == null ? null : InventoryItems.fromJson(json["vendor"]),
        inventoryType: json["inventory_type"] == null ? null : InventoryItems.fromJson(json["inventory_type"]),
        inventoryItems: json["inventory_items"] == null ? null : InventoryItems.fromJson(json["inventory_items"]),
        quantityUnit: json["quantity_unit"],
        status: json["status"],
        registerNumber: json["register_number"],
        ownerName: json["owner_name"],
        dateOfRegistration: json["date_of_registration"],
        engineNumber: json["engine_number"],
        chasisNumber: json["chasis_number"],
        runningKilometer: json["running_kilometer"],
        averageMileage: json["average_mileage"],
        insurance: json["insurance"],
        companyName: json["company_name"],
        insuranceNo: json["insurance_no"],
        insuranceAmount: json["insurance_amount"],
        insuranceStartDate: json["insurance_start_date"],
        insuranceEndDate: json["insurance_end_date"],
        insuranceRenewalDate: json["insurance_renewal_date"],
        fuelCapacity: json["fuel_capacity"],
        warrantyStartDate: json["warranty_start_date"],
        warrantyEndDate: json["warranty_end_date"],
        description: json["description"],
        documents: json["documents"] == null ? [] : List<dynamic>.from(json["documents"]!.map((x) => x)),
        quantity: json["quantity"],
        unitType: json["unit_type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "date_of_consumption": "${dateOfConsumption!.year.toString().padLeft(4, '0')}-${dateOfConsumption!.month.toString().padLeft(2, '0')}-${dateOfConsumption!.day.toString().padLeft(2, '0')}",
        "purchase_amount": purchaseAmount,
        "vendor": vendor?.toJson(),
        "inventory_type": inventoryType?.toJson(),
        "inventory_items": inventoryItems?.toJson(),
        "quantity_unit": quantityUnit,
        "status": status,
        "register_number": registerNumber,
        "owner_name": ownerName,
        "date_of_registration": dateOfRegistration,
        "engine_number": engineNumber,
        "chasis_number": chasisNumber,
        "running_kilometer": runningKilometer,
        "average_mileage": averageMileage,
        "insurance": insurance,
        "company_name": companyName,
        "insurance_no": insuranceNo,
        "insurance_amount": insuranceAmount,
        "insurance_start_date": insuranceStartDate,
        "insurance_end_date": insuranceEndDate,
        "insurance_renewal_date": insuranceRenewalDate,
        "fuel_capacity": fuelCapacity,
        "warranty_start_date": warrantyStartDate,
        "warranty_end_date": warrantyEndDate,
        "description": description,
        "documents": documents == null ? [] : List<dynamic>.from(documents!.map((x) => x)),
        "quantity": quantity,
        "unit_type": unitType,
    };
}


class InventoryItems {
    final int id;
    final String name;

    InventoryItems({
      required  this.id,
    required    this.name,
    });

    factory InventoryItems.fromJson(Map<String, dynamic> json) => InventoryItems(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
