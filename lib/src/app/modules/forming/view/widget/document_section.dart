import 'package:argiot/src/app/modules/forming/model/document_view.dart';
import 'package:argiot/src/app/modules/forming/view/widget/pdf_thumbnail.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentSection extends StatelessWidget {
  final List<DocumentView> docs;
  const DocumentSection({super.key, required this.docs});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const TitleText('Documents'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(docs.length, (index) {
          final DocumentView doc = docs[index];
          final url = doc.url;
          final categoryName = doc.lable;

          final lowerUrl = url.toString().toLowerCase();
          final isImage =
              lowerUrl.endsWith('.jpg') ||
              lowerUrl.endsWith('.jpeg') ||
              lowerUrl.endsWith('.png') ||
              lowerUrl.endsWith('.gif');
          final isPdf = lowerUrl.endsWith('.pdf');

          return GestureDetector(
            onTap: () {
              if (url.isNotEmpty) {
                Get.toNamed(Routes.docViewer, arguments: url);
              } else {
                showError('Document not available');
              }
            },
            child: SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: isImage
                          ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  PdfThumbnail(isPdf: isPdf),
                            )
                          : PdfThumbnail(isPdf: isPdf),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categoryName,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    ],
  );
}
