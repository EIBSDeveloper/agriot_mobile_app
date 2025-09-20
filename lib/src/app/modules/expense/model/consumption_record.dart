class ConsumptionItem {
  final int id;
  final int? quantity;
  final DateTime dateOfConsumption;
  final double? startKilometer;
  final double? endKilometer;
  final double? usageHours;
  final int? rental;
  final int? cropId;
  final String? unitType;
  final String? cropName;

  ConsumptionItem({
    required this.id,
    required this.dateOfConsumption,
    this.quantity,
    this.startKilometer,
    this.endKilometer,
    this.usageHours,
    this.rental,
    this.cropId,
    this.unitType,
    this.cropName,
  });

  factory ConsumptionItem.fromJson(Map<String, dynamic> json) =>
      ConsumptionItem(
        id: json["id"],
        quantity: json["quantity"],
        dateOfConsumption: json["date_of_consumption"] == null
            ? DateTime.now()
            : DateTime.parse(json["date_of_consumption"]),
        startKilometer: (json["start_kilometer"] as num?)?.toDouble(),
        endKilometer: (json["end_kilometer"] as num?)?.toDouble(),
        usageHours: (json["usage_hours"] as num?)?.toDouble(),
        rental: json["rental"],
        cropId: json["crop_id"],
        unitType: json["unit_type"],
        cropName: json["crop_name"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "date_of_consumption":
        "${dateOfConsumption.year.toString().padLeft(4, '0')}-${dateOfConsumption.month.toString().padLeft(2, '0')}-${dateOfConsumption.day.toString().padLeft(2, '0')}",
    "start_kilometer": startKilometer,
    "end_kilometer": endKilometer,
    "usage_hours": usageHours,
    "rental": rental,
    "crop_id": cropId,
    "unit_type": unitType,
    "crop_name": cropName,
  };
}
