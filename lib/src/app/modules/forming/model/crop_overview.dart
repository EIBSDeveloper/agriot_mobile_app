
import 'package:argiot/src/app/modules/forming/model/crop_land.dart';
import 'package:argiot/src/app/modules/forming/model/cropinfo.dart';

import '../../guideline/model/guideline.dart';

class CropOverview {
  final int farmerId;
  final CropLand land;
  final Cropinfo crop;
  final List<Guideline> guidelines;

  CropOverview({
    required this.farmerId,
    required this.land,
    required this.crop,
    required this.guidelines,
  });

  factory CropOverview.fromJson(Map<String, dynamic> json) => CropOverview(
      farmerId: json['farmer_id'],
      land: CropLand.fromJson(json['land']),
      crop: Cropinfo.fromJson(json['crop']),
      guidelines: List<Guideline>.from(
        json['guidelines']?.map((x) => Guideline.fromJson(x)) ?? [],
      ),
     
    );
}
