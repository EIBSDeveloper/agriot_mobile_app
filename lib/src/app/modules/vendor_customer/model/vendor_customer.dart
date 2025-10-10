class VendorCustomer {
  final int id;
  final int farmerId;
  final String farmer;
  final String name;
  final String type;
  final String? shopName;
  final String? businessName;
  final String mobileNo;
  final String? email;
  final String? doorNo;
  final String? gstNo;
  final String? taxNo;
  final int? postCode;
  final bool isCredit;
  final double openingBalance;
  final String? description;
  final bool isCustomerIsVendor;
  final int? marketId;
  final String? market;
  final String? inventoryType;
  final String? vendorImage;
  final String? customerImg;

  VendorCustomer({
    required this.id,
    required this.farmerId,
    required this.farmer,
    required this.name,
    required this.type,
    this.shopName,
    this.businessName,
    required this.mobileNo,
    this.email,
    this.doorNo,
    this.gstNo,
    this.taxNo,
    this.postCode,
    required this.isCredit,
    required this.openingBalance,
    this.description,
    required this.isCustomerIsVendor,
    this.marketId,
    this.market,
    this.inventoryType,
    this.vendorImage,
    this.customerImg,
  });

  factory VendorCustomer.fromJson(Map<String, dynamic> json) {
    var market = (json['markets'] is List )?json['markets'].map((e)=>e['market']).toString():"";
    return VendorCustomer(
      id: json['id'],
      farmerId: json['farmer_id'] ?? 0,
      farmer: json['farmer'] ?? '',
      name: json['customer_name'] ?? json['name'] ?? '',
      type: json['type'],
      shopName: json['shop_name'],
      businessName: json['business_name'],
      mobileNo: json['mobile_no'].toString(),
      email: json['email'],
      doorNo: json['door_no'],
      gstNo: json['gst_no'] ?? json['gst_number'],
      taxNo: json['tax_no'] ?? json['tax_number'],
      postCode: json['post_code'] ?? json['pincode'],
      isCredit: json['is_credit'] ?? (json['credit'] == '+'),
      openingBalance: (json['opening_balance'] ?? 0).toDouble(),
      // description: json['description'][0]??" ",
      isCustomerIsVendor: json['is_customer_is_vendor'] ?? false,
      marketId: json['market_id'],
      market: market,
      inventoryType: json['inventory_type'],
      vendorImage: json['vendor_image'],
      customerImg: json['customer_img'],
    );
  }
}
