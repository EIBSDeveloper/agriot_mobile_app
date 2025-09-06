import 'package:flutter/material.dart';

import '../../../../../core/app_style.dart';
import '../../model/document_model.dart';
import '../../model/dropdown_item.dart';

class DocumentItemWidget extends StatelessWidget {
  final int index;
  final DocumentItem item;
  final List<AppDropdownItem> documentTypes;
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
  Widget build(BuildContext context) => Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Document #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: AppStyle.decoration.copyWith(
                color: const Color.fromARGB(137, 221, 234, 234),
                boxShadow: const [],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              height: 55,
              child: DropdownButtonFormField<AppDropdownItem>(
                initialValue: item.type,
                decoration: const InputDecoration(
                  labelText: 'Document Type',
                  border: InputBorder.none,
                  isDense: true,
                ),
                items: documentTypes.map((type) => DropdownMenuItem<AppDropdownItem>(
                    value: type,
                    child: Text(type.name),
                  )).toList(),
                onChanged: (value) => onChanged(item.copyWith(type: value)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPickDocument,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                item.file == null ? 'Select Document' : 'Document Selected',
              ),
            ),
            if (item.file != null) ...[
              const SizedBox(height: 8),
              Text(
                item.file!.name,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
}
