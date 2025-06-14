import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/order.dart';
import '../../core/services/auth/auth_notifier.dart';

class SellsPage extends StatefulWidget {
  const SellsPage({super.key});

  @override
  State<SellsPage> createState() => _SellsPageState();
}

class _SellsPageState extends State<SellsPage>
    with SingleTickerProviderStateMixin {
  String formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  late final TabController _tabController;

  late List<Order> orders;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    orders =
        (authNotifier.currentUser as ProducerUser)
            .stores[authNotifier.selectedStoreIndex]
            .orders ??
        [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget getAllFilter([state]) {
    final ordersFiltered =
        state == null
            ? orders
            : orders.where((order) => order.state == state).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        itemCount: ordersFiltered.length,
        itemBuilder:
            (context, index) => Card(
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Pedido #${ordersFiltered[index].id}",
                          style: TextStyle(fontWeight: FontWeight.w600),
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
                          ordersFiltered[index].state.toDisplayString(),
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
                  "Data da Encomenda: ${DateFormat('d \'de\' MMMM \'de\' y', 'pt_PT').format(ordersFiltered[index].createdAt)}\n${"Data de Entrega Prevista: ${DateFormat('d \'de\' MMMM \'de\' y', 'pt_PT').format(ordersFiltered[index].deliveryDate)}"}\nMorada: ${ordersFiltered[index].address}",
                  style: TextStyle(fontSize: 16),
                ),
                isThreeLine: true,
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom tab bar (pode estar onde quiseres)
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: Text(
              //     "As minhas vendas",
              //     style: TextStyle(
              //       fontSize: 30,
              //       fontWeight: FontWeight.w600,
              //       color: Theme.of(context).colorScheme.secondary,
              //     ),
              //   ),
              // ),
              TabBar(
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
                  Tab(text: 'Entregues'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBarView(
              controller: _tabController,
              children: [
                Center(child: getAllFilter()),
                Center(child: getAllFilter(OrderState.Pendent)),
                Center(child: getAllFilter(OrderState.Sent)),
                Center(child: getAllFilter(OrderState.Delivered)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
