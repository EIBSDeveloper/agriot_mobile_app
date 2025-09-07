class Vendor {

  Vendor({
    required this.id,
    required this.name,
    required this.businessName,
    required this.mobileNo,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
      id: json['id'],
      name: json['name'],
      businessName: json['business_name'] ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
    );
  final int id;
  final String name;
  final String? businessName;
  final String? mobileNo;
}
