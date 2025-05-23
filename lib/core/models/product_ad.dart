import 'product.dart';

class ProductAd {
  static int _idCounter = 0;

  final String id;
  final Product product;
  String description;
  String price;
  String description = "";
  String highlight;


  ProductAd({
    required this.product,
    String? price,
    String? description,
    required this.highlight,
  }) : price =
           price ??
           "${product.price!.toStringAsFixed(2)}€/${product.unit.toDisplayString()}",
       id = (_idCounter++).toString();
}
