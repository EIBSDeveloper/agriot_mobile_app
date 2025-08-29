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

  factory VendorCustomer.fromJson(Map<String, dynamic> json) {
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
}

class VendorCustomerFormData {
  String? customerName;
  String? vendorName;
  String? shopName;
  String? businessName;
  String mobileNo;
  String? email;
  String? doorNo;
  int? countryId;
  int? stateId;
  int? cityId;
  int? talukId;
  int? villageId;
  String? gstNo;
  String? taxNo;
  int postCode;
  bool isCredit;
  double openingBalance;
  String? description;
  List<int>? marketIds;
  List<int>? inventoryTypeIds;
  String? imageBase64;
  String type;

  VendorCustomerFormData({
    this.customerName,
    this.vendorName,
    this.shopName,
    this.businessName,
    required this.mobileNo,
    this.email,
    this.doorNo,
    this.countryId,
    this.stateId,
    this.cityId,
    this.talukId,
    this.villageId,
    this.gstNo,
    this.taxNo,
    required this.postCode,
    required this.isCredit,
    required this.openingBalance,
    this.description,
    this.marketIds,
    this.inventoryTypeIds,
    this.imageBase64,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      if (type == 'customer' || type == 'both') 'customer_name': customerName,
      if (type == 'vendor') 'name': vendorName,
      'shop_name': shopName,
      if (type == 'vendor' || type == 'both') 'business_name': businessName,
      'mobile_no': mobileNo,
      'email': email,
      'door_no': doorNo,
      'country': countryId,
      'state': stateId,
      'city': cityId,
      'taluk': talukId,
      'village': villageId,
      'gst_no': gstNo,
      'tax_no': taxNo,
      if (type == 'customer' || type == 'both') 'post_code': postCode,
      if (type == 'vendor') 'pincode': postCode,
      'is_credit': isCredit,
      'opening_balance': openingBalance,
      'description': description,
      if (marketIds != null)
        'market': (type == 'vendor') ? marketIds![0] : marketIds,
      if (inventoryTypeIds != null) 'inventory_type': inventoryTypeIds,
      // if (type == 'customer') 'customer_img': imageBase64,
      // if (type == 'vendor') 'vendor_img': imageBase64,
    };
  }
}

class Market {
  final int id;
  final String name;

  Market({required this.id, required this.name});

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(id: json['id'], name: json['name']);
  }

  @override
  String toString() => name; // Important for search functionality
}
