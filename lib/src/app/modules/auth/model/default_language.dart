class DefaultLanguage {
  String languageDefault;

  DefaultLanguage({required this.languageDefault});

  DefaultLanguage copyWith({String? languageDefault}) =>
      DefaultLanguage(languageDefault: languageDefault ?? this.languageDefault);

  factory DefaultLanguage.fromJson(Map<String, dynamic> json) =>
      DefaultLanguage(languageDefault: json["default"]);

  Map<String, dynamic> toJson() => {"default": languageDefault};
}
