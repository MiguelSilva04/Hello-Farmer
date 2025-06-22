import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/product_ad_detail_screen.dart';
import 'package:harvestly/components/countryCitySelector.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:harvestly/utils/categories.dart';
import 'package:harvestly/utils/keywords.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../core/services/auth/auth_notifier.dart';

class ExplorePage extends StatefulWidget {
  ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String _searchText = '';
  late String _categoryText;
  String? _selectedKeyword;
  String _selectedCity = AuthService().currentUser!.city ?? "";
  TextEditingController searchEditingController = TextEditingController();
  double _minPrice = 0;
  double _maxPrice = 30;
  String _sortOption = 'name_asc';

  final ScrollController _scrollController = ScrollController();

  List<String> selectedKeywords = [];
  List<ProductAd> allFavorites = [];
  List<ProductAd> displayedAds = [];
  Map<String, int> _categoryCounts = {};

  late AuthNotifier authNotifier;
  late BottomNavigationNotifier bottomNotifier;

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

  void applyFilters() {
    final currentSeason = calculateCurrentSeason();
    authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    final selectedCityLower = _selectedCity.trim().toLowerCase();

    final filteredProducers =
        authNotifier.producerUsers.where((producer) {
          return _selectedCity.trim().isEmpty ||
              producer.stores.any((store) {
                final storeCity = store.city?.trim().toLowerCase() ?? '';
                return storeCity == selectedCityLower;
              });
        }).toList();

    final allAds =
        filteredProducers
            .expand((producer) => producer.stores)
            .where((store) => store.productsAds?.isNotEmpty ?? false)
            .expand((store) => store.productsAds!)
            .toList();

    final Map<String, int> categoryCounts = {};

    final stores = authNotifier.producerUsers.expand((p) => p.stores).toList();

    for (final c in Categories.categories) {
      categoryCounts[c.name] =
          allAds.where((ad) {
            final store = stores.firstWhereOrNull(
              (s) => (s.productsAds ?? []).any(
                (productAd) => productAd.id == ad.id,
              ),
            );

            if (store == null) return false;

            final isSameCategory = ad.product.category == c.name;
            final isSameCity = store.city == _selectedCity;

            final price = ad.product.price;
            final isWithinPriceRange = price >= _minPrice && price <= _maxPrice;

            return isSameCategory && isSameCity && isWithinPriceRange;
          }).length;
    }

    final List<ProductAd> matching = [];
    final List<ProductAd> others = [];

    for (final ad in allAds) {
      final product = ad.product;

      final nameMatch =
          _searchText.trim().length >= 1 &&
          product.name.toLowerCase().contains(_searchText.toLowerCase());

      final categoryMatch =
          _searchText.trim().length >= 2 &&
          product.category.toLowerCase().contains(_searchText.toLowerCase());

      final isCurrentSeason =
          _searchText == "Season" &&
          (product.season == currentSeason || product.season == Season.ALL);

      final keywordMatch =
          _selectedKeyword == null ||
          (ad.keywords
                  ?.map((k) => k.toLowerCase())
                  .contains(_selectedKeyword!.toLowerCase()) ??
              false);

      final priceMatch =
          product.price >= _minPrice && product.price <= _maxPrice;

      final matchesAllFilters = keywordMatch && priceMatch;

      if (nameMatch && matchesAllFilters) {
        matching.add(ad);
      } else if ((categoryMatch || isCurrentSeason) && matchesAllFilters) {
        others.add(ad);
      }
    }

    final filtered = [...matching, ...others];

    final refinedFiltered =
        _selectedCity.isNotEmpty
            ? filtered.where((ad) {
              for (final user in authNotifier.allUsers) {
                if (user is ProducerUser) {
                  for (final store in user.stores) {
                    final matches =
                        store.productsAds?.any((a) => a.id == ad.id) ?? false;
                    final storeCity = store.city?.trim().toLowerCase() ?? '';
                    if (matches &&
                        (selectedCityLower.isEmpty ||
                            storeCity == selectedCityLower)) {
                      return true;
                    }
                  }
                }
              }
              return false;
            }).toList()
            : filtered;

    sortProducts(refinedFiltered);

    setState(() {
      displayedAds = refinedFiltered;
      _categoryCounts = categoryCounts;
    });
  }

