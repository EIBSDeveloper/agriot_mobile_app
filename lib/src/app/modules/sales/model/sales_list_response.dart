import 'package:argiot/src/app/modules/sales/model/sales.dart';
import 'package:argiot/src/app/modules/sales/model/sales_by_date.dart';

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
