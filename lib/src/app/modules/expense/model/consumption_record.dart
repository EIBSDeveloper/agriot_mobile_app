class ConsumptionRecord {
  final int id;
  final double? quantityUtilized;
  final DateTime dateOfConsumption;
  final String description;
  final String? crop;
  final double availableQuantity;

  ConsumptionRecord({
    required this.id,
    required this.quantityUtilized,
    required this.dateOfConsumption,
    required this.description,
    required this.crop,
    required this.availableQuantity,
  });

  factory ConsumptionRecord.fromJson(Map<String, dynamic> json) => ConsumptionRecord(
      id: json['id'],
      crop: json['crop_name'],
      quantityUtilized: double.tryParse(
        json['quantity_utilized']?.toString() ?? '',
      ),
      dateOfConsumption: DateTime.parse(json['date_of_consumption']),
      description: json['description'] ?? '',
      availableQuantity:
          double.tryParse(json['available_quans']?.toString() ?? '0') ?? 0,
    );
}
