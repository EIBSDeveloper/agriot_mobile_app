// widgets/search_bar.dart

import 'package:flutter/material.dart';

import '../../../../widgets/input_card_style.dart';

class CustomSearchBar extends StatelessWidget {
  final String labelText;
  final Function(String) onChanged;

  const CustomSearchBar({
    super.key,
    required this.labelText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) =>  InputCardStyle(
               
      child: TextField(
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
}
