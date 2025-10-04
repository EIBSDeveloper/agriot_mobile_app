class Vendor {

  Vendor({
     this.id,
     this.name,
     this.businessName,
     this.mobileNo,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
      id: json['id'],
      name: json['name'],
      businessName: json['business_name'] ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
    );
  final int? id;
  final String? name;
  final String? businessName;
  final String? mobileNo;
}
