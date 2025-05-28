import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.type,
  });
}

enum NotificationType {
  orderSent,
  deliveryScheduled,
  adPublished,
  newReview,
  newMessage,
}

extension NotificationTypeIcon on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.orderSent:
        return Icons.local_shipping;
      case NotificationType.deliveryScheduled:
        return Icons.local_shipping_outlined;
      case NotificationType.adPublished:
        return Icons.campaign;
      case NotificationType.newReview:
        return Icons.star;
      case NotificationType.newMessage:
        return Icons.message;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.orderSent:
        return Colors.orange;
      case NotificationType.deliveryScheduled:
        return Colors.blue;
      case NotificationType.adPublished:
        return Colors.redAccent;
      case NotificationType.newReview:
        return Colors.amber;
      case NotificationType.newMessage:
        return Colors.blueAccent;
    }
  }
}