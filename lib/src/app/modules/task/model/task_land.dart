class TaskLand {
  final int id;
  final String name;

  TaskLand({required this.id, required this.name});

  factory TaskLand.fromJson(Map<String, dynamic> json) => TaskLand(id: json['id'], name: json['name']);
}
