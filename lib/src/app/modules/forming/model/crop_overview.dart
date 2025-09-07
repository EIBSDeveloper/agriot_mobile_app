import 'package:argiot/src/app/modules/forming/view/screen/crop_model.dart';

class CropOverview {
  final int farmerId;
  final CropLand land;
  final Cropinfo crop;
  final List<CropGuideline> guidelines;
  final List<Schedule> schedules;

  CropOverview({
    required this.farmerId,
    required this.land,
    required this.crop,
    required this.guidelines,
    required this.schedules,
  });

  factory CropOverview.fromJson(Map<String, dynamic> json) => CropOverview(
      farmerId: json['farmer_id'],
      land: CropLand.fromJson(json['land']),
      crop: Cropinfo.fromJson(json['crop']),
      guidelines: List<CropGuideline>.from(
        json['guidelines']?.map((x) => CropGuideline.fromJson(x)) ?? [],
      ),
      schedules: List<Schedule>.from(
        json['schedules']?.map((x) => Schedule.fromJson(x)) ?? [],
      ),
    );
}
