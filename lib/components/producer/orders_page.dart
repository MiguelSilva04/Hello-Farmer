import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/order_details_page.dart';
import 'package:harvestly/core/models/consumer_user.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/core/services/auth/notification_notifier.dart';
import 'package:harvestly/core/services/auth/store_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../core/models/order.dart';

class OrdersProducerPage extends StatefulWidget {
  const OrdersProducerPage({super.key});

  @override
  State<OrdersProducerPage> createState() => _OrdersProducerPageState();
}

class _OrdersProducerPageState extends State<OrdersProducerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final AuthNotifier _authNotifier;
  late final String _storeId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    _storeId = (_authNotifier.currentUser as ProducerUser)
        .stores[_authNotifier.selectedStoreIndex!]
        .id;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshOrders() async {
    final store = StoreService.instance
        .getStoresByOwner(_authNotifier.currentUser!.id)
        .firstWhere((s) => s.id == _storeId);
    StoreService.instance.listenToOrdersForStore(store);
  }

  Widget _buildEmptyState() {
    return Center(
      child: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              "Sem encomendas ainda.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Aguarde por novas encomendas dos seus clientes.",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(Order order, ConsumerUser? consumer) {
    return Card(
      child: ListTile(
        onTap: () {
          if (consumer == null) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(
                order: order,
                consumer: consumer,
                producer: _authNotifier.currentUser as ProducerUser,
              ),
            ),
          );
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Pedido", style: TextStyle(fontWeight: FontWeight.w600)),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(" #${order.id}",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AutoSizeText(
                order.state.toDisplayString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          "Data da Encomenda: ${DateFormat('d \'de\' MMMM \'de\' y', 'pt_PT').format(order.createdAt)}\n"
          "Data de Entrega Prevista: ${DateFormat('d \'de\' MMMM \'de\' y', 'pt_PT').format(order.deliveryDate)}\n"
          "Morada: ${order.address}",
          style: const TextStyle(fontSize: 16),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildOrdersView([OrderState? stateFilter]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: StreamBuilder<List<Order>>(
        stream: _authNotifier.storeOrdersStream(
          _storeId,
          (orderId, consumerId) async {
            final notifier = Provider.of<NotificationNotifier>(
              context,
              listen: false,
            );
            await notifier.addAbandonedOrderNotification(_storeId, orderId, true);
            await notifier.addAbandonedOrderNotification(consumerId, orderId, false);
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshOrders,
              color: Theme.of(context).colorScheme.secondary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [_buildEmptyState()],
              ),
            );
          }

          final filtered = stateFilter == null
              ? orders
              : orders.where((o) => o.state == stateFilter).toList();

          final sorted = [...filtered]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return RefreshIndicator(
            onRefresh: _refreshOrders,
            color: Theme.of(context).colorScheme.secondary,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final order = sorted[index];
                final consumer = _authNotifier.allUsers
                    .whereType<ConsumerUser>()
                    .firstWhereOrNull((u) => u.id == order.consumerId);
                return _buildOrderTile(order, consumer);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          isScrollable: true,
          controller: _tabController,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Theme.of(context).colorScheme.secondaryFixed,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Pendentes'),
            Tab(text: 'Enviadas'),
            Tab(text: 'Prontas para recolha'),
            Tab(text: 'Entregues'),
            Tab(text: 'Abandonadas'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(context),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersView(),
              _buildOrdersView(OrderState.Pending),
              _buildOrdersView(OrderState.Sent),
              _buildOrdersView(OrderState.Ready),
              _buildOrdersView(OrderState.Delivered),
              _buildOrdersView(OrderState.Abandoned),
            ],
          ),
        ),
      ],
    );
  }
}
