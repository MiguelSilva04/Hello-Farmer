enum OrderState { Delivered, Pendent, Sent, Abandonned }

extension OrderStateExtension on OrderState {
  String toDisplayString() {
    switch (this) {
      case OrderState.Delivered:
        return "Entregue";
      case OrderState.Pendent:
        return "Pendente";
      case OrderState.Sent:
        return "Enviada";
      case OrderState.Abandonned:
        return "Abandonada";
    }
  }
}

class OrderItem {
  final String produtctAdId;
  final double qty;

  OrderItem({required this.produtctAdId, required this.qty});
}

class Order {
  final String id;
  final DateTime pickupDate;
  DateTime? deliveryDate;
  final String address;
  final OrderState state;
  final List<OrderItem> productsAds;
  final double totalPrice;
  final String consumerId;
  final String deliveryAddress;
  final String producerId;

  Order({
    required this.id,
    required this.pickupDate,
    required this.deliveryDate,
    required this.address,
    required this.state,
    required this.productsAds,
    required this.totalPrice,
    required this.consumerId,
    required this.producerId,
    required this.deliveryAddress,
  });
}
