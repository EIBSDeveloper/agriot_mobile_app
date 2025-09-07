class Task {
  final int id;
  final String cropType;
  final String cropImage;
  final String description;
  final String? status;

  Task({
    required this.id,
    required this.cropType,
    required this.cropImage,
    required this.description,
     this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
      id: json['id'],
      cropType: json['crop_type']?? json['crop_name'],
      cropImage: json['crop_image'],
      description: json['description'] ?? " ",
      status: json['schedule_status_name'] ,
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'crop_type': cropType,
      'crop_image': cropImage,
      'description': description,
    };
}
