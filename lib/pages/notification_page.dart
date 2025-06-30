import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/order_details_page.dart';
import 'package:harvestly/components/consumer/product_ad_detail_screen.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:provider/provider.dart';
import 'package:harvestly/core/services/auth/notification_notifier.dart';
import 'package:harvestly/core/models/notification.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/services/chat/chat_service.dart';
import '../core/services/chat/chat_list_notifier.dart';
import '../utils/user_store_helper.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Future<void> redirect(NotificationItem notification) async {
    final data = notification.data;
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    switch (notification.type) {
      case NotificationType.orderPlaced:
      case NotificationType.orderSent:
      case NotificationType.abandonedOrder:
        final orderId = data['order'];
        if (orderId != null) {
          final authNotifier = Provider.of<AuthNotifier>(
            context,
            listen: false,
          );

          final producer = authNotifier.producerUsers.firstWhere(
            (p) => p.stores.any(
              (store) =>
                  store.orders?.any((order) => order.id == orderId) ?? false,
            ),
          );

          final store = producer.stores.firstWhere(
            (s) => s.orders?.any((o) => o.id == orderId) ?? false,
          );

          final order = store.orders!.firstWhere((o) => o.id == orderId);

          if (!mounted) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => OrderDetailsPage(order: order, producer: producer),
            ),
          );
        }

      case NotificationType.newReview:
        final adId = data['productAd'];
        if (adId != null) {
          final authNotifier = Provider.of<AuthNotifier>(
            context,
            listen: false,
          );

          final producer = authNotifier.producerUsers.firstWhere(
            (p) => p.stores.any(
              (store) => store.productsAds?.any((ad) => ad.id == adId) ?? false,
            ),
          );

          final store = producer.stores.firstWhere(
            (s) => s.productsAds?.any((a) => a.id == adId) ?? false,
          );

          final ad = store.productsAds!.firstWhere((a) => a.id == adId);

          if (!mounted) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductAdDetailScreen(ad: ad, producer: producer),
            ),
          );
        }
        break;

      case NotificationType.newMessage:
        final senderId = data['sender'];
        if (senderId != null) {
          final chatListNotifier = Provider.of<ChatListNotifier>(
            context,
            listen: false,
          );
          final chatService = Provider.of<ChatService>(context, listen: false);
          final currentUserId = authNotifier.currentUser!.id;

          final chat = chatListNotifier.chats.firstWhere(
            (c) =>
                (c.consumerId == currentUserId && c.producerId == senderId) ||
                (c.producerId == currentUserId && c.consumerId == senderId),
            orElse: () => throw Exception('Chat não encontrado'),
          );

          chatService.updateCurrentChat(chat);

          Provider.of<BottomNavigationNotifier>(
            context,
            listen: false,
          ).setIndex(3);

          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final user = authNotifier.currentUser!;
    final id =
        user.isProducer
            ? (user as ProducerUser).stores[authNotifier.selectedStoreIndex!].id
            : user.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Notificacoes'), centerTitle: true),
      body: StreamBuilder<List<NotificationItem>>(
        stream: AuthService().getUserNotificationsStream(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Sem notificacoes",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          final notifications = snapshot.data!;
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    onDismissed: (_) async {
                      await Provider.of<NotificationNotifier>(
                        context,
                        listen: false,
                      ).removeNotification(
                        notification: notification,
                        isProducer: user.isProducer,
                        id: id,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notificacao removida')),
                      );
                    },
                    child: ListTile(
                      onTap: () => redirect(notification),
                      leading: CircleAvatar(
                        backgroundColor: notification.type.color.withOpacity(
                          .85,
                        ),
                        child: Icon(
                          notification.type.icon,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(description),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(notification.dateTime),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
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
        return "Nova avaliacao de $dynamicName";
      case NotificationType.abandonedOrder:
        return "Encomenda abandonada (${notification.data["order"]})";
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    if (date == today) return "Hoje às $hour:$minute";
    if (date == yesterday) return "Ontem às $hour:$minute";
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} às $hour:$minute";
  }
}
