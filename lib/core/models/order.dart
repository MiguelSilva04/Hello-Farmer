import 'package:cloud_firestore/cloud_firestore.dart' as cf;

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
  final String productAdId;
  final double qty;

  OrderItem({required this.productAdId, required this.qty});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productAdId: json['productId'],
      qty: (json['quantity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'productId': productAdId, 'quantity': qty};
  }
}

class Order {
  final String id;
  final DateTime createdAt;
  DateTime deliveryDate;
  final String address;
  final OrderState state;
  final List<OrderItem> ordersItems;
  final double totalPrice;
  final String consumerId;
  final String storeId;

  Order({
    required this.id,
    required this.createdAt,
    required this.deliveryDate,
    required this.address,
    required this.state,
    required this.ordersItems,
    required this.totalPrice,
    required this.consumerId,
    required this.storeId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? "",
      createdAt:
          (json['createdAt'] is cf.Timestamp)
              ? (json['createdAt'] as cf.Timestamp).toDate()
              : json['createdAt'],
      deliveryDate:
          (json['deliveryDate'] is cf.Timestamp)
              ? (json['deliveryDate'] as cf.Timestamp).toDate()
              : json['deliveryDate'],
      address: json['address'],
      state: OrderState.values.firstWhere(
        (e) => e.toDisplayString() == json['status'],
      ),
      ordersItems:
          (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      consumerId: json['consumerId'],
      storeId: json['storeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryDate': deliveryDate.toIso8601String(),
      'address': address,
      'state': state.toString().split('.').last,
      'ordersItems': ordersItems.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice,
      'consumerId': consumerId,
      'storeId': storeId,
    };
  }
}
