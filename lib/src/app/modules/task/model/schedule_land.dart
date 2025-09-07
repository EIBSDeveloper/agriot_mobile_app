import 'package:argiot/src/app/modules/task/model/schedule_crop.dart';

class ScheduleLand {
  const ScheduleLand({
    required this.id,
    required this.name,
    required this.crops,
  });

  factory ScheduleLand.fromJson(Map<String, dynamic> json) => ScheduleLand(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    crops:
        (json['crops'] as List<dynamic>?)
            ?.map((cropJson) => ScheduleCrop.fromJson(cropJson))
            .toList() ??
        <ScheduleCrop>[],
  );

  final int id;
  final String name;
  final List<ScheduleCrop> crops;
}
