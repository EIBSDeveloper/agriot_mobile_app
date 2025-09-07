class TaskCrop {
  final int id;
  final String name;
  final String cropImg;

  TaskCrop({required this.id, required this.name, required this.cropImg});

  factory TaskCrop.fromJson(Map<String, dynamic> json) => TaskCrop(
      id: json['id'],
      name: json['name'],
      cropImg: json['crop_img'],
    );
}
