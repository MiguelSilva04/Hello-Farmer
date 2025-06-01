import 'package:flutter/material.dart';
import '../../core/models/order.dart';
import '../../core/models/producer_user.dart';
import '../../core/models/product_ad.dart';
import '../../core/services/auth/auth_service.dart';
import 'details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final String? currentUserId;
  late final List<Order> orders;
  late final List<ProductAd> allAds;

  @override
  void initState() {
    super.initState();
    final users = AuthService().users;
    currentUserId = AuthService().currentUser?.id;

    allAds =
        users
            .whereType<ProducerUser>()
            .expand((p) => p.store.productsAds ?? [])
            .cast<ProductAd>()
            .toList();

    orders =
        users
            .whereType<ProducerUser>()
            .expand((producer) => producer.store.orders ?? [])
            .where((order) => order.consumerId == currentUserId)
            .cast<Order>()
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final Order order = orders[index];
        final ordersAds =
            order.productsAds
                .map((ad) => allAds.firstWhere((a) => a.id == ad.produtctAdId))
                .toList()
                .cast<ProductAd>();

        return OrderCard(order: order, ads: ordersAds);
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final ads;

  const OrderCard({super.key, required this.order, required this.ads});

  @override
  Widget build(BuildContext context) {
    final producer = AuthService().users.firstWhere(
      (u) => u.id == order.producerId,
    );

    final visibleAds = ads.take(3).toList();
    final extraCount = ads.length - visibleAds.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    ...visibleAds.map((ad) {
                      final image =
                          ad.product.imageUrl.isNotEmpty
                              ? ad.product.imageUrl.first
                              : null;
                      return Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child:
                              image != null
                                  ? Image.asset(
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
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "+$extraCount",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
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
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "${order.totalPrice}€",
                      style: const TextStyle(
                        fontSize: 16,
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
                  Text(
                    'Encomenda #${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        child: Image.network(producer.imageUrl),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${producer.firstName} ${producer.lastName}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.deliveryDate != null
                            ? "${order.deliveryDate!.day}/${order.deliveryDate!.month}/${order.deliveryDate!.year}"
                            : "Sem entrega",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                // backgroundColor: const Color.fromRGBO(198, 220, 211, 1),
                // foregroundColor: const Color.fromRGBO(59, 126, 98, 1),
                // padding: const EdgeInsets.symmetric(
                //   horizontal: 10,
                //   vertical: 6,
                // ),
                textStyle: const TextStyle(fontSize: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => OrderDetailsPage(
                          order: order,
                          ads: ads,
                          producer: producer,
                        ),
                  ),
                );
              },
              child: const Text('Detalhes'),
            ),
          ],
        ),
      ),
    );
  }
}
