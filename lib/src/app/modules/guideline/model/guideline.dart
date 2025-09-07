import 'package:argiot/src/app/modules/forming/model/crop.dart';
import 'package:argiot/src/app/modules/guideline/model/guideline_category.dart';


class Guideline {
  Guideline({
    required this.id,
    required this.name,
    required this.guidelinestype,
    required this.guidelinescategory,
    required this.description,
    required this.status,
    required this.mediaType,
    this.crop,
    this.videoUrl,
    this.document,
    this.createdAt,
    this.updatedAt,
  });

  factory Guideline.fromJson(Map<String, dynamic> json) => Guideline(
    id: json['id'],
    name: json['name'],
    guidelinestype: json['guidelinestype'],
    guidelinescategory: GuidelineCategory.fromJson(json['guidelinescategory']),
    crop: json['crop'] != null ? Crop.fromJson(json['crop']) : null,
    description: json['description'],
    status: json['status'],
    videoUrl: json['video_url'],
    document: json['document'],
    mediaType: json['media_type'],
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null,
  );
  final int id;
  final String name;
  final String guidelinestype;
  final GuidelineCategory? guidelinescategory;
  final Crop? crop;
  final String description;
  final int status;
  final String? videoUrl;
  final String? document;
  final String mediaType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
