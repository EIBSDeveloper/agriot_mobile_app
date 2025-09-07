import 'package:argiot/src/app/modules/expense/model/document_category_detail.dart';

class Document {
  final int id;
  final DocumentCategoryDetail documentCategory;
  final String uploadDocument;
  Document({
    required this.id,
    required this.documentCategory,
    required this.uploadDocument,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
      id: json['id'] ?? 0,
      documentCategory: DocumentCategoryDetail.fromJson(
        json['document_category'] ?? {},
      ),
      uploadDocument: json['upload_document'] ?? '',
    );
}
