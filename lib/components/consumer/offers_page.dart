import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/product_ad_detail_screen.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import '../../core/models/offer.dart';
import '../../core/services/auth/auth_notifier.dart';

enum OfferSortOption { expiryAsc, expiryDesc, discountAsc, discountDesc }

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final producers = authNotifier.producerUsers;

    // State for filter
    final ValueNotifier<OfferSortOption> sortOption = ValueNotifier(
      OfferSortOption.expiryAsc,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Stack(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C9C7B), Color(0xFF297F5D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "As Tuas Promoções",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ValueListenableBuilder<OfferSortOption>(
                  valueListenable: sortOption,
                  builder:
                      (context, value, _) => IconButton(
                        onPressed: () async {
                          final selected = await showModalBottomSheet<
                            OfferSortOption
                          >(
                            context: context,
                            builder: (context) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.calendar_today),
                                      title: Text(
                                        'Data de validade (Crescente)',
                                      ),
                                      selected:
                                          value == OfferSortOption.expiryAsc,
                                      onTap:
                                          () => Navigator.pop(
                                            context,
                                            OfferSortOption.expiryAsc,
                                          ),
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.calendar_today_outlined,
                                      ),
                                      title: Text(
                                        'Data de validade (Decrescente)',
                                      ),
                                      selected:
                                          value == OfferSortOption.expiryDesc,
                                      onTap:
                                          () => Navigator.pop(
                                            context,
                                            OfferSortOption.expiryDesc,
                                          ),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.percent),
                                      title: Text(
                                        'Valor do desconto (Crescente)',
                                      ),
                                      selected:
                                          value == OfferSortOption.discountAsc,
                                      onTap:
                                          () => Navigator.pop(
                                            context,
                                            OfferSortOption.discountAsc,
                                          ),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.percent_outlined),
                                      title: Text(
                                        'Valor do desconto (Decrescente)',
                                      ),
                                      selected:
                                          value == OfferSortOption.discountDesc,
                                      onTap:
                                          () => Navigator.pop(
                                            context,
                                            OfferSortOption.discountDesc,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                          if (selected != null) {
                            sortOption.value = selected;
                          }
                        },
                        icon: Icon(
                          Icons.filter_alt_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: ValueListenableBuilder<OfferSortOption>(
              valueListenable: sortOption,
              builder: (context, currentSort, _) {
                return StreamBuilder<List<Offer>>(
                  stream: AuthService().getUserOffersStream(
                    AuthService().currentUser!.id,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Sem promoções ativas."));
                    }

                    List<Offer> allOffers = List.from(snapshot.data!);

                    switch (currentSort) {
                      case OfferSortOption.expiryAsc:
                        allOffers.sort(
                          (a, b) => a.endDate.compareTo(b.endDate),
                        );
                        break;
                      case OfferSortOption.expiryDesc:
                        allOffers.sort(
                          (a, b) => b.endDate.compareTo(a.endDate),
                        );
                        break;
                      case OfferSortOption.discountAsc:
                        allOffers.sort(
                          (a, b) => a.discountValue.toValue().compareTo(
                            b.discountValue.toValue(),
                          ),
                        );
                        break;
                      case OfferSortOption.discountDesc:
                        allOffers.sort(
                          (a, b) => b.discountValue.toValue().compareTo(
                            a.discountValue.toValue(),
                          ),
                        );
                        break;
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: allOffers.length,
                      itemBuilder: (context, index) {
                        final offer = allOffers[index];
                        final ad = producers
                            .expand((p) => p.stores)
                            .expand((store) => store.productsAds ?? [])
                            .firstWhere((a) => a.id == offer.productAdId);
                        final producer = producers.firstWhere(
                          (p) => p.stores.any(
                            (store) => (store.productsAds ?? []).any(
                              (prodAd) => prodAd.id == ad.id,
                            ),
                          ),
                        );

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                offer.discountValue.imagePath,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              ad.product.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Promoção: ${offer.discountValue.toDisplayString()}',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'De: ${producer.firstName} ${producer.lastName}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (ctx) => ProductAdDetailScreen(
                                        ad: ad,
                                        producer: producer,
                                        promotion: offer.value,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
