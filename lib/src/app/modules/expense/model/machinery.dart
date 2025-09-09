class Machinery {
  final String dateOfConsumption;
  final int vendor;
  final int inventoryType;
  final int inventoryCategory;
  final int inventoryItems;
  final String machineryType;
  final int fuelCapacity;
  final String warrantyStartDate;
  final String warrantyEndDate;
  final String purchaseAmount;
  final String paidAmount;
  final String description;
  final List? documents;

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
    required this.documents,
  });

  Map<String, dynamic> toJson() => {
    'date_of_consumption': dateOfConsumption,
    'vendor': vendor,
    'inventory_type': inventoryType,
    'inventory_category': inventoryCategory,
    'inventory_items': inventoryItems,
    'machinery_type': machineryType,
    'fuel_capacity': fuelCapacity,
    if (warrantyStartDate.isNotEmpty) 'warranty_start_date': warrantyStartDate,
    if (warrantyEndDate.isNotEmpty) 'warranty_end_date': warrantyEndDate,
    "paid_amount": paidAmount,
    'purchase_amount': purchaseAmount,
    'description': description,
    'documents': documents,
  };
}
