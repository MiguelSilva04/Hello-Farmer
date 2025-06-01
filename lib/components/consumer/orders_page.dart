import 'package:flutter/material.dart';
import '../../core/models/order.dart';
import '../../core/models/producer_user.dart';
import '../../core/models/product_ad.dart';
import '../../core/services/auth/auth_service.dart';
import 'details_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().currentUser?.id;

    final orders =
        AuthService().users
            .whereType<ProducerUser>()
            .expand((producer) => producer.store.orders ?? [])
            .where((order) => order.consumerId == currentUserId)
            .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(order: order);
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final producer =
        AuthService().users.where((u) => u.id == order.producerId).first;
    final ads =
        AuthService().users
            .whereType<ProducerUser>()
            .expand((producer) => producer.store.productsAds ?? [])
            .where(
              (productAd) => order.productsAds.contains(
                (u) => u.produtctAdId == productAd.id,
              ),
            )
            .toList();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(12),
            //   child: Image.asset(
            //     ads.first.product.imageUrl.first,
            //     width: 70,
            //     height: 70,
            //     fit: BoxFit.cover,
            //   ),
            // ),
            const SizedBox(width: 16),

            // Info principal
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
                  Text(
                    'Produtor: ${producer.firstName} ${producer.lastName}',
                    style: const TextStyle(fontSize: 14),
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
                        order.deliveryDate?.toIso8601String() ?? "Sem entrega",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
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
                      const Spacer(),
                      Text(
                        order.totalPrice.toString(),
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
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(198, 220, 211, 1),
                foregroundColor: const Color.fromRGBO(59, 126, 98, 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
              child: const Text('Ver'),
            ),
          ],
        ),
      ),
    );
  }
}
