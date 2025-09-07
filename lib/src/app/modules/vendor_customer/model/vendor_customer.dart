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
  final int? countryId;
  final String? country;
  final int? stateId;
  final String? state;
  final int? cityId;
  final String? city;
  final int? talukId;
  final String? taluk;
  final int? villageId;
  final String? village;
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
    this.countryId,
    this.country,
    this.stateId,
    this.state,
    this.cityId,
    this.city,
    this.talukId,
    this.taluk,
    this.villageId,
    this.village,
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

  factory VendorCustomer.fromJson(Map<String, dynamic> json) => VendorCustomer(
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
      countryId: json['country_id'],
      country: json['country'],
      stateId: json['state_id'],
      state: json['state'],
      cityId: json['city_id'],
      city: json['city'],
      talukId: json['taluk_id'],
      taluk: json['taluk'],
      villageId: json['village_id'],
      village: json['village'],
      gstNo: json['gst_no'] ?? json['gst_number'],
      taxNo: json['tax_no'] ?? json['tax_number'],
      postCode: json['post_code'] ?? json['pincode'],
      isCredit: json['is_credit'] ?? (json['credit'] == '+'),
      openingBalance: (json['opening_balance'] ?? 0).toDouble(),
      // description: json['description'][0]??" ",
      isCustomerIsVendor: json['is_customer_is_vendor'] ?? false,
      marketId: json['market_id'],
      market: json['market'] is List
          ? (json['market'] as List).join(', ')
          : json['market'],
      inventoryType: json['inventory_type'],
      vendorImage: json['vendor_image'],
      customerImg: json['customer_img'],
    );
}
