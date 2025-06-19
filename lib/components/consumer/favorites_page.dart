import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/product_ad_detail_screen.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/utils/keywords.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../core/services/auth/auth_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Set<String> selectedKeywords = {};

  void applyFilter(Set<String> selectedKeywords) {
    setState(() {
      this.selectedKeywords.clear();
      this.selectedKeywords.addAll(selectedKeywords);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);

    final selectedIndex = authNotifier.selectedStoreIndex;

    List<ProductAd> allAds = [];
    if (selectedIndex != null) {
      allAds = AuthService()
          .users
          .whereType<ProducerUser>()
          .expand((producer) {
            if (producer.stores.isNotEmpty && selectedIndex < producer.stores.length) {
              return producer.stores[selectedIndex].productsAds ?? [];
            }
            return <ProductAd>[];
          })
          .toList(growable: false).cast<ProductAd>();
    }

    final favoriteAds = allAds.where((ad) => authNotifier.favorites.contains(ad.id)).toList();

    final displayedFavorites = selectedKeywords.isEmpty
        ? favoriteAds
        : favoriteAds.where((ad) => ad.keywords?.any(selectedKeywords.contains) ?? false).toList();

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
              children: Keywords.keywords.map((keywordIcon) {
                final isSelected = selectedKeywords.contains(keywordIcon.name);
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
                      final newSelected = Set<String>.from(selectedKeywords);
                      if (selected) {
                        newSelected.add(keywordIcon.name);
                      } else {
                        newSelected.remove(keywordIcon.name);
                      }
                      applyFilter(newSelected);
                    },
                    selectedColor: Theme.of(context).colorScheme.secondaryFixed,
                    checkmarkColor: Theme.of(context).colorScheme.secondary,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: displayedFavorites.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: displayedFavorites.length,
                    itemBuilder: (context, index) {
                      final ad = displayedFavorites[index];

                      final producer = AuthService().users
                          .whereType<ProducerUser>()
                          .firstWhereOrNull((u) =>
                              u
                                  .stores[selectedIndex ?? 0]
                                  .productsAds
                                  ?.any((a) => a.id == ad.id) ??
                              false);

                      if (producer == null) return const SizedBox.shrink();

                      return Column(
                        children: [
                          ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => ProductAdDetailScreen(
                                  ad: ad,
                                  producer: producer,
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
                                    ad.product.imageUrls.first,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: -6,
                                  left: -6,
                                  child: GestureDetector(
                                    onTap: () => authNotifier.toggleFavorite(ad.id),
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
                                        authNotifier.isFavorite(ad.id)
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
                                Text('${producer.firstName} ${producer.lastName}'),
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
