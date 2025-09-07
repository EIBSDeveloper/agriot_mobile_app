class LandVSCropModel {
  final List<String> labels;
  final List<int> data;

  LandVSCropModel({required this.labels, required this.data});

  // Factory constructor to create a DataModel from JSON
  factory LandVSCropModel.fromJson(Map<String, dynamic> json) =>
      LandVSCropModel(
        labels: List<String>.from(json['labels']),
        data: List<int>.from(json['data']),
      );

  // Method to convert DataModel to JSON
  Map<String, dynamic> toJson() => {'labels': labels, 'data': data};
}
