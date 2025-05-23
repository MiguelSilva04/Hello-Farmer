import 'product.dart';

class ProductAd {
  static int _idCounter = 0;

  final String id;
  final Product product;
  String description;
  String price;
  final String highlight;

  ProductAd({required this.product, String? description, String? price, required this.highlight})
    : description = description ?? "",
      price = price ?? "${product.price!.toStringAsFixed(2)}€/${product.unit.toDisplayString()}",
      id = (_idCounter++).toString();
}
