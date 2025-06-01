import 'package:flutter/material.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';

import '../../core/models/consumer_user.dart';
import '../../core/models/offer.dart';
import '../../core/models/producer_user.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final producers = AuthService().users.whereType<ProducerUser>().toList();
    final allOffers = (AuthService().currentUser as ConsumerUser).offers;
    // for (final producer in producers) {
    //   if (producer.store.productsAds != null) {
    //     for (final ad in producer.store.productsAds!) {
    //       for (final user in AuthService().users) {
    //         if (user is ConsumerUser && user.offers != null) {
    //           for (final offer in user.offers!) {
    //             if (offer.productAdId == ad.id) {
    //               allOffers.add(offer);
    //             }
    //           }
    //         }
    //       }
    //     }
    //   }
    // }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allOffers!.length,
      itemBuilder: (context, index) {
        final offer = allOffers[index];
        final ad = producers
            .expand((p) => p.store.productsAds ?? [])
            .firstWhere((a) => a.id == offer.productAdId);

        final producer = producers.firstWhere(
          (p) =>
              p.store.productsAds?.any((prodAd) => prodAd.id == ad.id) ?? false,
        );

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: Container(
              width: 60,
              height: 120,
              child: Image.asset(offer.discountValue.imagePath),
            ),
            title: Text(
              ad.product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            onTap: () {
              // Ação ao clicar na oferta (opcional)
            },
          ),
        );
      },
    );
  }
}
