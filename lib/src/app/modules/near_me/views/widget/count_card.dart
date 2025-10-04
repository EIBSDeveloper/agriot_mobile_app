// widgets/search_bar.dart

import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';

class CountCard extends StatelessWidget {
  final String title;
  final int count;
  final String? imageUrl;
  final VoidCallback onTap;

  const CountCard({
    super.key,
    required this.title,
    required this.count,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight:80
        ),
        decoration: AppStyle.decoration,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            if (count > 0) Text('($count) '),
          ],
        ),
      ),
    );
}
