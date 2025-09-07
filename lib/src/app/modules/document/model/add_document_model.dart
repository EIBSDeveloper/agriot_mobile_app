class AddDocumentModel {
  AddDocumentModel({
    this.fileType,
    this.isNew = false,
    this.newFileType,
    this.documents,
  });
  final int? fileType;
  final bool isNew;
  final String? newFileType;
  final List? documents;

  Map<String, dynamic> toJson() => {
    if (!isNew) "file_type": fileType,
    if (isNew) "new_file_type": newFileType,
    "documents": documents ?? [],
  };
}
