import 'package:flutter/material.dart';
import 'package:harvestly/core/services/chat/chat_list_notifier.dart';
import 'package:harvestly/core/services/chat/chat_service.dart';
import 'package:harvestly/utils/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/app_user.dart';
import '../../../core/models/order.dart';
import '../../../core/models/producer_user.dart';
import '../../../core/services/auth/auth_notifier.dart';
import '../../../core/services/auth/auth_service.dart';

class ClientsSection extends StatefulWidget {
  const ClientsSection({super.key});

  @override
  State<ClientsSection> createState() => _ClientsSectionState();
}

class _ClientsSectionState extends State<ClientsSection> {
  List<AppUser> _consumers = [];
  Map<String, List<Order>> _ordersByConsumer = {};
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isLoaded) {
      final currentUser = (AuthService().currentUser! as ProducerUser);
      final users = Provider.of<AuthNotifier>(context, listen: false).allUsers;
      final selectedStore =
          currentUser.stores[Provider.of<AuthNotifier>(
            context,
            listen: false,
          ).selectedStoreIndex!];

      final orders = selectedStore.orders ?? [];

      final ordersByConsumer = <String, List<Order>>{};
      for (final order in orders) {
        ordersByConsumer.putIfAbsent(order.consumerId, () => []).add(order);
      }

      final consumers =
          users.where((u) => ordersByConsumer.keys.contains(u.id)).toList();

      setState(() {
        _ordersByConsumer = ordersByConsumer;
        _consumers = consumers;
        _isLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Os teus Clientes",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                "Total",
                _consumers.length.toString(),
                Icons.people,
              ),
              _buildStatCard(
                "Frequente",
                _consumers
                    .where((c) => _ordersByConsumer[c.id]!.length > 3)
                    .length
                    .toString(),
                Icons.star,
              ),
              _buildStatCard(
                "Recentes",
                _consumers
                    .where((c) {
                      final orders = _ordersByConsumer[c.id]!;
                      final nonNullDates =
                          orders
                              .map((o) => o.deliveryDate)
                              .cast<DateTime>()
                              .toList();
                      if (nonNullDates.isEmpty) return false;
                      final last = nonNullDates.reduce(
                        (a, b) => a.isAfter(b) ? a : b,
                      );
                      return DateTime.now().difference(last).inDays <= 7;
                    })
                    .length
                    .toString(),
                Icons.history,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.tertiaryFixedDim,
            Theme.of(context).colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          ListView.builder(
            itemCount: _consumers.length,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              _consumers.sort(
                (a, b) => _ordersByConsumer[b.id]!.length.compareTo(
                  _ordersByConsumer[a.id]!.length,
                ),
              );
              final client = _consumers[index];
              final orders = _ordersByConsumer[client.id]!;
              final nonNullDates =
                  orders.map((o) => o.deliveryDate).cast<DateTime>().toList();
              final lastOrderDate =
                  nonNullDates.isNotEmpty
                      ? nonNullDates.reduce((a, b) => a.isAfter(b) ? a : b)
                      : null;
              final formattedDate =
                  lastOrderDate != null
                      ? DateFormat.yMMMd().format(lastOrderDate)
                      : 'Abandonada';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.tertiaryFixedDim,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(client.imageUrl),
                    radius: 28,
                  ),
                  title: Row(
                    children: [
                      Text(
                        "${client.firstName} ${client.lastName}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 2),
                      if (orders.length > 3)
                        const Icon(Icons.star, color: Colors.amber, size: 25),
                    ],
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Telefone: ${client.phone}"),
                      Text("Encomendas: ${orders.length}"),
                      Text("Última encomenda: $formattedDate"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.message_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () async {
                      final chatService = Provider.of<ChatService>(
                        context,
                        listen: false,
                      );
                      final currentUser =
                          AuthService().currentUser! as ProducerUser;
                      final otherUser = client;

                      final chatList =
                          Provider.of<ChatListNotifier>(
                            context,
                            listen: false,
                          ).chats;
                      final existingChat = chatList.firstWhere(
                        (chat) =>
                            (chat.consumerId == currentUser.id &&
                                chat.producerId == otherUser.id) ||
                            (chat.producerId == currentUser.id &&
                                chat.consumerId == otherUser.id),
                      );
                      chatService.updateCurrentChat(existingChat);
                      Navigator.of(context).pushNamed(AppRoutes.CHAT_PAGE);

                      // Criar nova conversa
                      final _messageController = TextEditingController();
                      final result = await showDialog<String>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: Text("Enviar mensagem"),
                              content: TextField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  hintText: "Escreve a tua mensagem...",
                                ),
                                maxLines: null,
                                autofocus: true,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text("Fechar"),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(
                                        ctx,
                                      ).pop(_messageController.text.trim()),
                                  child: const Text("Enviar"),
                                ),
                              ],
                            ),
                      );
                      if (result != null && result.isNotEmpty) {
                        final newChat = await chatService.createChat(
                          currentUser.isProducer
                              ? otherUser.id
                              : currentUser.id,
                          currentUser.isProducer
                              ? currentUser.id
                              : otherUser.id,
                        );

                        await chatService.save(result, currentUser, newChat.id);

                        Provider.of<ChatListNotifier>(
                          context,
                          listen: false,
                        ).addChat(newChat);

                        chatService.updateCurrentChat(newChat);

                        Navigator.of(context).pushNamed(AppRoutes.CHAT_PAGE);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
