import 'product.dart';

enum DeliveryDate {
  SUNDAY,
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY,
}

extension DeliveryDateExtension on DeliveryDate {
  String toDisplayString() {
    switch (this) {
      case DeliveryDate.SUNDAY:
        return "Domingo";
      case DeliveryDate.MONDAY:
        return "Segunda-feira";
      case DeliveryDate.TUESDAY:
        return "Terça-feira";
      case DeliveryDate.WEDNESDAY:
        return "Quarta-feira";
      case DeliveryDate.THURSDAY:
        return "Quinta-feira";
      case DeliveryDate.FRIDAY:
        return "Sexta-feira";
      case DeliveryDate.SATURDAY:
        return "Sábado";
    }
  }
}

class Basket {
  String name;
  double price;
  DeliveryDate deliveryDate;
  final List<Product> products;

  Basket({
    required this.name,
    required this.price,
    required this.deliveryDate,
    required this.products,
  });

  Basket copyWith({
    String? name,
    double? price,
    DeliveryDate? deliveryDate,
    List<Product>? products,
  }) {
    return Basket(
      name: name ?? this.name,
      price: price ?? this.price,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      products: products ?? this.products,
    );
  }

  factory Basket.fromMap(Map<String, dynamic> map) {
    return Basket(
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      deliveryDate: DeliveryDate.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            (map['deliveryDate'] as String).toUpperCase(),
      ),
      products:
          (map['products'] as List)
              .map((item) => Product.fromMap(item as Map<String, dynamic>))
              .toList(),
    );
  }
}
