class Errormodel {
  final String? error;
  final String? message;

  Errormodel({this.error, this.message});

  factory Errormodel.fromJson(Map<String, dynamic> json) => Errormodel(
      error: json['error'] as String?,
      message: json['message'] as String?,
    );

  Map<String, dynamic> toJson() => {'error': error, 'message': message};
}
