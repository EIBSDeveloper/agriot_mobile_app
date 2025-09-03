// To parse this JSON data, do
//
//     final getOtp = getOtpFromJson(jsonString);

import 'dart:convert';

GetOtp getOtpFromJson(String str) => GetOtp.fromJson(json.decode(str));


class GetOtp {
  String ?message;
  bool? user;
  int? userId;
  bool? details;
  bool? land;
  bool? crop;
   Language language;
  int? otp;

  GetOtp({
     this.message,
     this.user,
     this.userId,
    required this.details,
    required this.land,
    required this.crop,
    required this.language,
    required this.otp,
  });

  factory GetOtp.fromJson(Map<String, dynamic> json) {
    var farmer = json["farmer"];
    return GetOtp(
    message: json["message"],
    user: json["user"],
    userId: farmer["id"],
    details: json["details"],
    land: json["land"],
    crop: json["crop"],
    language: Language.fromJson(farmer["language"]),
    otp: int.tryParse(farmer["otp"].toString())??0,
  );}


}

class Language {
  String languageDefault;

  Language({required this.languageDefault});

  Language copyWith({String? languageDefault}) =>
      Language(languageDefault: languageDefault ?? this.languageDefault);

  factory Language.fromJson(Map<String, dynamic> json) =>
      Language(languageDefault: json["default"]);

  Map<String, dynamic> toJson() => {"default": languageDefault};
}
