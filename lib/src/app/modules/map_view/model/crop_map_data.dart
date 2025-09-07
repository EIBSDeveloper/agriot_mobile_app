class CropMapData {
  final int? cropId;
  final String? cropType;
  final String? cropName;
  final List<List<double>>? geoMarks;
  final String? cropImage;

  CropMapData({
    this.cropId,
    this.cropType,
    this.cropName,
    this.geoMarks,
    this.cropImage,
  });

  factory CropMapData.fromJson(Map<String, dynamic> json) => CropMapData(
    cropId: json["crop_id"],
    cropType: json["crop_type"],
    cropName: json["crop_name"],
    geoMarks: json["geo_marks"] == null
        ? []
        : (json["geo_marks"] as List)
              .where((point) => point["lat"] != null && point["lng"] != null)
              .map<List<double>>(
                (point) => [point["lat"].toDouble(), point["lng"].toDouble()],
              )
              .toList(),
    cropImage: json["crop_image"],
  );
}
