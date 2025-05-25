import 'package:harvestly/core/models/store.dart';

import 'product.dart';

class ProductAd {
  static int _idCounter = 0;

  final String id;
  final Product product;
  String description = "";
  String price;
  String highlight;
  List<DeliveryMethod> preferredDeliveryMethods;
  List<Map<DateTime, String>>? viewsByUserDateTime;

  ProductAd({
    required this.product,
    required this.preferredDeliveryMethods,
    String? description,
    String? price,
    this.viewsByUserDateTime,
    required this.highlight,
  }) : description = description ?? "",
       price =
           price ??
           "${product.price!.toStringAsFixed(2)}€/${product.unit.toDisplayString()}",
       id = (_idCounter++).toString();
}
