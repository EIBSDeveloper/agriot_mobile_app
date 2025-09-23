import 'package:argiot/src/app/modules/expense/model/fuel_inventory_model.dart';

import '../../document/document.dart';

class CunsumptionDetailModel {
    final int? id;
    final int? quantity;
    final DateTime? dateOfConsumption;
    final dynamic startKilometer;
    final dynamic endKilometer;
    final dynamic usageHours;
    final int? rental;
    final int? cropId;
    final String? cropName;
    final InventoryItems? inventoryItems;
    final InventoryItems? inventoryType;
    final String? description;
    final List<AddDocumentModel>? documents;

    CunsumptionDetailModel({
        this.id,
        this.quantity,
        this.dateOfConsumption,
        this.startKilometer,
        this.endKilometer,
        this.usageHours,
        this.rental,
        this.cropId,
        this.cropName,
        this.inventoryItems,
        this.inventoryType,
        this.description,
        this.documents,
    });

    factory CunsumptionDetailModel.fromJson(Map<String, dynamic> json) => CunsumptionDetailModel(
        id: json["id"],
        quantity: json["quantity"],
        dateOfConsumption: json["date_of_consumption"] == null ? null : DateTime.parse(json["date_of_consumption"]),
        startKilometer: json["start_kilometer"],
        endKilometer: json["end_kilometer"],
        usageHours: json["usage_hours"],
        rental: json["rental"],
        cropId: json["crop_id"],
        cropName: json["crop_name"],
        inventoryItems: json["inventory_items"] == null ? null : InventoryItems.fromJson(json["inventory_items"]),
        inventoryType: json["inventory_type"] == null ? null : InventoryItems.fromJson(json["inventory_type"]),
        description: json["description"],
        // documents: json["documents"] == null ? [] : AddDocumentModel.,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "quantity": quantity,
        "date_of_consumption": "${dateOfConsumption!.year.toString().padLeft(4, '0')}-${dateOfConsumption!.month.toString().padLeft(2, '0')}-${dateOfConsumption!.day.toString().padLeft(2, '0')}",
        "start_kilometer": startKilometer,
        "end_kilometer": endKilometer,
        "usage_hours": usageHours,
        "rental": rental,
        "crop_id": cropId,
        "crop_name": cropName,
        "inventory_items": inventoryItems?.toJson(),
        "inventory_type": inventoryType?.toJson(),
        "description": description,
        "documents": documents == null ? [] : List<dynamic>.from(documents!.map((x) => x)),
    };
}
