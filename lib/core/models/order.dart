enum OrderState {
  Entregue,
  Pendente,
  Enviada,
}

class Order {
  final String id;
  final DateTime pickupDate;
  final DateTime deliveryDate;
  final String address;
  final OrderState state;

  Order({
    required this.id,
    required this.pickupDate,
    required this.deliveryDate,
    required this.address,
    required this.state,
  });
}
