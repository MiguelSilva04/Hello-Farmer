import 'package:flutter/material.dart';
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
  late final List<Order> _orders;
  late final List<AppUser> _consumers;
  late final Map<String, List<Order>> _ordersByConsumer;

  @override
  void initState() {
    super.initState();
    final currentUser = (AuthService().currentUser! as ProducerUser);
    final users = AuthService().users;
    _orders =
        currentUser
            .stores[Provider.of<AuthNotifier>(
              context,
              listen: false,
            ).selectedStoreIndex]
            .orders
            ?.where((o) => o.producerId == currentUser.id)
            .toList() ??
        [];

    _ordersByConsumer = {};
    for (final order in _orders) {
      _ordersByConsumer.putIfAbsent(order.consumerId, () => []).add(order);
    }

    _consumers =
        users.where((u) => _ordersByConsumer.keys.contains(u.id)).toList();
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
                              .where((date) => date != null)
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
                  orders
                      .map((o) => o.deliveryDate)
                      .where((date) => date != null)
                      .cast<DateTime>()
                      .toList();
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
                    icon: const Icon(
                      Icons.message_rounded,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      // Lógica para contactar (e.g., abrir WhatsApp ou chat interno)
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
