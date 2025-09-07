class VendorCustomerFormData {
  String? customerName;
  String? vendorName;
  String? shopName;
  String? businessName;
  String mobileNo;
  String? email;
  String? doorNo;
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

  Map<String, dynamic> toJson() => {
      if (type == 'customer' || type == 'both') 'customer_name': customerName,
      if (type == 'vendor') 'name': vendorName,
      'shop_name': shopName,
      if (type == 'vendor' || type == 'both') 'business_name': businessName,
      'mobile_no': mobileNo,
      'email': email,
      'door_no': doorNo,
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
