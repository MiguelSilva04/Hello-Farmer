import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/notification.dart';

class NotificationNotifier extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  Future<void> loadNotifications({
    required String id,
    required bool isProducer,
  }) async {
    try {
      final collectionPath =
          isProducer ? 'stores/$id/notifications' : 'users/$id/notifications';

      final querySnapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();

      _notifications.clear();

      final items =
          querySnapshot.docs.map((doc) {
              print(doc.data());
              return NotificationItem.fromJson(doc.data());
            }).toList()
            ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

      _notifications.addAll(items);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar notificações: $e');
    }
  }

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void clear() {
    _notifications.clear();
    notifyListeners();
  }

  Future<void> addOrderSentNofication(AppUser consumer, String storeId) async {
    final notificationDoc =
        FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .collection('notifications')
            .doc();

    final notification = NotificationItem(
      id: notificationDoc.id,
      type: NotificationType.orderPlaced,
      dateTime: DateTime.now(),
      data: {'consumer': consumer.id, 'store': storeId},
    );

    final userToken = consumer.token ?? '';

    await notificationDoc.set({
      'id': notification.id,
      'type': notification.type.name,
      'dateTime': Timestamp.fromDate(notification.dateTime),
      'data': notification.data,
      'userId': storeId,
      'userToken': userToken,
    });

    addNotification(notification);
  }
}
