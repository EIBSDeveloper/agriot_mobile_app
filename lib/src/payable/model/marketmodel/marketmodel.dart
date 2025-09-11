// ===== Model Classes =====
class MarketReport {
  final String market;
  final List<Price> price;


  MarketReport({
    required this.market,
    required this.price,
   
  });

  factory MarketReport.fromJson(Map<String, dynamic> json) => MarketReport(
    market: json["market"],
    price: List<Price>.from(json["price"].map((x) => Price.fromJson(x))),

  );
}

class Price {
  final String product;
  final int productPrice;

  Price({required this.product, required this.productPrice});

  factory Price.fromJson(Map<String, dynamic> json) =>
      Price(product: json["product"], productPrice: json["product_price"]);
}
