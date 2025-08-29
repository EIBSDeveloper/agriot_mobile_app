import 'package:flutter/material.dart';

import '../../../../../core/app_style.dart';
import '../../model/document_model.dart';
import '../../model/dropdown_item.dart';

class DocumentItemWidget extends StatelessWidget {
  final int index;
  final DocumentItem item;
  final List<DropdownItem> documentTypes;
  final VoidCallback onRemove;
  final Function(DocumentItem) onChanged;
  final VoidCallback onPickDocument;

  const DocumentItemWidget({
    super.key,
    required this.index,
    required this.item,
    required this.documentTypes,
    required this.onRemove,
    required this.onChanged,
    required this.onPickDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Document #${index + 1}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              decoration: AppStyle.decoration.copyWith(
                color: const Color.fromARGB(137, 221, 234, 234),
                boxShadow: const [],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              height: 55,
              child: DropdownButtonFormField<DropdownItem>(
                value: item.type,
                decoration: InputDecoration(
                  labelText: 'Document Type',
                  border: InputBorder.none,
                  isDense: true,
                ),
                items: documentTypes.map((type) {
                  return DropdownMenuItem<DropdownItem>(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (value) => onChanged(item.copyWith(type: value)),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPickDocument,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text(
                item.file == null ? 'Select Document' : 'Document Selected',
              ),
            ),
            if (item.file != null) ...[
              SizedBox(height: 8),
              Text(
                item.file!.name,
                style: TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
