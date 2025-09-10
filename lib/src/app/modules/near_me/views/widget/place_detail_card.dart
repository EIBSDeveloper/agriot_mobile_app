// widgets/search_bar.dart

import 'package:argiot/src/app/modules/near_me/model/models.dart';
import 'package:flutter/material.dart';

class PlaceDetailCard extends StatelessWidget {
  final PlaceDetail detail;

  const PlaceDetailCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(detail.contact, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    detail.address,
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // SizedBox(height: 8),
            // if (detail.days.isNotEmpty)
            //   Wrap(
            //     spacing: 4,
            //     children: detail.days.map((day) {
            //       return Chip(
            //         label: Text(day),
            //         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //       );
            //     }).toList(),
            //   ),
          ],
        ),
      ),
    );
}
