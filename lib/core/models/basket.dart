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
}
