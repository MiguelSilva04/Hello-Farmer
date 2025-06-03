// order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:harvestly/core/models/order.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/store.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;
  final ProducerUser producer;

  const OrderDetailsPage({
    super.key,
    required this.order,
    required this.producer,
  });

  @override
  Widget build(BuildContext context) {
    final date =
        order.deliveryDate != null
            ? DateFormat.yMMMEd('pt_PT').format(order.deliveryDate!)
            : null;
    final products = order.productsAds;
    final deliveryMethod =
        (AuthService().users
                    .whereType<ProducerUser>()
                    .expand((p) => p.store.productsAds ?? [])
                    .firstWhere(
                      (ad) => ad.id == products.first.produtctAdId,
                      orElse:
                          () => throw Exception("ProductAd não encontrado."),
                    )
                as ProductAd)
            .preferredDeliveryMethods
            .first;
    return Scaffold(
      appBar: AppBar(title: const Text("Encomenda")),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 25),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (date != null) ...[
                          Text(
                            "Data da encomenda: ",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (date == null) ...[
                          Text(
                            "Abandonada desde: ",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            DateFormat.yMMMd('pt_PT').format(order.pickupDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 5),
                Row(
                  children: [
                    const Icon(Icons.inventory, size: 25),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Encomenda Nº ",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "${order.id}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home, size: 25),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Morada de entrega: ", style: TextStyle(fontSize: 16)),
                    Text(
                      order.address,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Remetente",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        producer.store.imageUrl != null
                            ? AssetImage(producer.store.imageUrl!)
                            : null,
                    child:
                        producer.store.imageUrl == null
                            ? const Icon(Icons.store, size: 30)
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producer.store.name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (producer.store.location != null)
                          Row(
                            children: [
                              Icon(Icons.pin_drop_rounded),
                              Text(
                                producer.store.location!,
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondaryFixed,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () {},
                    tooltip: "Contactar produtor",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("Estado: ", style: const TextStyle(fontSize: 16)),
                Text(
                  order.state.toDisplayString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("Valor: ", style: const TextStyle(fontSize: 16)),
                Text(
                  "${order.totalPrice.toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: "Entrega: ",
                style: TextStyle(fontSize: 16),
                children: [
                  TextSpan(
                    text: deliveryMethod.toDisplayString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              "Produtos Encomendados",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            /// Lista de produtos
            Expanded(
              child: ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = products[index];
                  final ad =
                      AuthService().users
                              .whereType<ProducerUser>()
                              .expand((p) => p.store.productsAds ?? [])
                              .firstWhere(
                                (ad) => ad.id == item.produtctAdId,
                                orElse:
                                    () =>
                                        throw Exception(
                                          "ProductAd não encontrado.",
                                        ),
                              )
                          as ProductAd;

                  final product = ad.product;
                  final quantityText =
                      product.unit == Unit.KG
                          ? "${item.qty}${product.unit.toDisplayString()}"
                          : "x${item.qty.toStringAsFixed(0)}";

                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            product.imageUrl.first,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$quantityText ${product.name}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${product.price.toStringAsFixed(2)}€/${product.unit.toDisplayString()}",
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondaryFixed,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      // lógica de repetir compra
                                    },
                                    icon: const Icon(
                                      Icons.shopping_cart_checkout,
                                    ),
                                    label: const Text("Comprar novamente"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Para mais detalhes sobre a entrega, contacta o vendedor.",
              style: TextStyle(fontSize: 12),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // lógica de ver fatura
                },
                child: const Text("Ver fatura"),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