  void sortProducts(List<ProductAd> filtered) {
    filtered.sort((a, b) {
      switch (_sortOption) {
        case 'name_asc':
          return a.product.name.compareTo(b.product.name);
        case 'name_desc':
          return b.product.name.compareTo(a.product.name);
        case 'price_asc':
          return a.product.price.compareTo(b.product.price);
        case 'price_desc':
          return b.product.price.compareTo(a.product.price);
        default:
          return 0;
      }
    });
  }

  ProducerUser? findProducerOfAd(ProductAd ad, List<ProducerUser> producers) {
    for (final producer in producers) {
      for (final store in producer.stores) {
        if (store.productsAds?.any((a) => a.id == ad.id) ?? false) {
          return producer;
        }
      }
    }
    return null;
  }

  Widget _buildSearchResults(List<ProductAd> ads) {
    if (ads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 32.0),
        child: Center(child: Text('Nenhum produto encontrado.')),
      );
    }

    final Map<String, List<ProductAd>> groupedAds = {};
    for (final ad in ads) {
      final category = ad.product.category;
      groupedAds.putIfAbsent(category, () => []).add(ad);
    }

    final sortedCategories = groupedAds.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          sortedCategories.map((category) {
            final categoryAds = groupedAds[category]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...categoryAds.map((ad) {
                  final product = ad.product;
                  final producer = findProducerOfAd(
                    ad,
                    authNotifier.producerUsers,
                  );

                  final keywordMap = {
                    for (var k in Keywords.keywords) k.name: k.icon,
                  };
                  return GestureDetector(
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
                    child: Column(
                      children: [
                        if (producer != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.imageUrls.first,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        const Divider(),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    bottomNotifier = Provider.of<BottomNavigationNotifier>(
      context,
      listen: false,
    );
    applyFilters();
    if (bottomNotifier.selectedCategory != null) {
      _searchText = bottomNotifier.selectedCategory!;
      _categoryText = bottomNotifier.selectedCategory!;
      applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBar(
            controller: searchEditingController,
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
              applyFilters();
              _scrollController.jumpTo(0);
            },
          ),
          const SizedBox(height: 16),

          CategoryTabs(
            selectedKeyword: _selectedKeyword,
            onKeywordSelected: (value) {
              setState(() {
                _selectedKeyword = value;
              });
              applyFilters();
              _scrollController.jumpTo(0);
            },
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        '${_categoryText}${_categoryText.isNotEmpty ? " em " : "Em "}$_selectedCity...',
                        style: TextStyle(
                          fontSize: _categoryText.isNotEmpty ? 16 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (isAvailableToClear())
                      GestureDetector(
                        onTap: () {
                          clearFilters();
                        },
                        child: Text(
                          "Limpar",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  double tempMinPrice = _minPrice;
                  double tempMaxPrice = _maxPrice;
                  String tempSortOption = _sortOption;
                  String tempCitySelected = _selectedCity;

                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    isScrollControlled: true,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Filtrar por Preço de Unidade',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                RangeSlider(
                                  min: 0,
                                  max: 30,
                                  divisions: 30,
                                  values: RangeValues(
                                    tempMinPrice,
                                    tempMaxPrice,
                                  ),
                                  onChanged: (range) {
                                    setModalState(() {
                                      tempMinPrice = range.start;
                                      tempMaxPrice = range.end;
                                    });
                                  },
                                  labels: RangeLabels(
                                    '${tempMinPrice.toStringAsFixed(2)}€',
                                    '${tempMaxPrice.toStringAsFixed(2)}€',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        const Text(
                                          'Ordenar por',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        DropdownButton<String>(
                                          dropdownColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                          ),
                                          value: tempSortOption,
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'name_asc',
                                              child: Text('Nome (A-Z)'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'name_desc',
                                              child: Text('Nome (Z-A)'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'price_asc',
                                              child: Text(
                                                'Preço (Mais barato)',
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'price_desc',
                                              child: Text('Preço (Mais caro)'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              setModalState(() {
                                                tempSortOption = value;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    Flexible(
                                      child: TextButton.icon(
                                        icon: Icon(
                                          Icons.location_on,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                        ),
                                        label: Text(
                                          tempCitySelected.isEmpty
                                              ? 'Selecionar Cidade'
                                              : tempCitySelected,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Container(
                                                  constraints: BoxConstraints(
                                                    maxHeight:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.height *
                                                        0.6,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        child: CountryCitySelector(
                                                          onCitySelected: (
                                                            city,
                                                          ) {
                                                            setModalState(() {
                                                              tempCitySelected =
                                                                  city;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setModalState(() {
                                          tempCitySelected = "";
                                        });
                                        setState(() {
                                          _selectedCity =
                                              AuthService().currentUser!.city ??
                                              "";
                                          tempCitySelected =
                                              AuthService().currentUser!.city ??
                                              "";
                                          applyFilters();
                                        });
                                      },
                                      icon: Icon(
                                        Icons.clear,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _minPrice = tempMinPrice;
                                      _maxPrice = tempMaxPrice;
                                      _sortOption = tempSortOption;
                                      _selectedCity = tempCitySelected;
                                      applyFilters();
                                    });
                                  },
                                  child: const Text('Aplicar Filtros'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Text(
                  'Filtrar',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (_searchText.isEmpty) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchText = "Season";
                  _categoryText = "Season";
                  applyFilters();
                });
              },
              child: _buildSeasonalCard(),
            ),
            const SizedBox(height: 16),
            ...Categories.categories.map((c) {
              final count = _categoryCounts[c.name] ?? 0;
              return GestureDetector(
                onTap: () {
                  bottomNotifier.setCategory(c.name);
                  setState(() {
                    _searchText = c.name;
                    _categoryText = c.name;
                    applyFilters();
                  });
                  _scrollController.jumpTo(0);
                },
                child: _buildCategory(
                  c.name,
                  '$count Produto${count != 1 ? 's' : ''} na sua região',
                  c.icon,
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 16),
            _buildSearchResults(displayedAds),
          ],
        ],
      ),
    );
  }

  bool isAvailableToClear() {
    return _searchText != "" ||
        _categoryText != '' ||
        _selectedKeyword != null ||
        searchEditingController.text != "" ||
        _searchText != "";
  }

  Season calculateCurrentSeason() {
    final now = DateTime.now();
    final month = now.month;

    if (month >= 3 && month <= 5) {
      return Season.SPRING; // Março, Abril, Maio
    } else if (month >= 6 && month <= 8) {
      return Season.SUMMER; // Junho, Julho, Agosto
    } else if (month >= 9 && month <= 11) {
      return Season.AUTUMN; // Setembro, Outubro, Novembro
    } else {
      return Season.WINTER; // Dezembro, Janeiro, Fevereiro
    }
  }

  void clearFilters() {
    searchEditingController.clear();
    bottomNotifier.setCategory('');
    setState(() {
      _searchText = "";
      _categoryText = '';
      _selectedKeyword = null;
      searchEditingController;
    });
  }
}

class CategoryTabs extends StatefulWidget {
  final String? selectedKeyword;
  final Function(String?) onKeywordSelected;

  const CategoryTabs({
    super.key,
    required this.selectedKeyword,
    required this.onKeywordSelected,
  });

  @override
  _CategoryTabsState createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  final List<String> keywords = Keywords.keywords.map((k) => k.name).toList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              keywords.map((keyword) {
                final bool isSelected = keyword == widget.selectedKeyword;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      keyword,
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
                      widget.onKeywordSelected(isSelected ? null : keyword);
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
