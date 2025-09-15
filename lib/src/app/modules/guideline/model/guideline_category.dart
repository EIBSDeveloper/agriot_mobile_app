class        GuidelineCategory {
  GuidelineCategory({required this.id, required this.name, this.description});

  factory GuidelineCategory.fromJson(Map<String, dynamic> json) =>
      GuidelineCategory(
        id: json['id'],
        name: json['name'],
        description: json['description'],
      );
  final int id;
  final String name;
  final String? description;
}
