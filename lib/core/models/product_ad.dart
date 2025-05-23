import 'product.dart';

class ProductAd {
  static int _idCounter = 0;

  final String id;
  final Product product;
  String price;
  final String highlight;

  ProductAd({
    required this.product,
    String? price,
    required this.highlight,
  }) : price =
           price ??
           "${product.price!.toStringAsFixed(2)}€/${product.unit.toDisplayString()}",
       id = (_idCounter++).toString();
}
