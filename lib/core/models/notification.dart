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
      case NotificationType.deliveryScheduled:
        return "Entrega agendada";
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
      case NotificationType.deliveryScheduled:
        return "Entrega Nº(${data['order']}) agendada ";
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
  deliveryScheduled,
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
      case NotificationType.deliveryScheduled:
        return Icons.schedule_send_rounded;
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
      case NotificationType.orderSent:
        return Colors.green.shade600; // Verde: enviado com sucesso
      case NotificationType.orderPlaced:
        return Colors.teal.shade600; // Teal: encomenda recebida
      case NotificationType.deliveryScheduled:
        return Colors.indigo.shade600; // Azul escuro: agendamento
      case NotificationType.newReview:
        return Colors.amber.shade800; // Amarelo forte: avaliação
      case NotificationType.newMessage:
        return Colors.blue.shade400; // Azul leve: comunicação
      case NotificationType.abandonedOrder:
        return Colors.grey.shade700; // Cinzento escuro: inatividade
      case NotificationType.lowStock:
        return Colors.red.shade700; // Vermelho: alerta urgente
    }
  }
}
