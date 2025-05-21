import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/order.dart';

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

  final List<Order> orders = [
    Order(
      id: '1001',
      pickupDate: DateTime(2025, 4, 5),
      deliveryDate: DateTime(2025, 4, 6),
      address: 'Rua do Pedido #1001',
      state: OrderState.Entregue,
      totalPrice: 20.34
    ),
    Order(
      id: '0078',
      pickupDate: DateTime(2025, 4, 15),
      deliveryDate: DateTime(2025, 5, 19),
      address: 'Rua do Pedido #0078',
      state: OrderState.Pendente,
      totalPrice: 25.12
    ),
    Order(
      id: '0832',
      pickupDate: DateTime(2025, 4, 15),
      deliveryDate: DateTime(2025, 4, 30),
      address: 'Rua do Pedido #0832',
      state: OrderState.Enviada,
      totalPrice: 30.59
    ),
    Order(
      id: '3627',
      pickupDate: DateTime(2025, 4, 29),
      deliveryDate: DateTime(2025, 5, 4),
      address: 'Rua do Pedido #3627',
      state: OrderState.Pendente,
      totalPrice: 17.36
    ),
    Order(
      id: '1938',
      pickupDate: DateTime(2025, 4, 1),
      deliveryDate: DateTime(2025, 4, 2),
      address: 'Rua do Pedido #1938',
      state: OrderState.Entregue,
      totalPrice: 13.84
    ),
    Order(
      id: '8809',
      pickupDate: DateTime(2025, 4, 1),
      deliveryDate: DateTime(2025, 4, 2),
      address: 'Rua do Pedido #8809',
      state: OrderState.Entregue,
      totalPrice: 69.11
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                title: Text(
                  "Pedido #${ordersFiltered[index].id}",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "Data da Recolha: ${DateFormat('d \'de\' MMMM \'de\' y', 'pt_PT').format(ordersFiltered[index].pickupDate)}\nData de Entrega: ${DateFormat('d \'de\' MMMM \'de\' y', 'pt_PT').format(ordersFiltered[index].deliveryDate)}\nMorada: ${ordersFiltered[index].address}",
                  style: TextStyle(fontSize: 13),
                ),
                isThreeLine: true,
                trailing: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      ordersFiltered[index].state.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ),
      // child: Column(
      //   children: [
      //     Card(
      //       child: ListTile(
      //         title: Text("Pedido #1001"),
      //         subtitle: Text(
      //           "Data da Recolha: 5 de abril de 2025\nData de Entrega: 6 de abril de 2025\nMorada: Rua do Pedido #1001",
      //           style: TextStyle(fontSize: 13),
      //         ),
      //         isThreeLine: true,
      //         trailing: Container(
      //           decoration: BoxDecoration(
      //             color: Theme.of(context).colorScheme.tertiary,
      //             borderRadius: BorderRadius.circular(5),
      //           ),
      //           child: Padding(
      //             padding: const EdgeInsets.symmetric(
      //               horizontal: 8,
      //               vertical: 4,
      //             ),
      //             child: Text(
      //               "Entregue",
      //               style: TextStyle(
      //                 fontSize: 12,
      //                 color: Theme.of(context).colorScheme.primary,
      //                 fontWeight: FontWeight.w700,
      //               ),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
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
                Center(child: getAllFilter(OrderState.Pendente)),
                Center(child: getAllFilter(OrderState.Enviada)),
                Center(child: getAllFilter(OrderState.Entregue)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
