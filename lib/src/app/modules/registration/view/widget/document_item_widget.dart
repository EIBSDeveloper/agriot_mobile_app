import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/input_card_style.dart';
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
                'document_number'.trParams({'number': '${index + 1}'}),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 8),
          InputCardStyle(
            child: DropdownButtonFormField<AppDropdownItem>(
              initialValue: item.type,
              decoration: InputDecoration(
                labelText: 'document_type'.tr,
                border: InputBorder.none,
                isDense: true,
              ),
              items: documentTypes
                  .map(
                    (type) => DropdownMenuItem<AppDropdownItem>(
                      value: type,
                      child: Text(type.name),
                    ),
                  )
                  .toList(),
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
              item.file == null ? 'select_document'.tr : 'document_selected'.tr,
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
