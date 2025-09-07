class DocumentModel {
  final int fileType;
  final List<String> documents;

  DocumentModel({required this.fileType, required this.documents});

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
      fileType: json['file_type'],
      documents: List<String>.from(json['documents']),
    );

  Map<String, dynamic> toJson() => {'file_type': fileType, 'documents': documents};
}
