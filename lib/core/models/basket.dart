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
  final List<Map<String, int>> productsAmounts;

  Basket({
    required this.name,
    required this.price,
    required this.deliveryDate,
    required this.productsAmounts,
  });

  Basket copyWith({
    String? name,
    double? price,
    DeliveryDate? deliveryDate,
    List<Map<String, int>>? products,
  }) {
    return Basket(
      name: name ?? this.name,
      price: price ?? this.price,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      productsAmounts: products ?? this.productsAmounts,
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
      productsAmounts:
          (map['products'])
              .map((item) => Product.fromMap(item as Map<String, int>))
              .toList(),
    );
  }
}
