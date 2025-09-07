import 'package:argiot/src/app/modules/forming/model/crop_land_details.dart';
import 'package:argiot/src/app/modules/forming/view/screen/crop_model.dart';

class CropDetails {
  final CropLandDetails land;
  final List<CropDetail> crops;

  CropDetails({required this.land, required this.crops});

  factory CropDetails.fromJson(Map<String, dynamic> json) => CropDetails(
      land: CropLandDetails.fromJson(json),
      crops: List<CropDetail>.from(
        json['crop_details']?.map((x) => CropDetail.fromJson(x)) ?? [],
      ),
    );
}
