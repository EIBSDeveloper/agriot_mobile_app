import 'package:argiot/src/app/modules/expense/model/document.dart';

class DocumentCategory {
  final int categoryId;
  final List<Document> documents;

  DocumentCategory({required this.categoryId, required this.documents});

  factory DocumentCategory.fromJson(Map<String, dynamic> json) => DocumentCategory(
      categoryId: json['category_id'] ?? 0,
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => Document.fromJson(doc))
          .toList(),
    );
}
