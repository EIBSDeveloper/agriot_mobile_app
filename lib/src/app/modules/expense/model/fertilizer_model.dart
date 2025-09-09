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
  final List? documents;

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
    this.documents,
  });

  Map<String, dynamic> toJson() => {
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
      'documents': documents,
    };
}
