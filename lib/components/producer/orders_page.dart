import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/order_details_page.dart';
import 'package:harvestly/core/models/consumer_user.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/order.dart';
import '../../core/services/auth/auth_notifier.dart';
import '../../core/services/auth/store_service.dart';

class OrdersProducerPage extends StatefulWidget {
  const OrdersProducerPage({super.key});

  @override
  State<OrdersProducerPage> createState() => _OrdersProducerPageState();
}

class _OrdersProducerPageState extends State<OrdersProducerPage>
    with SingleTickerProviderStateMixin {
  String formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  late final TabController _tabController;
  late AuthNotifier authNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    authNotifier = Provider.of<AuthNotifier>(context, listen: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget getAllFilter([OrderState? stateFilter]) {
    final storeId =
        (authNotifier.currentUser as ProducerUser)
            .stores[authNotifier.selectedStoreIndex!]
            .id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: StreamBuilder<List<Order>>(
        stream: authNotifier.storeOrdersStream(storeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
              color: Theme.of(context).colorScheme.secondary,
              onRefresh: () async {
                final store = StoreService.instance
                    .getStoresByOwner(authNotifier.currentUser!.id)
                    .firstWhere((s) => s.id == storeId);
                StoreService.instance.listenToOrdersForStore(store);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(child: Text("Sem encomendas ainda.")),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!;
          final filteredOrders =
              stateFilter == null
                  ? orders
                  : orders
                      .where((order) => order.state == stateFilter)
                      .toList();

          return RefreshIndicator(
            color: Theme.of(context).colorScheme.secondary,
            onRefresh: () async {
              final store = StoreService.instance
                  .getStoresByOwner(authNotifier.currentUser!.id)
                  .firstWhere((s) => s.id == storeId);
              StoreService.instance.listenToOrdersForStore(store);
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                final consumer =
                    authNotifier.allUsers
                            .where((u) => u.id == order.consumerId)
                            .first
                        as ConsumerUser;

                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (ctx) => OrderDetailsPage(
                                order: order,
                                producer:
                                    (authNotifier.currentUser as ProducerUser),
                                consumer: consumer,
                              ),
                        ),
                      );
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pedido",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              " #${order.id}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: AutoSizeText(
                              order.state.toDisplayString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
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
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(context),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBarView(
              controller: _tabController,
              children: [
                Center(child: getAllFilter()),
                Center(child: getAllFilter(OrderState.Pending)),
                Center(child: getAllFilter(OrderState.Sent)),
                Center(child: getAllFilter(OrderState.Ready)),
                Center(child: getAllFilter(OrderState.Delivered)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.surface,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.secondary,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.secondaryFixed,
                indicatorColor: Theme.of(context).colorScheme.secondary,
                tabs: const [
                  Tab(text: 'Todas'),
                  Tab(text: 'Pendentes'),
                  Tab(text: 'Enviadas'),
                  Tab(text: 'Prontas para recolha'),
                  Tab(text: 'Entregues'),
                ],
              ),
            ],
          ),
        ),
      );
  }
}
