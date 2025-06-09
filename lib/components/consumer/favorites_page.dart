import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/product_ad_detail_screen.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/utils/keywords.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../core/models/consumer_user.dart';
import '../../core/services/auth/auth_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<ProductAd> allFavorites = [];
  List<ProductAd> displayedFavorites = [];

  final Set<String> selectedKeywords = {};

  List<String> get favoritesProductsIds {
    final consumer = AuthService().currentUser as ConsumerUser;
    return consumer.favouritesProductsIds ?? [];
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() {
    final favoritesIds = favoritesProductsIds;

    final allAds = AuthService().users.whereType<ProducerUser>().expand(
      (producer) =>
          producer
              .stores[Provider.of<AuthNotifier>(
                context,
                listen: false,
              ).selectedStoreIndex]
              .productsAds ??
          [],
    );

    final uniqueFavorites = {
      for (var ad in allAds)
        if (favoritesIds.contains(ad.id)) ad.id: ad,
    };

    setState(() {
      allFavorites = uniqueFavorites.values.toList().cast<ProductAd>();
      displayedFavorites = List.from(allFavorites);
    });
  }

  void applyFilters() {
    setState(() {
      if (selectedKeywords.isEmpty) {
        displayedFavorites = List.from(allFavorites);
      } else {
        displayedFavorites =
            allFavorites.where((ad) {
              return ad.keywords?.any((k) => selectedKeywords.contains(k)) ??
                  false;
            }).toList();
      }
    });
  }

  void toggleFavorite(ProductAd ad) {
    final consumer = AuthService().currentUser as ConsumerUser;
    final favorites = consumer.favouritesProductsIds ?? [];

    setState(() {
      if (favorites.contains(ad.id)) {
        favorites.remove(ad.id);
      } else {
        favorites.add(ad.id);
      }
      consumer.favouritesProductsIds = favorites;

      loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children:
                  Keywords.keywords.map((keywordIcon) {
                    final isSelected = selectedKeywords.contains(
                      keywordIcon.name,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              keywordIcon.icon,
                              size: 18,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              keywordIcon.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedKeywords.add(keywordIcon.name);
                            } else {
                              selectedKeywords.remove(keywordIcon.name);
                            }
                            applyFilters();
                          });
                        },
                        selectedColor:
                            Theme.of(context).colorScheme.secondaryFixed,
                        checkmarkColor: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child:
                displayedFavorites.isNotEmpty
                    ? ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: displayedFavorites.length,
                      itemBuilder: (context, index) {
                        final ad = displayedFavorites[index];

                        ProducerUser? producer;
                        try {
                          producer = AuthService().users
                              .whereType<ProducerUser>()
                              .firstWhereOrNull(
                                (u) =>
                                    u
                                        .stores[Provider.of<AuthNotifier>(
                                          context,
                                          listen: false,
                                        ).selectedStoreIndex]
                                        .productsAds
                                        ?.any((a) => a.id == ad.id) ??
                                    false,
                              );
                        } catch (_) {
                          producer = null;
                        }

                        if (producer == null) return const SizedBox.shrink();

                        return Column(
                          children: [
                            ListTile(
                              onTap:
                                  () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (ctx) => ProductAdDetailScreen(
                                            ad: ad,
                                            producer: producer!,
                                          ),
                                    ),
                                  ),
                              contentPadding: const EdgeInsets.all(12),
                              leading: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      ad.product.imageUrl.first,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: -6,
                                    left: -6,
                                    child: GestureDetector(
                                      onTap: () => toggleFavorite(ad),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          favoritesProductsIds.contains(ad.id)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                ad.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      producer.imageUrl,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${producer.firstName} ${producer.lastName}',
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                                onPressed: () {},
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    )
                    : const Center(
                      child: Text("Sem produtos adicionados aos favoritos!"),
                    ),
          ),
        ],
      ),
    );
  }
}
