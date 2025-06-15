import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/order_details_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/order.dart';
import '../../core/models/producer_user.dart';
import '../../core/models/product_ad.dart';
import '../../core/services/auth/auth_notifier.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final String? currentUserId;
  late final List<Order> orders;
  late final List<ProductAd> allAds;
  late AuthNotifier authNotifier;
  OrderState? state = null;

  @override
  void initState() {
    super.initState();
    authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final users = authNotifier.allUsers;
    currentUserId = authNotifier.currentUser?.id;

    allAds =
        users
            .whereType<ProducerUser>()
            .where((p) => p.stores.isNotEmpty)
            .expand(
              (p) =>
                  p.stores[authNotifier.selectedStoreIndex].productsAds ?? [],
            )
            .toList()
            .cast<ProductAd>();

    orders =
        users
            .whereType<ProducerUser>()
            .where((p) => p.stores.isNotEmpty && p.stores.isNotEmpty)
            .expand(
              (p) =>
                  p
                      .stores[Provider.of<AuthNotifier>(
                        context,
                        listen: false,
                      ).selectedStoreIndex]
                      .orders ??
                  [],
            )
            .where(
              (order) =>
                  (state == null || order.state == state) &&
                  order.consumerId == currentUserId,
            )
            .fold<Map<String, Order>>({}, (map, order) {
              map[order.id] = order;
              return map;
            })
            .values
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders =
        orders.where((order) => state == null || order.state == state).toList();
    return orders.length == 0
        ? Center(child: Text("Não tem encomendas efetuadas ainda..."))
        : SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => setState(() => state = null),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                state == null
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.inverseSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "Todas",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color:
                                    state != null
                                        ? Theme.of(context).colorScheme.tertiary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.inverseSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () => setState(() => state = OrderState.Pendent),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                state == OrderState.Pendent
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.inverseSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "Pendente",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color:
                                    state != OrderState.Pendent
                                        ? Theme.of(context).colorScheme.tertiary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.inverseSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () => setState(() => state = OrderState.Sent),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                state == OrderState.Sent
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.inverseSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "Enviada",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color:
                                    state != OrderState.Sent
                                        ? Theme.of(context).colorScheme.tertiary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.inverseSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap:
                            () => setState(() => state = OrderState.Delivered),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                state == OrderState.Delivered
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.inverseSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "Entregue",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color:
                                    state != OrderState.Delivered
                                        ? Theme.of(context).colorScheme.tertiary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.inverseSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap:
                            () => setState(() => state = OrderState.Abandonned),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                state == OrderState.Abandonned
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.inverseSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "Abandonada",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color:
                                    state != OrderState.Abandonned
                                        ? Theme.of(context).colorScheme.tertiary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.inverseSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final Order order = filteredOrders[index];
                  final ordersAds =
                      order.ordersItems
                          .map(
                            (ad) => allAds.firstWhere(
                              (a) => a.id == ad.productAdId,
                            ),
                          )
                          .toList()
                          .cast<ProductAd>();

                  return OrderCard(order: order, ads: ordersAds);
                },
              ),
            ],
          ),
        );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final ads;

  const OrderCard({super.key, required this.order, required this.ads});

  @override
  Widget build(BuildContext context) {
    final producer = Provider.of<AuthNotifier>(context, listen: false)
        .producerUsers
        .firstWhere((u) => u.stores.any((store) => store.id == order.storeId));

    final visibleAds = ads.take(3).toList();
    final extraCount = ads.length - visibleAds.length;

    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => OrderDetailsPage(order: order, producer: producer),
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        ...visibleAds.map((ad) {
                          final image =
                              ad.product.imageUrls.isNotEmpty
                                  ? ad.product.imageUrls.first
                                  : null;
                          return Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child:
                                  image != null
                                      ? Image.network(
                                        image,
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      )
                                      : Container(
                                        width: 30,
                                        height: 30,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                            ),
                          );
                        }),
                        if (extraCount > 0)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "+$extraCount",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.delivery_dining,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.state.toDisplayString(),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "${order.totalPrice.toStringAsFixed(2)}€",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.state == OrderState.Sent ||
                          order.state == OrderState.Pendent)
                        Text(
                          "Data prevista de entrega:",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (order.state == OrderState.Abandonned)
                        Text(
                          "Sem entrega",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (order.state != OrderState.Abandonned)
                        Text(
                          DateFormat.yMMMEd('pt_PT').format(order.deliveryDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(),
                            child: Image.network(producer.imageUrl),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${producer.firstName} ${producer.lastName}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (value) {
                      if (value == 'ver') {
                      } else if (value == 'remover') {}
                    },
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'change',
                            child: Text('Mudar endereço de entrega'),
                          ),
                        ],
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Devolução",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.inverseSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Localizar",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color:
                                  Theme.of(context).colorScheme.inverseSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
