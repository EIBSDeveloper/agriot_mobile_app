import 'package:argiot/src/app/modules/guideline/model/guideline_category.dart';

class Guideline {
  final int id;
  final String name;
  final String guidelinestype;
  final GuidelineCategory? guidelinescategory;
  final String description;
  final String? videoUrl;
  final String? document;
  final String mediaType;

 Guideline({
    required this.id,
    required this.name,
    required this.guidelinestype,
    required this.guidelinescategory,
    required this.description,
    this.videoUrl,
    this.document,
    required this.mediaType,
  });

  factory Guideline.fromJson(Map<String, dynamic> json) => Guideline(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    videoUrl: json['video_url'] ?? "",
    document: json['document'],
    mediaType: json['media_type'],
    guidelinestype: json['guidelinestype'],
    guidelinescategory: GuidelineCategory.fromJson(json['guidelinescategory']),
  );
}
