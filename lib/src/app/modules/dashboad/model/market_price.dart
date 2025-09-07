import 'package:argiot/src/app/modules/dashboad/model/product_price.dart';

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
