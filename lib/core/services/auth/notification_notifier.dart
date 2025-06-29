import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:harvestly/core/models/consumer_user.dart';
import 'package:harvestly/core/models/producer_user.dart';

import '../../models/app_user.dart';
import '../../models/notification.dart';
import '../../models/store.dart';
import 'auth_notifier.dart';

class NotificationNotifier extends ChangeNotifier {
  late AuthNotifier authNotifier;
  final List<NotificationItem> _notifications = [];
  StreamSubscription? _notificationsSubscription;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  NotificationNotifier(this.authNotifier) {
    _initializeLocalNotifications();
  }

  void updateAuthNotifier(AuthNotifier newNotifier) {
    authNotifier = newNotifier;
    notifyListeners();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

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
          try {
            final list =
                snapshot.docs
                    .map((doc) => NotificationItem.fromJson(doc.data()))
                    .toList();
            _notifications.addAll(list);

            final _currentUser = authNotifier.currentUser;
            if (_currentUser == null) return;

            if (_currentUser.isProducer) {
              final producer = _currentUser as ProducerUser;
              if (producer.stores.isEmpty) return;
              final store = producer.stores[authNotifier.selectedStoreIndex!];
              store.notifications?.addAll(list);
            } else {
              final consumer = _currentUser as ConsumerUser;
              consumer.notifications?.addAll(list);
            }

            notifyListeners();
            authNotifier.notifyListeners();
          } catch (e) {
            print('Erro ao converter notificação: $e');
          }
        });
  }

  Future<void> setupFCM({required String id, required bool isProducer}) async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    final token = await messaging.getToken();

    if (token != null) {
      await _saveToken(id: id, isProducer: isProducer, token: token);
    }

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) _showLocalNotification(message);
    });
  }

  Future<void> logoutCleanup({
    required String userId,
    required bool isProducer,
  }) async {
    _notificationsSubscription?.cancel();
    clear();
  }

  Future<void> _saveToken({
    required String id,
    required bool isProducer,
    required String token,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection(isProducer ? 'stores' : 'users')
        .doc(id);
    await docRef.set({
      'tokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  Future<void> removeToken({
    required String id,
    required bool isProducer,
  }) async {
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    if (token != null) {
      final docRef = FirebaseFirestore.instance
          .collection(isProducer ? 'stores' : 'users')
          .doc(id);
      await docRef.update({
        'tokens': FieldValue.arrayRemove([token]),
      });
    }
  }

  Future<List<String>> _getTokens(String id, bool isProducer) async {
    final doc =
        await FirebaseFirestore.instance
            .collection(isProducer ? 'stores' : 'users')
            .doc(id)
            .get();
    final tokens = doc.data()?['tokens'];
    if (tokens is List) {
      return List<String>.from(tokens);
    }
    return [];
  }

  void _showLocalNotification(RemoteMessage message) {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Notificações',
      channelDescription: 'Canal de notificações padrão',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
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
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'sendNotification',
    );
    for (final token in tokens) {
      print("Token a enviar notificacao: $token");
      try {
        final response = await callable.call({
          'token': token,
          'title': title,
          'body': body,
          'data': data ?? {},
        });
        print('Push enviada para $token com sucesso: ${response.data}');
      } catch (e) {
        print('Erro ao enviar push para $token: $e');
      }
    }
  }

  Future<void> _createAndSendNotification({
    required String userId,
    required NotificationType type,
    required Map<String, String> data,
    required bool isProducer,
    required String title,
    required String body,
  }) async {
    final userTokens = await _getTokens(userId, isProducer);

    final docRef =
        FirebaseFirestore.instance
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
      'userTokens': userTokens,
    });

    addNotification(notification);

    if (userTokens.isNotEmpty) {
      await triggerPushNotificationViaFunction(
        tokens: userTokens,
        title: title,
        body: body,
        data: {'notificationId': notification.id, 'userId': userId},
      );
    }
  }

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  Future<void> addOrderPlacedNotification(AppUser consumer, String storeId) =>
      _createAndSendNotification(
        userId: storeId,
        type: NotificationType.orderPlaced,
        data: {'consumer': consumer.id, 'store': storeId},
        isProducer: true,
        title: 'Nova encomenda!',
        body: 'Recebeste uma nova encomenda na tua loja.',
      );

  Future<void> addOrderSentNotification(Store store, String userId) =>
      _createAndSendNotification(
        userId: userId,
        type: NotificationType.orderSent,
        data: {'store': store.id},
        isProducer: false,
        title: 'A tua encomenda foi enviada!',
        body: 'A tua encomenda da loja ${store.name} foi enviada.',
      );

  Future<void> addNewReviewNotification(String storeId, String consumerId) =>
      _createAndSendNotification(
        userId: storeId,
        type: NotificationType.newReview,
        data: {'consumer': consumerId},
        isProducer: true,
        title: 'Nova avaliação!',
        body: 'Recebeste uma nova avaliação de um cliente.',
      );

  Future<void> addNewMessageNotification(
    String receiverId,
    String senderId, {
    required bool isProducer,
  }) => _createAndSendNotification(
    userId: receiverId,
    type: NotificationType.newMessage,
    data: {'consumer': senderId},
    isProducer: isProducer,
    title: 'Nova mensagem',
    body: 'Recebeste uma nova mensagem.',
  );

  Future<void> addAbandonedOrderNotification(String storeId, String orderId) =>
      _createAndSendNotification(
        userId: storeId,
        type: NotificationType.abandonedOrder,
        data: {'order': orderId},
        isProducer: true,
        title: 'Encomenda abandonada',
        body: 'Uma encomenda foi abandonada no carrinho.',
      );
}
