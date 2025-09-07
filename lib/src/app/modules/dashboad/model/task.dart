// class Task {
//   final int id;
//   final String name;
//   final String startDate;
//   final String endDate;
//   final String status;
//   final String landName;
//   final String cropName;
//   final String cropImage;

//   Task({
//     required this.id,
//     required this.name,
//     required this.startDate,
//     required this.endDate,
//     required this.status,
//     required this.landName,
//     required this.cropName,
//     required this.cropImage,
//   });

//   factory Task.fromJson(Map<String, dynamic> json) => Task(
//     id: json['id'],
//     name: json['schedule'] ?? " ",
//     startDate: json['start_date'],
//     endDate: json['end_date'],
//     status: json['schedule_status_name'],
//     landName: json['land_name'],
//     cropName: json['crop_name'],
//     cropImage: json['crop_image'],
//   );
// }
