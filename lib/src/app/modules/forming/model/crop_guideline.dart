class CropGuideline {
  final int id;
  final String name;
  final String description;
  final String videoUrl;
  final String? document;
  final String mediaType;

  CropGuideline({
    required this.id,
    required this.name,
    required this.description,
    required this.videoUrl,
    this.document,
    required this.mediaType,
  });

  factory CropGuideline.fromJson(Map<String, dynamic> json) => CropGuideline(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      videoUrl: json['video_url'] ?? "",
      document: json['document'],
      mediaType: json['media_type'],
    );
}
