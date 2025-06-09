import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/product_ad_detail_screen.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import '../../core/models/consumer_user.dart';
import '../../core/models/offer.dart';
import '../../core/models/producer_user.dart';
import '../../core/services/auth/auth_notifier.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final producers = AuthService().users.whereType<ProducerUser>().toList();
    final allOffers = (AuthService().currentUser as ConsumerUser).offers;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allOffers!.length,
      itemBuilder: (context, index) {
        final offer = allOffers[index];
        final ad = producers
            .expand(
              (p) =>
                  p
                      .stores[Provider.of<AuthNotifier>(
                        context,
                        listen: false,
                      ).selectedStoreIndex]
                      .productsAds ??
                  [],
            )
            .firstWhere((a) => a.id == offer.productAdId);

        final producer = producers.firstWhere(
          (p) =>
              p
                  .stores[Provider.of<AuthNotifier>(
                    context,
                    listen: false,
                  ).selectedStoreIndex]
                  .productsAds
                  ?.any((prodAd) => prodAd.id == ad.id) ??
              false,
        );

        return Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: Container(
                width: 60,
                height: 120,
                child: Image.asset(offer.discountValue.imagePath),
              ),
              title: Text(
                ad.product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Oferta: ${offer.discountValue.toDisplayString()}'),
                  const SizedBox(height: 4),
                  Text('Produtor: ${producer.firstName} ${producer.lastName}'),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (ctx) => ProductAdDetailScreen(
                            ad: ad,
                            producer: producer,
                            promotion: offer.value,
                          ),
                    ),
                  ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}
