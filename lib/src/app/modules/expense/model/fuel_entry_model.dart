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
  final List? document;

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
    required this.document,
  });

  Map<String, dynamic> toJson() => {
    'date_of_consumption': dateOfConsumption,
    'vendor': vendor,
    'inventory_type': inventoryType,
    'inventory_category': inventoryCategory,
    'inventory_items': inventoryItems,
    'quantity': quantity,
    'purchase_amount': purchaseAmount,
    "paid_amount": paidAmount,
    'description': description,
    'documents': document,
  };
}
