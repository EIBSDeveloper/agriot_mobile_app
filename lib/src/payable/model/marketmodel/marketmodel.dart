// // ===== Model Classes =====
// class MarketReport {
//   final String market;
//   final List<Price> price;
//   final Language language;

//   MarketReport({
//     required this.market,
//     required this.price,
//     required this.language,
//   });

//   factory MarketReport.fromJson(Map<String, dynamic> json) => MarketReport(
//     market: json["market"],
//     price: List<Price>.from(json["price"].map((x) => Price.fromJson(x))),
//     language: Language.fromJson(json["language"]),
//   );
// }

// class Price {
//   final String product;
//   final int productPrice;

//   Price({required this.product, required this.productPrice});

//   factory Price.fromJson(Map<String, dynamic> json) =>
//       Price(product: json["product"], productPrice: json["product_price"]);
// }

// class Language {
//   final String defaultLang;

//   Language({required this.defaultLang});

//   factory Language.fromJson(Map<String, dynamic> json) =>
//       Language(defaultLang: json["default"]);
// }
