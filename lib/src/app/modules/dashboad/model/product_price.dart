class ProductPrice {
  final String product;
  final double price;

  ProductPrice({required this.product, required this.price});

  factory ProductPrice.fromJson(Map<String, dynamic> json) => ProductPrice(
    product: json['product'],
    price: json['product_price']?.toDouble() ?? 0.0,
  );
}
