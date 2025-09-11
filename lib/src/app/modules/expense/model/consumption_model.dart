class FuelConsumptionModel {
  // final List<Document> documents;

  FuelConsumptionModel({
    required this.dateOfConsumption,
    required this.crop,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.inventoryItems,
    required this.description,
    required this.farmer,
    required this.quantityUtilized,
    // required this.documents,
  });
  final String dateOfConsumption;
  final int crop;
  final int inventoryType;
  final int inventoryCategory;
  final int inventoryItems;
  final String description;
  final String farmer;
  final double quantityUtilized;

  Map<String, dynamic> toJson() => {
    'date_of_consumption': dateOfConsumption,
    'crop': crop,
    'inventory_type': inventoryType,
    'inventory_category': inventoryCategory,
    'inventory_items': inventoryItems,
    'description': description,
    'farmer': farmer,
    'quantity_utilized': quantityUtilized.toString(),
    // 'documents': documents.map((doc) => doc.toJson()).toList(),
  };
}
