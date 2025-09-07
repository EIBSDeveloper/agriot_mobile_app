import 'package:argiot/src/app/modules/task/view/screens/screen.dart';

class Customer extends NamedItem {
  @override
  final int id;
  @override
  final String name;
  final String shopName;

  Customer({required this.id, required this.name, this.shopName = ''});

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['customer_name'] ?? '',
      shopName: json['shop_name'] ?? '',
    );
}
