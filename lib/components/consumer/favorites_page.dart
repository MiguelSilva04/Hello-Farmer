import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/product_ad_detail_screen.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/utils/keywords.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<ProductAd> allAds = [];
  final Set<String> selectedKeywords = {};
  bool isLoading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadAllAds();
      _initialized = true;
    }
  }

  Future<void> _loadAllAds() async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final ads = await authNotifier.fetchAllProductAdsOnce();

    setState(() {
      allAds = ads;
      isLoading = false;
    });
  }

  void applyFilter(Set<String> selectedKeywords) {
    setState(() {
      this.selectedKeywords.clear();
      this.selectedKeywords.addAll(selectedKeywords);
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
                          final newSelected = Set<String>.from(
                            selectedKeywords,
                          );
                          if (selected) {
                            newSelected.add(keywordIcon.name);
                          } else {
                            newSelected.remove(keywordIcon.name);
                          }
                          applyFilter(newSelected);
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
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Consumer<AuthNotifier>(
                      builder: (context, authNotifier, _) {
                        final favoriteAds =
                            allAds
                                .where(
                                  (ad) =>
                                      authNotifier.favorites.contains(ad.id),
                                )
                                .toList();

                        final displayedFavorites =
                            selectedKeywords.isEmpty
                                ? favoriteAds
                                : favoriteAds
                                    .where(
                                      (ad) =>
                                          ad.keywords?.any(
                                            selectedKeywords.contains,
                                          ) ??
                                          false,
                                    )
                                    .toList();

                        if (displayedFavorites.isEmpty) {
                          return const Center(
                            child: Text(
                              "Sem produtos adicionados aos favoritos!",
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: displayedFavorites.length,
                          itemBuilder: (context, index) {
                            final ad = displayedFavorites[index];

                            ProducerUser? producer;
                            int? storeIndex;

                            for (var p
                                in authNotifier.allUsers
                                    .whereType<ProducerUser>()) {
                              for (var i = 0; i < p.stores.length; i++) {
                                final contains =
                                    p.stores[i].productsAds?.any(
                                      (a) => a.id == ad.id,
                                    ) ??
                                    false;

                                if (contains) {
                                  producer = p;
                                  storeIndex = i;
                                  break;
                                }
                              }
                              if (producer != null) break;
                            }

                            if (producer == null)
                              return const SizedBox.shrink();

                            final keywordMap = {
                              for (var k in Keywords.keywords) k.name: k.icon,
                            };

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
                                        child: Image.network(
                                          ad.product.imageUrls.first,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    size: 70,
                                                  ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -6,
                                        left: -6,
                                        child: GestureDetector(
                                          onTap:
                                              () => authNotifier.toggleFavorite(
                                                ad.id,
                                              ),
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
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ad.product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (ad.keywords != null)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          height: 36,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children:
                                                  ad.keywords!
                                                      .map(
                                                        (k) => Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                right: 6,
                                                              ),
                                                          child: Chip(
                                                            avatar: Icon(
                                                              keywordMap[k],
                                                              size: 16,
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .secondary,
                                                            ),
                                                            label: Text(
                                                              k,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .secondary,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          producer
                                                  .stores[storeIndex!]
                                                  .imageUrl ??
                                              producer.imageUrl,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.store,
                                                    size: 30,
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        producer.stores[storeIndex].name ??
                                            'Loja sem nome',
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                              ],
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
