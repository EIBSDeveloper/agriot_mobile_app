import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';

import '../../../../widgets/input_card_style.dart';
// Often not needed for this pattern, but kept if you have other uses.

class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final String? labelText;
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;
  final String Function(T) displayItem;
  final bool isDense;
  final InputBorder? border;

  const SearchableDropdown({
    super.key,
    required this.label,
    this.labelText,
    required this.items,
    required this.onChanged,
    this.selectedItem,
    required this.displayItem,
    this.validator,
    this.isDense = true,
    this.border,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SearchableDropdownState<T> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  late TextEditingController _displayController;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController(
      text: _getDisplayText(widget.selectedItem),
    );
  }

  @override
  void didUpdateWidget(covariant SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      _displayController.text = _getDisplayText(widget.selectedItem);
    }
  }

  String _getDisplayText(T? item) {
    if (item == null) return '';
    return widget.displayItem(item);
  }

  @override
  Widget build(BuildContext context) => InputCardStyle(
    child: TextFormField(
      controller: _displayController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.labelText ?? widget.label,
        border: InputBorder.none,
        isDense: widget.isDense,
        contentPadding: EdgeInsets.zero,
        suffixIcon: const Icon(Icons.keyboard_arrow_down_outlined),
        errorStyle: const TextStyle(height: 0),
      ),
      onTap: _showSearchDialog,
      validator: (value) => widget.validator?.call(widget.selectedItem),
    ),
  );

  Future<void> _showSearchDialog() async {
    final T? selectedItem = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _SearchBottomSheet<T>(
        items: widget.items,
        displayItem: widget.displayItem,
        label: widget.label,
        validator: widget.validator,
        initialSearchText: _displayController.text,
      ),
    );

    if (selectedItem != null) {
      widget.onChanged(selectedItem);
      _displayController.text = _getDisplayText(selectedItem);
    } else {
      _displayController.text = _getDisplayText(widget.selectedItem);
    }
  }

  @override
  void dispose() {
    _displayController.dispose();
    super.dispose();
  }
}

class _SearchBottomSheet<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) displayItem;
  final String label;
  final String? initialSearchText;
  final FormFieldValidator<T>? validator;
  final void Function()? addNew;

  const _SearchBottomSheet({
    super.key,
    required this.items,
    required this.displayItem,
    required this.label,
    this.validator,
    this.addNew,
    this.initialSearchText,
  });

  @override
  __SearchBottomSheetState<T> createState() => __SearchBottomSheetState<T>();
}

class __SearchBottomSheetState<T> extends State<_SearchBottomSheet<T>> {
  late List<T> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchText != null) {
      _searchController.text = widget.initialSearchText!;
      _filterItems();
    } else {
      _filteredItems = widget.items;
    }
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final displayText = widget.displayItem(item);
          return displayText.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    expand: false,
    maxChildSize: 0.9,
    minChildSize: 0.4,
    initialChildSize: 0.7,
    builder: (context, scrollController) => GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        decoration: AppStyle.decoration.copyWith(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child:  InputCardStyle(
               
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search ${widget.label}',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                if (widget.addNew != null)
                  ElevatedButton(
                    onPressed: widget.addNew,
                    child: const Text("Add New"),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _filteredItems.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No matching items found.'),
                  )
                : Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return ListTile(
                          title: Text(widget.displayItem(item)),
                          onTap: () {
                            widget.validator?.call(item);
                            Navigator.pop(context, item);
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }
}
