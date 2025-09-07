class FileType {
  final int id;
  final int docType;
  final String? name;
  final String? description;

  FileType({
    required this.id,
    required this.docType,
    required this.name,
    required this.description,
  });

  factory FileType.fromJson(Map<String, dynamic> json) => FileType(
      id: json['id'],
      docType: json['doctype'],
      name: json['name'],
      description: json['description']??"",
    );
}
