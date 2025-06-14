import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/order.dart';
import '../../../core/models/producer_user.dart';
import '../../../core/services/auth/auth_notifier.dart';
import '../../../core/services/auth/auth_service.dart';

class AbandonedOrdersPage extends StatelessWidget {
  const AbandonedOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentStore =
        (AuthService().currentUser! as ProducerUser)
            .stores[Provider.of<AuthNotifier>(
          context,
          listen: false,
        ).selectedStoreIndex];
    final orders = currentStore.orders ?? [];

    final abandonedOrders =
        orders
            .where(
              (o) =>
                  o.state == OrderState.Abandonned &&
                  (Provider.of<AuthNotifier>(context, listen: false).currentUser
                          as ProducerUser)
                      .stores
                      .any((store) => store.id == o.storeId),
            )
            .toList();

    final users = AuthService().users;

    String getUserName(String id) {
      final user = users.firstWhere((u) => u.id == id);
      return "${user.firstName} ${user.lastName}";
    }

    Widget _buildAbandonedCard(Order order, String consumidor) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Theme.of(context).colorScheme.outline,
        elevation: 1.5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 25,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consumidor,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Última tentativa:\n${DateFormat.yMMMd().format(order.deliveryDate)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade200,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.chat, size: 20),
                        label: const Text(
                          "Contactar",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade200,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Enviar lembrete",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Text(
                "Produtos Abandonados:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final products = order.ordersItems;
                        final productCount = products.length;

                        double imageSize;
                        int maxVisible = 4;

                        if (productCount == 1) {
                          imageSize = 55;
                        } else if (productCount == 2) {
                          imageSize = 55;
                        } else if (productCount == 3) {
                          imageSize = 50;
                        } else {
                          imageSize = 40;
                        }

                        if (productCount <= maxVisible) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  products.map((p) {
                                    final productAd =
                                        currentStore.productsAds!
                                            .where(
                                              (pr) => pr.id == p.productAdId,
                                            )
                                            .first;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            productAd.product.name,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            height: imageSize,
                                            width: imageSize,
                                            child: Image.asset(
                                              productAd.product.imageUrls.first,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),
                          );
                        } else {
                          return SizedBox(
                            height: imageSize + 24,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: productCount,
                                    itemBuilder: (context, index) {
                                      final p = products[index];
                                      final productAd =
                                          currentStore.productsAds!
                                              .where(
                                                (pr) => pr.id == p.productAdId,
                                              )
                                              .first;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              productAd.product.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Container(
                                              height: imageSize,
                                              width: imageSize,
                                              child: Image.asset(
                                                productAd
                                                    .product
                                                    .imageUrls
                                                    .first,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  // const Spacer(),
                  Text(
                    "${order.totalPrice.toStringAsFixed(2)} €",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return abandonedOrders.isEmpty
        ? Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Boa! Não há qualquer encomenda que tenha sido abandonada!😁",
              textAlign: TextAlign.center,
            ),
          ),
        )
        : Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Estas encomendas foram iniciadas mas não finalizadas.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ...abandonedOrders.map((order) {
                  final consumidor = getUserName(order.consumerId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAbandonedCard(order, consumidor),
                  );
                }),
              ],
            ),
          ),
        );
  }
}
