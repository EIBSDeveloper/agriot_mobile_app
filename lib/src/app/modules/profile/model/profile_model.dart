import 'package:argiot/src/app/modules/profile/model/subscription.dart';

class ProfileModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final int countryId;
  final String countryName;
  final int stateId;
  final String stateName;
  final int cityId;
  final String cityName;
  final int talukId;
  final String talukName;
  final int villageId;
  final String villageName;
  final String doorNo;
  final int pincode;
  final String? description; 
  final String? companyName; 
  final String? taxNo;     
  final String address;
  final String? location;
  final String? imgUrl;     
  final List<Subscription> subscriptions;

  ProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.countryId,
    required this.countryName,
    required this.stateId,
    required this.stateName,
    required this.cityId,
    required this.cityName,
    required this.talukId,
    required this.talukName,
    required this.villageId,
    required this.villageName,
    required this.doorNo,
    required this.pincode,
    required this.location,
    this.description,
    this.companyName,
    this.taxNo,
    required this.address,
    this.imgUrl,
    required this.subscriptions,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      countryId: json['country_id'] ?? 0,
      countryName: json['country_name'] ?? '',
      stateId: json['state_id'] ?? 0,
      stateName: json['state_name'] ?? '',
      cityId: json['city_id'] ?? 0,
      cityName: json['city_name'] ?? '',
      talukId: json['taluk_id'] ?? 0,
      talukName: json['taluk_name'] ?? '',
      villageId: json['village_id'] ?? 0,
      villageName: json['village_name'] ?? '',
      location: json['locations'] ?? '',
      doorNo: json['door_no'] ?? '',
      pincode: json['pincode'] ?? 0,
      description: json['description'], // can be null
      companyName: json['company_name'], // can be null
      taxNo: json['tax_no'],             // can be null
      address: json['address'] ?? '',
      imgUrl: json['img_url'],           // can be null or empty
      subscriptions: List<Subscription>.from(
        (json['subscriptions'] ?? []).map((x) => Subscription.fromJson(x))
      ),
    );
}
