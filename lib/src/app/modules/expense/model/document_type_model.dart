class DocumentTypeModel {
  DocumentTypeModel({required this.id, required this.name});

  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) =>
      DocumentTypeModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  final int id;
  final String name;
}
