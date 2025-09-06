class SalesListResponse {
  final int cropId;
  final String cropName;
  final int cropLandId;
  final String cropLand;
  final String cropImg;
  final double totalSalesAmount;
  final List<SalesByDate> salesByDate;

  SalesListResponse({
    required this.cropId,
    required this.cropName,
    required this.cropLandId,
    required this.cropLand,
    required this.cropImg,
    required this.totalSalesAmount,
    required this.salesByDate,
  });

  factory SalesListResponse.fromJson(Map<String, dynamic> json) {
    final salesMap = json['sales'] as Map<String, dynamic>;

    final salesByDateList = salesMap.entries.map((entry) {
      final date = entry.key;
      final salesList = (entry.value as List)
          .map((saleJson) => Sales.fromJson(saleJson))
          .toList();

      return SalesByDate(date: date, sales: salesList);
    }).toList();

    return SalesListResponse(
      cropId: json['crop_id'] ?? 0,
      cropName: json['crop_name'] ?? '',
      cropLandId: json['crop_land_id'] ?? 0,
      cropLand: json['crop_land'] ?? '',
      cropImg: json['crop_img'] ?? '',
      totalSalesAmount: json['total_sales_amount']?.toDouble() ?? 0.0,
      salesByDate: salesByDateList,
    );
  }
}
class SalesByDate {
  final String date;
  final List<Sales> sales;

  SalesByDate({
    required this.date,
    required this.sales,
  });
}

class Sales {
  final int salesId;
  final String datesOfSales;
  final int salesQuantity;
  final Unit salesUnit;
  final String quantityAmount;
  final String totalAmount;
  final double salesAmount;
  final String deductionAmount;
  final double totalSalesAmount;
  final String description;
  final int status;
  final Farmer farmer;
  final Customer myCustomer;
  final String createdAt;
  final String updatedAt;

  Sales({
    required this.salesId,
    required this.datesOfSales,
    required this.salesQuantity,
    required this.salesUnit,
    required this.quantityAmount,
    required this.totalAmount,
    required this.salesAmount,
    required this.deductionAmount,
    required this.totalSalesAmount,
    required this.description,
    required this.status,
    required this.farmer,
    required this.myCustomer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sales.fromJson(Map<String, dynamic> json) => Sales(
      salesId: json['sales_id'],
      datesOfSales: json['dates_of_sales'],
      salesQuantity: json['sales_quantity'],
      salesUnit: Unit.fromJson(json['sales_unit']),
      quantityAmount: json['quantity_amount'],
      totalAmount: json['total_amount'],
      salesAmount: json['sales_amount']?.toDouble() ?? 0.0,
      deductionAmount: json['deduction_amount'],
      totalSalesAmount: json['total_sales_amount']?.toDouble() ?? 0.0,
      description: json['description'],
      status: json['status'],
      farmer: Farmer.fromJson(json['farmer']),
      myCustomer: Customer.fromJson(json['my_customer']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
}

class SalesDetailResponse {
  final int salesId;
  final Farmer farmer;
  final String datesOfSales;
  final Crop myCrop;
  final Customer myCustomer;
  final int salesQuantity;
  final Unit salesUnit;
  final String quantityAmount;
  final String totalAmount;
  final double salesAmount;
  final String deductionAmount;
  final double totalSalesAmount;
  final double amountPaid;
  final String? description;
  final int status;
  final String createdAt;
  final String updatedAt;
  final List<Deduction> deductions;
  final List<DocumentCategory> documents;

  SalesDetailResponse({
    required this.salesId,
    required this.farmer,
    required this.datesOfSales,
    required this.myCrop,
    required this.myCustomer,
    required this.salesQuantity,
    required this.salesUnit,
    required this.quantityAmount,
    required this.totalAmount,
    required this.salesAmount,
    required this.deductionAmount,
    required this.totalSalesAmount,
    required this.amountPaid,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deductions,
    required this.documents,
  });

  factory SalesDetailResponse.fromJson(Map<String, dynamic> json) => SalesDetailResponse(
      salesId: json['sales_id'],
      farmer: Farmer.fromJson(json['farmer']),
      datesOfSales: json['dates_of_sales'],
      myCrop: Crop.fromJson(json['my_crop']),
      myCustomer: Customer.fromJson(json['my_customer']),
      salesQuantity: json['sales_quantity'],
      salesUnit: Unit.fromJson(json['sales_unit']),
      quantityAmount: json['quantity_amount'],
      totalAmount: json['total_amount'],
      salesAmount: json['sales_amount']?.toDouble() ?? 0.0,
      deductionAmount: json['deduction_amount'],
      totalSalesAmount: json['total_sales_amount']?.toDouble() ?? 0.0,
      amountPaid: json['amount_paid']?.toDouble() ?? 0.0,
      description: json['description'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deductions: List<Deduction>.from(
          json['deductions'].map((x) => Deduction.fromJson(x))),
      documents: List<DocumentCategory>.from(
          json['documents'].map((x) => DocumentCategory.fromJson(x))),
    );
}

class Farmer {
  final int id;
  final String name;

  Farmer({required this.id, required this.name});

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
      id: json['id'],
      name: json['name'],
    );
}

class Customer {
  final int id;
  final String name;
  final String? village;

  Customer({required this.id, required this.name, this.village});

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
      id: json['id'],
      name: json['name'],
      village: json['village'],
    );
}

class Crop {
  final int id;
  final String name;
  final String img;

  Crop({required this.id, required this.name, required this.img});

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
      id: json['id'],
      name: json['name'],
      img: json['img'],
    );
}

class Unit {
  final int id;
  final String name;

  Unit({required this.id, required this.name});

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
      id: json['id'],
      name: json['name'],
    );
}

class Deduction {
  final int? deductionId;
  final Reason? reason;
  final String charges;
  final Rupee rupee;

