import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/app_user.dart';
import '../../../core/models/order.dart';
import '../../../core/models/producer_user.dart';
import '../../../core/services/auth/auth_notifier.dart';
import '../../../core/services/auth/auth_service.dart';
import '../../sendMessageButton.dart';

class ClientsSection extends StatefulWidget {
  const ClientsSection({super.key});

  @override
  State<ClientsSection> createState() => _ClientsSectionState();
}

class _ClientsSectionState extends State<ClientsSection> {
  List<AppUser> _consumers = [];
  Map<String, List<Order>> _ordersByConsumer = {};
  bool _isLoaded = false;
  int _selectedTab = 0;

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
        color: Theme.of(context).colorScheme.secondary,
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
    final frequentes =
        _consumers.where((c) => _ordersByConsumer[c.id]!.length > 3).toList();
    final recentes =
        _consumers.where((c) {
          final orders = _ordersByConsumer[c.id]!;
          final nonNullDates =
              orders.map((o) => o.deliveryDate).whereType<DateTime>().toList();
          if (nonNullDates.isEmpty) return false;
          final last = nonNullDates.reduce((a, b) => a.isAfter(b) ? a : b);
          return DateTime.now().difference(last).inDays <= 7;
        }).toList();

    List<AppUser> filteredConsumers;
    if (_selectedTab == 1) {
      filteredConsumers = frequentes;
    } else if (_selectedTab == 2) {
      filteredConsumers = recentes;
    } else {
      filteredConsumers = _consumers;
    }

    filteredConsumers.sort((a, b) {
      final aDates =
          _ordersByConsumer[a.id]!
              .map((o) => o.deliveryDate)
              .whereType<DateTime>()
              .toList();
      final bDates =
          _ordersByConsumer[b.id]!
              .map((o) => o.deliveryDate)
              .whereType<DateTime>()
              .toList();

      final aLast =
          aDates.isNotEmpty
              ? aDates.reduce((a, b) => a.isAfter(b) ? a : b)
              : DateTime.fromMillisecondsSinceEpoch(0);
      final bLast =
          bDates.isNotEmpty
              ? bDates.reduce((a, b) => a.isAfter(b) ? a : b)
              : DateTime.fromMillisecondsSinceEpoch(0);

      return bLast.compareTo(aLast);
    });

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(12),
                isSelected: [
                  _selectedTab == 0,
                  _selectedTab == 1,
                  _selectedTab == 2,
                ],
                onPressed: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                selectedColor: Theme.of(context).colorScheme.onSecondary,
                fillColor: Theme.of(context).colorScheme.primary,
                color: Theme.of(context).colorScheme.primary,
                constraints: const BoxConstraints(minWidth: 90, minHeight: 36),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("Todos"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("Frequentes"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("Recentes"),
                  ),
                ],
              ),
            ),
          ),
          ListView.builder(
            itemCount: filteredConsumers.length,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              filteredConsumers.sort(
                (a, b) => _ordersByConsumer[b.id]!.length.compareTo(
                  _ordersByConsumer[a.id]!.length,
                ),
              );
              final client = filteredConsumers[index];
              final orders = _ordersByConsumer[client.id]!;
              final totalRecipe = orders.fold(0.0, (a, b) => a + b.totalPrice);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(client.imageUrl),
                    radius: 28,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${client.firstName} ${client.lastName}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 2),
                          if (orders.length > 3)
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Total gasto: ${NumberFormat.simpleCurrency(locale: 'pt_PT').format(totalRecipe)}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  subtitle: null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${orders.length}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  Theme.of(context).colorScheme.tertiaryFixed,
                            ),
                          ),
                          const Text(
                            "Encomendas",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      SendMessageButton(otherUser: client, isIconButton: true,)
                    ],
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
