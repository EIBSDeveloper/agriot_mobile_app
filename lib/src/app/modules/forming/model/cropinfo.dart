class Cropinfo {
  final int id;
  final String name;
  final String? cropType;
  final String? imageUrl;
  final String? description;
  final double? totalSales;
  final double? totalExpenses;

  Cropinfo({
    required this.id,
    required this.name,
    this.cropType,
    this.imageUrl,
    this.description,
    this.totalSales,
    this.totalExpenses,
  });

  factory Cropinfo.fromJson(Map<String, dynamic> json) => Cropinfo(
      id: json['id'] ?? json['crop_id'] ?? 0,
      name: json['name'] ?? json['crop'] ?? '',
      cropType: json['crop_type'],
      imageUrl: json['img'],
      description: json['description'],
      totalSales: json['total_sales_amount']?.toDouble(),
      totalExpenses: json['total_expenses_amount']?.toDouble(),
    );
}
