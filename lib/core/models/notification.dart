import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final NotificationType type;
  final DateTime dateTime;
  final Map<String, String> data;

  NotificationItem({
    required this.id,
    required this.type,
    required this.data,
    required this.dateTime,
  });

  String get title {
    switch (type) {
      case NotificationType.orderPlaced:
        return "Encomendada colocada";
      case NotificationType.orderSent:
        return "Encomenda enviada";
      case NotificationType.newMessage:
        return "Nova mensagem";
      case NotificationType.newReview:
        return "Nova avaliação";
      case NotificationType.abandonedOrder:
        return "Encomenda abandonada";
      case NotificationType.lowStock:
        return "Stock baixo";
    }
  }

  String get description {
    switch (type) {
      case NotificationType.orderPlaced:
        return "Encomenda colocada por ${data["consumer"]}";
      case NotificationType.orderSent:
        return "Encomenda enviada por ${data["store"]}";
      case NotificationType.newMessage:
        return "Nova mensagem de ${data["consumer"]}";
      case NotificationType.newReview:
        return "Nova avaliação de ${data["consumer"]}";
      case NotificationType.abandonedOrder:
        return "Encomenda abandonada (${data["order"]})";
      case NotificationType.lowStock:
        return "Stock baixo de (${data['ad']})";
    }
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.orderPlaced,
      ),
      data: Map<String, String>.from(json['data'] ?? {}),
      dateTime: (json['dateTime'] as Timestamp).toDate(),
    );
  }
}

enum NotificationType {
  orderPlaced,
  orderSent,
  newReview,
  newMessage,
  abandonedOrder,
  lowStock,
}

extension NotificationTypeIcon on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.orderSent:
        return Icons.local_shipping_rounded;
      case NotificationType.orderPlaced:
        return Icons.shopping_cart_checkout_rounded;
      case NotificationType.newReview:
        return Icons.reviews_rounded;
      case NotificationType.newMessage:
        return Icons.markunread_rounded;
      case NotificationType.abandonedOrder:
        return Icons.shopping_bag_outlined;
      case NotificationType.lowStock:
        return Icons.warning_amber_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.orderPlaced:
        return Colors.indigo.shade600;
      case NotificationType.orderSent:
        return Colors.green.shade600;
      case NotificationType.newReview:
        return Colors.amber.shade800;
      case NotificationType.newMessage:
        return Colors.blue.shade400;
      case NotificationType.abandonedOrder:
        return Colors.grey.shade700;
      case NotificationType.lowStock:
        return Colors.red.shade700;
    }
  }
}
