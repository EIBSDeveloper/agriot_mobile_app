class Crop {
  final int id;
  final String name;
  final String img;

  Crop({required this.id, required this.name, required this.img});

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      img: json['img'] ?? '',
    );
    
  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
