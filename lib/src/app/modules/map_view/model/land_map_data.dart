import 'package:argiot/src/app/modules/map_view/model/crop_map_data.dart';

class LandMapData {
  final int? landId;
  final String? landName;
  final String? manager;
  final String? solitType;
  final int? farmerId;
  final List<List<double>>? geoMarks;
  final List<CropMapData>? crops;

  LandMapData({
    this.landId,
    this.landName,
    this.manager,
    this.solitType,
    this.farmerId,
    this.geoMarks,
    this.crops,
  });

  factory LandMapData.fromJson(Map<String, dynamic> json) => LandMapData(
    landId: json["land_id"],
    landName: json["land_name"],
    manager: json["manager"],
    solitType: json["solit_type"],
    farmerId: json["farmer_id"],
    geoMarks: json["geo_marks"] == null
        ? []
        : (json["geo_marks"] as List)
              .where((point) => point["lat"] != null && point["lng"] != null)
              .map<List<double>>(
                (point) => [point["lat"].toDouble(), point["lng"].toDouble()],
              )
              .toList(),

    crops: json["crops"] == null
        ? []
        : List<CropMapData>.from(
            json["crops"]!.map((x) => CropMapData.fromJson(x)),
          ),
  );
}
