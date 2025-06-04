import 'package:flutter/material.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/utils/keywords.dart';

class ProductAdDetailScreen extends StatelessWidget {
  final ProductAd ad;

  const ProductAdDetailScreen({Key? key, required this.ad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final producer = AuthService().users
        .whereType<ProducerUser>()
        .firstWhere((p) => p.store.productsAds?.contains(ad) ?? false);

    final keywordMap = {
      for (var k in Keywords.keywords) k.name: k.icon,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(ad.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: ad.product.imageUrl.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    ad.product.imageUrl[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                ad.product.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "${ad.product.price.toStringAsFixed(2)} €/${ad.product.unit.toDisplayString()}",
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            // Descrição
            if (ad.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  ad.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 16),
            // Palavras-chave
            if (ad.keywords != null && ad.keywords!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8.0,
                  children: ad.keywords!.map((k) {
                    return Chip(
                      avatar: Icon(
                        keywordMap[k],
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      label: Text(
                        k,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),
            // Métodos de entrega preferidos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Métodos de Entrega Preferidos:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: ad.preferredDeliveryMethods.map((method) {
                      return Chip(
                        label: Text(method.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Informações do produtor
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      producer.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${producer.firstName} ${producer.lastName}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        producer.store.city ?? '',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Botões de ação
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Lógica para adicionar ao carrinho
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text("Adicionar ao Carrinho"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Lógica para contactar a banca do produtor
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text("Contactar Banca"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
