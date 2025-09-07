class ScheduleCrop {
  ScheduleCrop({required this.id, required this.name});

  factory ScheduleCrop.fromJson(Map<String, dynamic> json) =>
      ScheduleCrop(id: json['id'] ?? 0, name: json['name'] ?? '');
  final int id;
  final String name;
}
