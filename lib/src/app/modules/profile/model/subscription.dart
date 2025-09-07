class Subscription {
  final String packageName;
  final String packageDuration;
  final int packageValidity;
  final String startDate;
  final String endDate;
  final int remainingDays;
  final bool renewal;
  final int status;
  final double subAmount;
  final double packageAmount;
  final double packageSubAmount;
  final bool packageOffer;
  final int packagePercentage;

  Subscription({
    required this.packageName,
    required this.packageDuration,
    required this.packageValidity,
    required this.startDate,
    required this.endDate,
    required this.remainingDays,
    required this.renewal,
    required this.status,
    required this.subAmount,
    required this.packageAmount,
    required this.packageSubAmount,
    required this.packageOffer,
    required this.packagePercentage,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
      packageName: json['package_name'] ?? '',
      packageDuration: json['package_duration'] ?? '',
      packageValidity: json['package_validity'] ?? 0,
      startDate: json['startdate'] ?? '',
      endDate: json['enddate'] ?? '',
      remainingDays: json['remainingdays'] ?? 0,
      renewal: json['renewal'] ?? false,
      status: json['status'] ?? 0,
      subAmount: (json['sub_amount'] ?? 0).toDouble(),
      packageAmount: (json['package_amount'] ?? 0).toDouble(),
      packageSubAmount: (json['package_sub_amount'] ?? 0).toDouble(),
      packageOffer: json['package_offer'] ?? false,
      packagePercentage: json['package_percentage'] ?? 0,
    );
}