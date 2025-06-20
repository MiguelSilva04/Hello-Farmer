
import 'package:flutter/material.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:harvestly/core/services/auth/notification_notifier.dart';
import 'package:harvestly/core/models/notification.dart';

import '../core/models/consumer_user.dart';
import '../utils/user_store_helper.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final user = authNotifier.currentUser!;
    final notificationProvider = Provider.of<NotificationNotifier>(context);
    final currentNotifications =
        user.isProducer
            ? (user as ProducerUser)
                .stores[authNotifier.selectedStoreIndex!]
                .notifications
            : (user as ConsumerUser).notifications;
    final userNotificationIds =
        currentNotifications?.map((n) => n.id).toSet() ?? {};

    final notifications =
        notificationProvider.notifications
            .where((n) => userNotificationIds.contains(n.id))
            .toList();

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
                        onDismissed: (_) async {
                          await notificationProvider.removeNotification(
                            notification: notification,
                            isProducer: authNotifier.currentUser!.isProducer,
                            id:
                                (!authNotifier.currentUser!.isProducer)
                                    ? authNotifier.currentUser!.id
                                    : (authNotifier.currentUser!
                                            as ProducerUser)
                                        .stores[authNotifier.selectedStoreIndex!]
                                        .id,
                          );
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
      case NotificationType.lowStock:
        return "Stock baixo de ${notification.data['ad']} (${dynamicName})";
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    if (date == today) {
      return "Hoje às $hour:$minute";
    } else if (date == yesterday) {
      return "Ontem às $hour:$minute";
    } else {
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      return "$day/$month às $hour:$minute";
    }
  }
}
