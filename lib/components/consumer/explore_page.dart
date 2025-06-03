import 'package:flutter/material.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/utils/categories.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ExplorePage extends StatefulWidget {
  ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String _searchText = '';
  Widget _buildSeasonalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8B3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_grocery_store,
            size: 40,
            color: Color(0xFFD34F1A),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Morango, Maçã e mais\nProdutos da estação',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8D2B00),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF8D2B00)),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD8F1E5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF2A815E)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Color(0xFF2A815E)),
        ],
      ),
    );
  }

  List<ProductAd> getFilteredAds(String query) {
    return AuthService().users
        .whereType<ProducerUser>()
        .expand((producer) => producer.store.productsAds ?? [])
        .where((ad) {
          final nameMatch = ad.product.name.toLowerCase().contains(
            query.toLowerCase(),
          );
          final categoryMatch = ad.product.category.toLowerCase().contains(
            query.toLowerCase(),
          );
          return nameMatch || categoryMatch;
        })
        .cast<ProductAd>()
        .toList();
  }

  Widget _buildSearchResults(List<ProductAd> ads) {
    if (ads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 32.0),
        child: Center(child: Text('Nenhum produto encontrado.')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ads.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final ad = ads[index];
        final product = ad.product;
        final producer =
            AuthService().users
                .whereType<ProducerUser>()
                .where((p) => p.store.productsAds?.contains(ad) ?? false)
                .first;
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      product.imageUrl.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${product.price.toStringAsFixed(2)} €/${product.unit.toDisplayString()}",
                        ),
                        Text(
                          product.category,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          producer.imageUrl,
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        "${producer.firstName} ${producer.lastName}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ProductAd> searchResults =
        _searchText.isNotEmpty ? getFilteredAds(_searchText) : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBar(
            elevation: WidgetStateProperty.all(1),
            backgroundColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ),
            hintStyle: WidgetStateProperty.all(
              TextStyle(
                color: Theme.of(context).colorScheme.inverseSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            textStyle: WidgetStateProperty.all(
              TextStyle(
                color: Theme.of(context).colorScheme.inverseSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            hintText: "Procurar produtos ou categorias",
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
          ),
          const SizedBox(height: 16),

          if (_searchText.isEmpty) ...[
            CategoryTabs(),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Em Setúbal...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Filtrar',
                  style: TextStyle(
                    color: Color(0xFF2A815E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSeasonalCard(),
            const SizedBox(height: 16),
            ...Categories.categories.map((c) {
              final count =
                  AuthService().users
                      .whereType<ProducerUser>()
                      .expand((p) => p.store.productsAds ?? [])
                      .where((ad) => ad.product.category == c.name)
                      .length;

              return _buildCategory(
                c.name,
                '$count Produto${count != 1 ? 's' : ''} na sua região',
                c.icon,
              );
            }),
          ] else ...[
            const SizedBox(height: 16),
            _buildSearchResults(searchResults),
          ],
        ],
      ),
    );
  }
}

class CategoryTabs extends StatefulWidget {
  @override
  _CategoryTabsState createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  final List<String> categories = [
    'Biológicos',
    'Convencionais',
    'Novidades',
    'Locais',
    'A granel',
    'Sem glúten',
    'Sem lactose',
    'Promoções',
  ];

  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              categories.map((category) {
                final bool isSelected = category == selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.tertiaryFixed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.grey.shade200,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = isSelected ? null : category;
                      });
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
