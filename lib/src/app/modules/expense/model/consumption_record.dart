
class ConsumptionItem {
    final int id;
    final int? quantity;
    final DateTime dateOfConsumption;
    final double? startKilometer;
    final double? endKilometer;
    final double? usageHours;
    final int? rental;
    final int? cropId;
    final String? cropName;

    ConsumptionItem({
    required    this.id,
        this.quantity,
        required   this.dateOfConsumption,
        this.startKilometer,
        this.endKilometer,
        this.usageHours,
        this.rental,
        this.cropId,
        this.cropName,
    });

    factory ConsumptionItem.fromJson(Map<String, dynamic> json) => ConsumptionItem(
        id: json["id"],
        quantity: json["quantity"],
        dateOfConsumption: json["date_of_consumption"] == null ? DateTime.now() : DateTime.parse(json["date_of_consumption"]),
        startKilometer: json["start_kilometer"],
        endKilometer: json["end_kilometer"],
        usageHours: json["usage_hours"],
        rental: json["rental"],
        cropId: json["crop_id"],
        cropName: json["crop_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "quantity": quantity,
        "date_of_consumption": "${dateOfConsumption.year.toString().padLeft(4, '0')}-${dateOfConsumption.month.toString().padLeft(2, '0')}-${dateOfConsumption.day.toString().padLeft(2, '0')}",
        "start_kilometer": startKilometer,
        "end_kilometer": endKilometer,
        "usage_hours": usageHours,
        "rental": rental,
        "crop_id": cropId,
        "crop_name": cropName,
    };
}