  Deduction({
    this.deductionId,
    this.reason,
    required this.charges,
    required this.rupee,
  });

  factory Deduction.fromJson(Map<String, dynamic> json) => Deduction(
      deductionId: json['deduction_id'],
      reason: json['reason'] != null ? Reason.fromJson(json['reason']) : null,
      charges: json['charges'],
      rupee: Rupee.fromJson(json['rupee']),
    );

  Map<String, dynamic> toJson() => {
      if (deductionId != null) 'deduction_id': deductionId,
      if (reason != null) 'reason': reason?.toJson(),
      'charges': charges,
      'rupee': rupee.toJson(),
    };
}

class Reason {
  final int id;
  final String name;

  Reason({required this.id, required this.name});

  factory Reason.fromJson(Map<String, dynamic> json) => Reason(
      id: json['id'],
      name: json['name'],
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
    };
}

class Rupee {
  final int id;
  final String name;

  Rupee({required this.id, required this.name});

  factory Rupee.fromJson(Map<String, dynamic> json) => Rupee(
      id: json['id'],
      name: json['name'],
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
    };
}

class DocumentCategory {
  final String categoryId;
  final List<Document> documents;

  DocumentCategory({
    required this.categoryId,
    required this.documents,
  });

  factory DocumentCategory.fromJson(Map<String, dynamic> json) => DocumentCategory(
      categoryId: json['category_id'],
      documents: List<Document>.from(
          json['documents'].map((x) => Document.fromJson(x))),
    );
}

class Document {
  final int id;
  final DocumentCategoryType documentCategory;
  final String fileUpload;
  final Language language;

  Document({
    required this.id,
    required this.documentCategory,
    required this.fileUpload,
    required this.language,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
      id: json['id'],
      documentCategory: DocumentCategoryType.fromJson(json['document_category']),
      fileUpload: json['file_upload'],
      language: Language.fromJson(json['language']),
    );
}

class DocumentCategoryType {
  final int id;
  final String name;

  DocumentCategoryType({required this.id, required this.name});

  factory DocumentCategoryType.fromJson(Map<String, dynamic> json) => DocumentCategoryType(
      id: json['id'],
      name: json['name'],
    );
}

class Language {
  final String defaultLanguage;

  Language({required this.defaultLanguage});

  factory Language.fromJson(Map<String, dynamic> json) => Language(
      defaultLanguage: json['default'],
    );
}

class DropdownItem {
  final int id;
  final String name;

  DropdownItem({required this.id, required this.name});

  factory DropdownItem.fromJson(Map<String, dynamic> json) => DropdownItem(
      id: json['id'],
      name: json['name'],
    );
}

class SalesAddRequest {
  final String datesOfSales;
  final int myCrop;
  final int myCustomer;
  final int salesQuantity;
  final int salesUnit;
  final String quantityAmount;
  final String salesAmount;
  final String deductionAmount;
  final String description;
  final String amountPaid;
  final List<Map<String, dynamic>> deductions;
  final List<Map<String, dynamic>> fileData;

  SalesAddRequest({
    required this.datesOfSales,
    required this.myCrop,
    required this.myCustomer,
    required this.salesQuantity,
    required this.salesUnit,
    required this.quantityAmount,
    required this.salesAmount,
    required this.deductionAmount,
    required this.description,
    required this.amountPaid,
    required this.deductions,
    required this.fileData,
  });

  Map<String, dynamic> toJson() => {
      'dates_of_sales': datesOfSales,
      'my_crop': myCrop,
      'my_customer': myCustomer,
      'sales_quantity': salesQuantity,
      'sales_unit': salesUnit,
      'quantity_amount': quantityAmount,
      'sales_amount': salesAmount,
      'deduction_amount': deductionAmount,
      'description': description,
      'amount_paid': amountPaid,
      'deductions': deductions,
      'file_data': fileData,
    };
}

class SalesEditRequest {
  final int salesId;
  final String datesOfSales;
  final int myCrop;
  final int myCustomer;
  final int salesQuantity;
  final int salesUnit;
  final String quantityAmount;
  final String salesAmount;
  final String deductionAmount;
  final String description;
  final String amountPaid;
  final List<Map<String, dynamic>> deductions;
  final List<Map<String, dynamic>> fileData;

  SalesEditRequest({
    required this.salesId,
    required this.datesOfSales,
    required this.myCrop,
    required this.myCustomer,
    required this.salesQuantity,
    required this.salesUnit,
    required this.quantityAmount,
    required this.salesAmount,
    required this.deductionAmount,
    required this.description,
    required this.amountPaid,
    required this.deductions,
    required this.fileData,
  });

  Map<String, dynamic> toJson() => {
      'sales_id': salesId,
      'dates_of_sales': datesOfSales,
      'my_crop': myCrop,
      'my_customer': myCustomer,
      'sales_quantity': salesQuantity,
      'sales_unit': salesUnit,
      'quantity_amount': quantityAmount,
      'sales_amount': salesAmount,
      'deduction_amount': deductionAmount,
      'description': description,
      'amount_paid': amountPaid,
      'deductions': deductions,
      'file_data': fileData,
    };
}