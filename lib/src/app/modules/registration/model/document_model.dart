import 'package:file_picker/file_picker.dart';
import './dropdown_item.dart';

class DocumentItem {
  final int? id;
  final DropdownItem? type;
  final PlatformFile? file;

  DocumentItem({
    this.id,
    this.type,
    this.file,
  });

  DocumentItem copyWith({
    DropdownItem? type,
    PlatformFile? file,
  }) {
    return DocumentItem(
      type: type ?? this.type,
      file: file ?? this.file,
    );
  }
}