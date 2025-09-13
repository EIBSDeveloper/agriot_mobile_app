import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;

import '../../../../service/utils/enums.dart';
import '../../../../widgets/my_network_image.dart';

class DocumentThumbnail extends StatefulWidget {
  final String source;
  const DocumentThumbnail(this.source, {super.key});

  @override
  State<DocumentThumbnail> createState() => _DocumentThumbnailState();
}

class _DocumentThumbnailState extends State<DocumentThumbnail> {
  bool isLoading = true;
  String error = '';
  List<String> documentUrls = [];
  List<FileTypes> fileTypes = [];
  List<FileSourceTypes> sourceTypes = [];

  @override
  void initState() {
    super.initState();
    _load(widget.source);
  }

  Future<void> _load(String source) async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      documentUrls = [source];
      await _checkDocuments();
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkDocuments() async {
    fileTypes.clear();
    sourceTypes.clear();

    for (final doc in documentUrls) {
      if (doc.isEmpty) {
        fileTypes.add(FileTypes.unsupported);
        sourceTypes.add(FileSourceTypes.unsupported);
        continue;
      }

      // Base64
      if (doc.startsWith("data:") ||
          RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(doc)) {
        sourceTypes.add(FileSourceTypes.base64);

        if (doc.toLowerCase().endsWith(".pdf")) {
          fileTypes.add(FileTypes.pdf);
        } else {
          fileTypes.add(FileTypes.image);
        }
        continue;
      }

      // Local file
      if (File(doc).existsSync()) {
        sourceTypes.add(FileSourceTypes.local);

        if (doc.toLowerCase().endsWith('.pdf')) {
          fileTypes.add(FileTypes.pdf);
        } else {
          fileTypes.add(FileTypes.image);
        }
        continue;
      }

      // Network
      final response = await http.head(Uri.parse(doc));
      if (response.statusCode == 200) {
        sourceTypes.add(FileSourceTypes.network);

        if (doc.toLowerCase().endsWith('.pdf')) {
          fileTypes.add(FileTypes.pdf);
        } else if (doc.toLowerCase().endsWith('.png') ||
            doc.toLowerCase().endsWith('.jpg') ||
            doc.toLowerCase().endsWith('.jpeg') ||
            doc.toLowerCase().endsWith('.gif')) {
          fileTypes.add(FileTypes.image);
        } else {
          fileTypes.add(FileTypes.unsupported);
        }
      } else {
        fileTypes.add(FileTypes.unsupported);
        sourceTypes.add(FileSourceTypes.unsupported);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 100,
        width: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error.isNotEmpty) {
      return SizedBox(
        height: 100,
        width: 100,
        child: Center(
          child: Icon(Icons.info_sharp, color: Theme.of(context).primaryColor),
        ),
      );
    }

    if (documentUrls.length == 1) {
      return SizedBox(
        height: 100,
        width: 100,
        child: _buildFileView(
          documentUrls.first,
          fileTypes.first,
          sourceTypes.first,
        ),
      );
    }

    return SizedBox(
      height: 100,
      width: 100,
      child: Icon(Icons.info_sharp, color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildFileView(String path, FileTypes type, FileSourceTypes source) {
    switch (type) {
      case FileTypes.pdf:
        if (source == FileSourceTypes.local) {
          return PDFView(filePath: path);
        } else if (source == FileSourceTypes.base64) {
          final bytes = base64Decode(
            path.replaceAll(RegExp(r'data:.*;base64,'), ''),
          );
          final file = File(
            "${Directory.systemTemp.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf",
          );
          file.writeAsBytesSync(bytes);
          return PDFView(filePath: file.path);
        } else {
          return PDFView(filePath: path);
        }

      case FileTypes.image:
        if (source == FileSourceTypes.local) {
          return Center(
            child: InteractiveViewer(child: Image.file(File(path))),
          );
        } else if (source == FileSourceTypes.base64) {
          final bytes = base64Decode(path.split(",").last);

          return Center(child: InteractiveViewer(child: Image.memory(bytes, gaplessPlayback: true,)));
        } else {
          return Center(child: InteractiveViewer(child: MyNetworkImage(path)));
        }

      case FileTypes.unsupported:
        return const Center(child: Text('Unsupported file format'));
    }
  }
}
