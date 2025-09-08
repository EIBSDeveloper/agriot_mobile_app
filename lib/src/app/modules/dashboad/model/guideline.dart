class Guideline {
  final int id;
  final String name;
  final String type;
  final String category;
  final String crop;
  final String description;
  final String videoUrl;
  final String document;
  final String mediaType;

  Guideline({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.crop,
    required this.description,
    required this.videoUrl,
    required this.document,
    required this.mediaType,
  });

  factory Guideline.fromJson(Map<String, dynamic> json) => Guideline(
    id: json['id'],
    name: json['name'],
    type: json['guidelines_type'],
    category: json['guidelines_category']['name'],
    crop: json['crop']['name'],
    description: json['description'],
    videoUrl: json['video_url']?["full"]??"",
    document: json['document'],
    mediaType: json['media_type'],
  );
}
