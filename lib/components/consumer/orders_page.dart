import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/order_details_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../../core/models/order.dart';
import '../../core/models/producer_user.dart';
import '../../core/models/product_ad.dart';
import '../../core/services/auth/auth_notifier.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  OrderState? _selectedState;
  late final AuthNotifier _authNotifier;

  @override
  void initState() {
    super.initState();
    _authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedState = null;
            break;
          case 1:
            _selectedState = OrderState.Pending;
            break;
          case 2:
            _selectedState = OrderState.Sent;
            break;
          case 3:
            _selectedState = OrderState.Ready;
            break;
          case 4:
            _selectedState = OrderState.Delivered;
            break;
          case 5:
            _selectedState = OrderState.Abandoned;
            break;
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ProductAd> _getAllAds() {
    return _authNotifier.allUsers
        .whereType<ProducerUser>()
        .expand(
          (producer) =>
              producer.stores.expand((store) => store.productsAds ?? []),
        )
        .whereType<ProductAd>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductAd>>(
      future: Future(() => _getAllAds()),
      builder: (context, adsSnapshot) {
        if (!adsSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allAds = adsSnapshot.data!;

        return StreamBuilder<List<Order>>(
          stream: _authNotifier.consumerOrdersStream(
            _authNotifier.currentUser!.id,
          ),
          builder: (context, ordersSnapshot) {
            if (ordersSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = ordersSnapshot.data ?? [];

            if (orders.isEmpty) {
              return const Center(
                child: Text("Não tem encomendas efetuadas ainda..."),
              );
            }

            final filteredOrders =
                orders
                    .where(
                      (order) =>
                          _selectedState == null ||
                          order.state == _selectedState,
                    )
                    .toList();

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildTabBar(context),
                  _buildOrdersList(filteredOrders, allAds),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: TabBar(
          isScrollable: true,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.tertiaryFixed,
          unselectedLabelColor: Theme.of(context).colorScheme.secondaryFixed,
          indicatorColor: Theme.of(context).colorScheme.tertiaryFixed,
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

  Widget _buildOrdersList(List<Order> orders, List<ProductAd> allAds) {
    final sortedOrders = List<Order>.from(orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: sortedOrders.length,
      itemBuilder: (context, index) {
        final order = sortedOrders[index];
        final ordersAds = order.ordersItems
            .map(
              (orderItem) => allAds.firstWhereOrNull(
                (ad) => ad.id == orderItem.productAdId,
              ),
            )
            .toList();

        return OrderCard(order: order, ads: ordersAds);
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final List<ProductAd?> ads;
  const OrderCard({super.key, required this.order, required this.ads});
  @override
  Widget build(BuildContext context) {
    final producer = Provider.of<AuthNotifier>(
      context,
      listen: false,
    ).producerUsers.firstWhereOrNull(
      (u) => u.stores.any((store) => store.id == order.storeId),
    );

    if (producer == null) {
      return const SizedBox.shrink();
    }

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
                          if (ad == null) {
                            return Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.hide_image, size: 18),
                            );
                          }

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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
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
                          order.state == OrderState.Pending)
                        Text(
                          "Data prevista de entrega:",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (order.state == OrderState.Abandoned)
                        Text(
                          "Sem entrega",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (order.state != OrderState.Abandoned)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Entregue a:",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              DateFormat.yMMMEd(
                                'pt_PT',
                              ).format(order.deliveryDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
