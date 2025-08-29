// To parse this JSON data, do
//
//     final getOtp = getOtpFromJson(jsonString);

import 'dart:convert';

GetOtp getOtpFromJson(String str) => GetOtp.fromJson(json.decode(str));


class GetOtp {
  String ?message;
  bool? user;
  bool? details;
  bool? land;
  bool? crop;
   Language language;
  int? otp;

  GetOtp({
     this.message,
     this.user,
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
    details: json["details"],
    land: json["land"],
    crop: json["crop"],
    language: Language.fromJson(farmer["language"]),
    otp: farmer["otp"],
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
