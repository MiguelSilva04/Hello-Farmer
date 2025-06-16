import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/notification.dart';

class NotificationNotifier extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  StreamSubscription? _notificationsSubscription;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  void listenToNotifications({required String id, required bool isProducer}) {
    final collectionPath =
        isProducer ? 'stores/$id/notifications' : 'users/$id/notifications';

    _notificationsSubscription?.cancel();

    _notificationsSubscription = FirebaseFirestore.instance
        .collection(collectionPath)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((snapshot) {
          _notifications.clear();
          _notifications.addAll(
            snapshot.docs.map((doc) => NotificationItem.fromJson(doc.data())),
          );
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void remove(NotificationItem notification) {
    _notifications.removeWhere((n) => n.id == notification.id);
    notifyListeners();
  }

  void clear() {
    _notifications.clear();
    notifyListeners();
  }

  Future<void> removeNotification({
    required NotificationItem notification,
    required bool isProducer,
    required String id,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection(isProducer ? 'stores' : 'users')
        .doc(id)
        .collection('notifications')
        .doc(notification.id);

    try {
      await docRef.delete();
      remove(notification);
    } catch (e) {
      debugPrint('Erro ao remover notificação: $e');
    }
  }

  Future<void> triggerPushNotificationViaFunction({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'sendNotification',
      );
      final response = await callable.call({
        'token': token,
        'title': title,
        'body': body,
        'data': data ?? {},
      });
      print('Push enviada com sucesso: ${response.data}');
    } catch (e) {
      print('Erro ao chamar função sendNotification: $e');
    }
  }

  Future<void> _addNotificationToFirestore({
    required String userId,
    required String userToken,
    required NotificationType type,
    required Map<String, String> data,
    required bool isProducer,
    required String title,
    required String body,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final docRef =
        firestore
            .collection(isProducer ? 'stores' : 'users')
            .doc(userId)
            .collection('notifications')
            .doc();

    final notification = NotificationItem(
      id: docRef.id,
      type: type,
      data: data,
      dateTime: DateTime.now(),
    );

    await docRef.set({
      'id': notification.id,
      'type': type.name,
      'dateTime': Timestamp.fromDate(notification.dateTime),
      'data': data,
      'userId': userId,
      'userToken': userToken,
    });

    addNotification(notification);

    if (userToken.isNotEmpty) {
      await triggerPushNotificationViaFunction(
        token: userToken,
        title: title,
        body: body,
        data: {'notificationId': notification.id, 'userId': userId},
      );
    }
  }

  Future<void> addOrderPlacedNotification(
    AppUser consumer,
    String storeId,
  ) async {
    final storeDoc =
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .get();
    final token = storeDoc.data()?['token'] ?? '';

    await _addNotificationToFirestore(
      userId: storeId,
      userToken: token,
      type: NotificationType.orderPlaced,
      data: {'consumer': consumer.id, 'store': storeId},
      isProducer: true,
      title: 'Nova encomenda!',
      body: 'Recebeste uma nova encomenda na tua loja.',
    );
  }

  Future<void> addOrderSentNotification(AppUser store, String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final token = userDoc.data()?['token'] ?? '';

    await _addNotificationToFirestore(
      userId: userId,
      userToken: token,
      type: NotificationType.orderSent,
      data: {'store': store.id},
      isProducer: false,
      title: 'A tua encomenda foi enviada!',
      body: 'A tua encomenda da loja ${store.id} foi enviada.',
    );
  }

  Future<void> addDeliveryScheduledNotification(
    String userId,
    String orderId,
  ) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final token = userDoc.data()?['token'] ?? '';

    await _addNotificationToFirestore(
      userId: userId,
      userToken: token,
      type: NotificationType.deliveryScheduled,
      data: {'order': orderId},
      isProducer: false,
      title: 'Entrega agendada!',
      body: 'A entrega da encomenda $orderId foi agendada.',
    );
  }

  Future<void> addNewReviewNotification(
    String storeId,
    String consumerId,
  ) async {
    final storeDoc =
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .get();
    final token = storeDoc.data()?['token'] ?? '';

    await _addNotificationToFirestore(
      userId: storeId,
      userToken: token,
      type: NotificationType.newReview,
      data: {'consumer': consumerId},
      isProducer: true,
      title: 'Nova avaliação!',
      body: 'Recebeste uma nova avaliação de um cliente.',
    );
  }

  Future<void> addNewMessageNotification(
    String receiverId,
    String senderId, {
    required bool isProducer,
  }) async {
    final doc = FirebaseFirestore.instance
        .collection(isProducer ? 'stores' : 'users')
        .doc(receiverId);
    final snapshot = await doc.get();
    final token = snapshot.data()?['token'] ?? '';

    await _addNotificationToFirestore(
      userId: receiverId,
      userToken: token,
      type: NotificationType.newMessage,
      data: {'consumer': senderId},
      isProducer: isProducer,
      title: 'Nova mensagem',
      body: 'Recebeste uma nova mensagem.',
    );
  }

  Future<void> addAbandonedOrderNotification(
    String storeId,
    String orderId,
  ) async {
    final storeDoc =
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .get();
    final token = storeDoc.data()?['token'] ?? '';

    await _addNotificationToFirestore(
      userId: storeId,
      userToken: token,
      type: NotificationType.abandonedOrder,
      data: {'order': orderId},
      isProducer: true,
      title: 'Encomenda abandonada',
      body: 'Uma encomenda foi abandonada.',
    );
  }

  Future<void> addLowStockNotification(String storeId, String adId) async {
    final storeDoc =
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .get();
    final token = storeDoc.data()?['token'] ?? '';

    await _addNotificationToFirestore(
      userId: storeId,
      userToken: token,
      type: NotificationType.lowStock,
      data: {'ad': adId},
      isProducer: true,
      title: 'Stock baixo',
      body: 'O produto $adId está com stock baixo.',
    );
  }
}
