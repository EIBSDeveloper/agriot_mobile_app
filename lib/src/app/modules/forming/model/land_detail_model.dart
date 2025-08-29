
class CropCardModel
 {
  final int id;
  final String name;
  final String? img;
  final double expense;
  final double sales;
  final int totalScheduleCount;
  final int completedScheduleCount;

  CropCardModel({
    required this.id,
    required this.name,
    this.img,
    required this.expense,
    required this.sales,
    required this.totalScheduleCount,
    required this.completedScheduleCount,
  });

  factory CropCardModel.fromJson(Map<String, dynamic> json) {
    var json2 = json['crop'];
    var name = json['name']??json2['name'];
    return CropCardModel(
      id: json['id'],
      name: name,
      img: json['img'],
      expense: json['expense']?.toDouble() ?? 0.0,
      sales: json['sales']?.toDouble() ?? 0.0,
      totalScheduleCount: json['total_schedule_count'] ?? json['crop_schedule_count'] ,
      completedScheduleCount: json['completed_schedule_count'] ?? json['crop_schedule_completed_count'],
    );
  }
}