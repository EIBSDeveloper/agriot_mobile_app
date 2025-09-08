import 'package:flutter/material.dart';

class PdfThumbnail extends StatelessWidget {
  final bool isPdf;
  const PdfThumbnail({super.key, required this.isPdf});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.grey[200],
    child: Center(
      child: Icon(
        isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
        size: 40,
        color: isPdf ? Colors.red : Colors.grey[600],
      ),
    ),
  );
}
