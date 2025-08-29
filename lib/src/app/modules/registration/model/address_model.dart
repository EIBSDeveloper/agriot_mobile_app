class AddressModel {
  final int? id;
  final String? name;

  AddressModel({this.id, this.name});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class CountryModel extends AddressModel {
  CountryModel({super.id, super.name});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class StateModel extends AddressModel {
  StateModel({super.id, super.name});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class CityModel extends AddressModel {
  CityModel({super.id, super.name});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class TalukModel extends AddressModel {
  TalukModel({super.id, super.name});

  factory TalukModel.fromJson(Map<String, dynamic> json) {
    return TalukModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class VillageModel extends AddressModel {
  VillageModel({super.id, super.name});

  factory VillageModel.fromJson(Map<String, dynamic> json) {
    return VillageModel(
      id: json['id'],
      name: json['name'],
    );
  }
}