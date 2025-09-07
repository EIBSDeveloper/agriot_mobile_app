class DocumentCategoryDetail {
  final int id;
  final String name;

  DocumentCategoryDetail({required this.id, required this.name});

  factory DocumentCategoryDetail.fromJson(Map<String, dynamic> json) =>
      DocumentCategoryDetail(id: json['id'] ?? 0, name: json['name'] ?? '');
}
