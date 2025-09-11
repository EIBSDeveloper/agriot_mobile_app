// models/land_model.dart
class Land {
  final int id;
  final String name;

  Land({required this.id, required this.name});

  factory Land.fromJson(Map<String, dynamic> json) => Land(
      id: json['id'],
      name: json['name'],
    );
}

class LandList {
  final List<Land> lands;

  LandList({required this.lands});

  factory LandList.fromJson(Map<String, dynamic> json) {
    var landList = json['lands'] as List;
    List<Land> lands = landList.map((land) => Land.fromJson(land)).toList();
    return LandList(lands: lands);
  }
}

// models/market_model.dart
class Market {
  final int id;
  final String name;
  final String marketImg;
  final List<String> products;
  final String openingTime;
  final String closingTime;
  final List<String> days;
  final String description;
  final String phone;
  final String address;
  final String latitude;
  final String longitude;
  final int status;
  final int landId;
  final String landName;
  final int farmerId;
  final String farmerLandName;

  Market({
    required this.id,
    required this.name,
    required this.marketImg,
    required this.products,
    required this.openingTime,
    required this.closingTime,
    required this.days,
    required this.description,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.landId,
    required this.landName,
    required this.farmerId,
    required this.farmerLandName,
  });

  factory Market.fromJson(Map<String, dynamic> json) => Market(
      id: json['id'],
      name: json['name'],
      marketImg: json['market_img'],
      products: List<String>.from(json['products']),
      openingTime: json['openingtime'],
      closingTime: json['closingtime'],
      days: List<String>.from(json['days']),
      description: json['description'],
      phone: json['phone'],
      address: json['address'],
      latitude: json['latitude']??'',
      longitude: json['longitude']??'',
      status: json['status'],
      landId: json['land_id'],
      landName: json['land_name'],
      farmerId: json['farmer_id'],
      farmerLandName: json['farmer_land']['land_name'],
    );
}

class MarketResponse {
  final int marketCount;
  final List<Market> markets;

  MarketResponse({required this.marketCount, required this.markets});

  factory MarketResponse.fromJson(Map<String, dynamic> json) {
    var marketList = json['markets'] as List;
    List<Market> markets = marketList.map((market) => Market.fromJson(market)).toList();
    return MarketResponse(
      marketCount: json['market_count'],
      markets: markets,
    );
  }
}

// models/place_model.dart
class PlaceDetail {
  final int id;
  final String name;
  final String contact;
  final String address;
  final String images;
  final String description;
  final String openingTime;
  final String closingTime;
  final List<String> days;
  final String latitude;
  final String longitude;
  final int status;

  PlaceDetail({
    required this.id,
    required this.name,
    required this.contact,
    required this.address,
    required this.images,
    required this.description,
    required this.openingTime,
    required this.closingTime,
    required this.days,
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  factory PlaceDetail.fromJson(Map<String, dynamic> json) => PlaceDetail(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      address: json['address'],
      images: json['images'],
      description: json['description'],
      openingTime: json['openingtime'],
      closingTime: json['closingtime'],
      days: List<String>.from(json['days']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      status: json['status'],
    );
}

class PlaceCategory {
  final String categoryName;
  final int count;
  final List<PlaceDetail> details;

  PlaceCategory({
    required this.categoryName,
    required this.count,
    required this.details,
  });

  factory PlaceCategory.fromJson(Map<String, dynamic> json) {
    var detailList = json['details'] as List;
    List<PlaceDetail> details = detailList.map((detail) => PlaceDetail.fromJson(detail)).toList();
    return PlaceCategory(
      categoryName: json['category_name'],
      count: json['count'],
      details: details,
    );
  }
}

// models/manpower_model.dart
class WorkType {
  final String workType;
  final int personCount;

  WorkType({required this.workType, required this.personCount});

  factory WorkType.fromJson(Map<String, dynamic> json) => WorkType(
      workType: json['work_type'],
      personCount: json['person_count'],
    );
}

class Worker {
  final int workerId;
  final String workerName;
  final int workerMobile;
  final List<WorkType> workTypes;

  Worker({
    required this.workerId,
    required this.workerName,
    required this.workerMobile,
    required this.workTypes,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    var workTypeList = json['work_types'] as List;
    List<WorkType> workTypes = workTypeList.map((workType) => WorkType.fromJson(workType)).toList();
    return Worker(
      workerId: json['worker_id'],
      workerName: json['worker_name'],
      workerMobile: json['worker_mobile'],
      workTypes: workTypes,
    );
  }
}

class ManPowerAgent {
  final int id;
  final String name;
  final String taluk;
  final int mobileNo;
  final int status;
  final int workersCount;
  final int farmerId;
  final int landId;
  final List<Worker> workers;

  ManPowerAgent({
    required this.id,
    required this.name,
    required this.taluk,
    required this.mobileNo,
    required this.status,
    required this.workersCount,
    required this.farmerId,
    required this.landId,
    required this.workers,
  });

  factory ManPowerAgent.fromJson(Map<String, dynamic> json) {
    var workerList = json['workers'] as List;
    List<Worker> workers = workerList.map((worker) => Worker.fromJson(worker)).toList();
    return ManPowerAgent(
      id: json['id'],
      name: json['name'],
      taluk: json['taluk'],
      mobileNo: json['mobile_no'],
      status: json['status'],
      workersCount: json['workers_count'],
      farmerId: json['farmer_id'],
      landId: json['land_id'],
      workers: workers,
    );
  }
}

// models/rental_model.dart
class RentalLanguage {
  final String defaultLang;

  RentalLanguage({required this.defaultLang});

  factory RentalLanguage.fromJson(Map<String, dynamic> json) => RentalLanguage(
      defaultLang: json['default'],
    );
}

class RentalDetail {
  final int id;
  final String vendorName;
  final int vendorPhone;
  final String vendorAddress;
  final String registerNumber;
  final String inventoryItemName;

  RentalDetail({
    required this.id,
    required this.vendorName,
    required this.vendorPhone,
    required this.vendorAddress,
    required this.registerNumber,
    required this.inventoryItemName,

  });

  factory RentalDetail.fromJson(Map<String, dynamic> json) => RentalDetail(
      id: json['id'],
      vendorName: json['vendor_name'],
      vendorPhone: json['vendor_phone'],
      vendorAddress: json['vendor_address'],
      registerNumber: json['register_number'],
      inventoryItemName: json['inventory_item_name'],
    );
}

class RentalItem {
  final int inventoryItemId;
  final String inventoryItemName;
  final int count;
  final List<RentalDetail> details;

  RentalItem({
    required this.inventoryItemId,
    required this.inventoryItemName,
    required this.count,
    required this.details,
  });

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    var detailList = json['details'] as List;
    List<RentalDetail> details = detailList.map((detail) => RentalDetail.fromJson(detail)).toList();
    return RentalItem(
      inventoryItemId: json['inventory_item_id'],
      inventoryItemName: json['inventory_item_name'],
      count: json['count'],
      details: details,
    );
  }
}