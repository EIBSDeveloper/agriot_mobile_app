import 'package:argiot/src/app/modules/sales/model/sales.dart';

class SalesByDate {
  final String date;
  final List<Sales> sales;

  SalesByDate({
    required this.date,
    required this.sales,
  });
}
