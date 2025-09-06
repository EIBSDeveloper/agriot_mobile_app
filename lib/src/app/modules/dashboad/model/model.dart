// lib/modules/dashboard/models/weather_model.dart
class WeatherData {
  final String condition;
  final double temperature;
  final String iconCode;
  final int humidity;

  WeatherData({
    required this.condition,
    required this.temperature,
    required this.iconCode,
    required this.humidity,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
      condition: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
      temperature: json['main']['temp'],
      iconCode: json['weather'][0]['icon'],
    );
}

// lib/modules/dashboard/models/guideline_model.dart
class Guideline {
  final int id;
  final String name;
  final String type;
  final String category;
  final String crop;
  final String description;
  final String videoUrl;
  final String document;
  final String mediaType;

  Guideline({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.crop,
    required this.description,
    required this.videoUrl,
    required this.document,
    required this.mediaType,
  });

  factory Guideline.fromJson(Map<String, dynamic> json) => Guideline(
      id: json['id'],
      name: json['name'],
      type: json['guidelines_type'],
      category: json['guidelines_category']['name'],
      crop: json['crop']['name'],
      description: json['description'],
      videoUrl: "json['video_url']",
      document: json['document'],
      mediaType: json['media_type'],
    );
}

// lib/modules/dashboard/models/task_model.dart
class Task {
  final int id;
  final String name;
  final String startDate;
  final String endDate;
  final String status;
  final String landName;
  final String cropName;
  final String cropImage;

  Task({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.landName,
    required this.cropName,
    required this.cropImage,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
      id: json['id'],
      name: json['schedule']??" ",
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['schedule_status_name'],
      landName: json['land_name'],
      cropName: json['crop_name'],
      cropImage: json['crop_image'],
    );
}

// lib/modules/dashboard/models/finance_model.dart
class FinanceData {
  final double totalSales;
  final double totalExpenses;
  final List<DailyData> sales;
  final List<DailyData> expenses;

  FinanceData({
    required this.totalSales,
    required this.totalExpenses,
    required this.sales,
    required this.expenses,
  });

  factory FinanceData.fromJson(Map<String, dynamic> json) => FinanceData(
      totalSales: json['total_sales_amount']?.toDouble() ?? 0.0,
      totalExpenses: json['total_expenses_amount']?.toDouble() ?? 0.0,
      sales: List<DailyData>.from(
        json['sales']?.map((x) => DailyData.fromJson(x)) ?? [],
      ),
      expenses: List<DailyData>.from(
        json['expenses']?.map((x) => DailyData.fromJson(x)) ?? [],
      ),
    );
}
class LandVSCropModel {
  final List<String> labels;
  final List<int> data;

  LandVSCropModel({
    required this.labels,
    required this.data,
  });

  // Factory constructor to create a DataModel from JSON
  factory LandVSCropModel.fromJson(Map<String, dynamic> json) => LandVSCropModel(
      labels: List<String>.from(json['labels']),
      data: List<int>.from(json['data']),
    );

  // Method to convert DataModel to JSON
  Map<String, dynamic> toJson() => {
      'labels': labels,
      'data': data,
    };
}

class DailyData {
  final String day;
  final double amount;

  DailyData({required this.day, required this.amount});

  factory DailyData.fromJson(Map<String, dynamic> json) => DailyData(
      day: json['day'],
      amount: json['amount']?.toDouble() ?? 0.0,
    );
}

// lib/modules/dashboard/models/market_model.dart
class MarketPrice {
  final String marketName;
  final List<ProductPrice> prices;

  MarketPrice({required this.marketName, required this.prices});

  factory MarketPrice.fromJson(Map<String, dynamic> json) => MarketPrice(
      marketName: json['market'],
      prices: List<ProductPrice>.from(
        json['price']?.map((x) => ProductPrice.fromJson(x)) ?? [],
      ),
    );
}

class ProductPrice {
  final String product;
  final double price;

  ProductPrice({required this.product, required this.price});

  factory ProductPrice.fromJson(Map<String, dynamic> json) => ProductPrice(
      product: json['product'],
      price: json['product_price']?.toDouble() ?? 0.0,
    );
}

// lib/modules/dashboard/models/payment_model.dart
class PaymentSummary {
  final VendorPayments vendor;
  final CustomerPayments customer;
  final BothPayments both;
  final TotalPayments total;

  PaymentSummary({
    required this.vendor,
    required this.customer,
    required this.both,
    required this.total,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) => PaymentSummary(
      vendor: VendorPayments.fromJson(json['vendor']),
      customer: CustomerPayments.fromJson(json['customer']),
      both: BothPayments.fromJson(json['both']),
      total: TotalPayments.fromJson(json['total']),
    );
}

class VendorPayments {
  final double payables;
  final double receivables;

  VendorPayments({required this.payables, required this.receivables});

  factory VendorPayments.fromJson(Map<String, dynamic> json) => VendorPayments(
      payables: json['payables']?.toDouble() ?? 0.0,
      receivables: json['receivables']?.toDouble() ?? 0.0,
    );
}

class CustomerPayments {
  final double payables;
  final double receivables;

  CustomerPayments({required this.payables, required this.receivables});

  factory CustomerPayments.fromJson(Map<String, dynamic> json) => CustomerPayments(
      payables: json['payables']?.toDouble() ?? 0.0,
      receivables: json['receivables']?.toDouble() ?? 0.0,
    );
}

class BothPayments {
  final double payables;
  final double receivables;

  BothPayments({required this.payables, required this.receivables});

  factory BothPayments.fromJson(Map<String, dynamic> json) => BothPayments(
      payables: json['payables']?.toDouble() ?? 0.0,
      receivables: json['receivables']?.toDouble() ?? 0.0,
    );
}

class TotalPayments {
  final double payables;
  final double receivables;

  TotalPayments({required this.payables, required this.receivables});

  factory TotalPayments.fromJson(Map<String, dynamic> json) => TotalPayments(
      payables: json['payables']?.toDouble() ?? 0.0,
      receivables: json['receivables']?.toDouble() ?? 0.0,
    );
}

// lib/modules/dashboard/models/widget_config_model.dart
class WidgetConfig {
  late bool weatherAndPayments;
  late bool expensesSales;
  late bool marketPrice;
  late bool scheduleTask;
  late bool? guidelines;

  WidgetConfig({
    required this.weatherAndPayments,
    required this.expensesSales,
    required this.marketPrice,
    required this.scheduleTask,
    required this.guidelines,
  });

  factory WidgetConfig.fromJson(Map<String, dynamic> json) => WidgetConfig(
      weatherAndPayments: json['weather_date & receivables_payables'] ?? true,
      expensesSales: json['expenses_sales'] ?? true,
      marketPrice: json['near_by_market_price'] ?? true,
      scheduleTask: json['schedulr_task'] ?? true,
      guidelines: json['guidelines'] ?? true,
    );
  // {"detail":"Widget configuration updated successfully.","widget_config":{"id":164,"farmer_id":312,"farmer-name":"teena","weather_date & receivables_payables":true,"expenses_sales":true,"near_by_market_price":false,"schedulr_task":true,"Guidelines":true,"language":{"default":"en"}}}
  Map<String, dynamic> toJson() => {
      'weather_date & receivables_payables': weatherAndPayments,
      'expenses_sales': expensesSales,
      'near_by_market_price': marketPrice,
      'schedulr_task': scheduleTask,
      'guidelines': guidelines,
    };
}
