import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harvestly/core/services/auth/notification_notifier.dart';
import 'package:harvestly/core/models/notification.dart';

import '../utils/user_store_helper.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final notifications =
        Provider.of<NotificationNotifier>(context).notifications;

    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body:
          notifications.isNotEmpty
              ? ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  return FutureBuilder<String>(
                    future: _getDynamicName(notification),
                    builder: (context, snapshot) {
                      final dynamicName = snapshot.data ?? '';
                      final description = _buildDescription(
                        notification,
                        dynamicName,
                      );

                      return Dismissible(
                        key: Key(notification.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          setState(() {
                            notifications.removeAt(index);
                          });
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: notification.type.color,
                            child: Icon(
                              notification.type.icon,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(notification.title),
                          subtitle: Text(description),
                          trailing: Text(
                            _formatDate(notification.dateTime),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
              : const Center(child: Text("Sem notificações")),
    );
  }

  Future<String> _getDynamicName(NotificationItem notification) async {
    final data = notification.data;
    switch (notification.type) {
      case NotificationType.orderPlaced:
      case NotificationType.newMessage:
      case NotificationType.newReview:
        final consumerId = data['consumer'];
        if (consumerId != null)
          return await UserStoreHelper.getUserName(consumerId);
        break;

      case NotificationType.orderSent:
      case NotificationType.lowStock:
        final storeId = data['store'];
        if (storeId != null) return await UserStoreHelper.getStoreName(storeId);
        break;

      default:
        return '';
    }
    return '';
  }

  String _buildDescription(NotificationItem notification, String dynamicName) {
    switch (notification.type) {
      case NotificationType.orderSent:
        return "Encomenda enviada por $dynamicName";
      case NotificationType.orderPlaced:
        return "Encomenda colocada por $dynamicName";
      case NotificationType.newMessage:
        return "Nova mensagem de $dynamicName";
      case NotificationType.newReview:
        return "Nova avaliação de $dynamicName";
      case NotificationType.abandonedOrder:
        return "Encomenda abandonada (${notification.data["order"]})";
      case NotificationType.deliveryScheduled:
        return "Entrega Nº(${notification.data['order']}) agendada";
      case NotificationType.lowStock:
        return "Stock baixo de ${notification.data['ad']} (${dynamicName})";
    }
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return "$day/$month às $hour:$minute";
  }
}
