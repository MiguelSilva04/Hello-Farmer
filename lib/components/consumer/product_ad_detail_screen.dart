import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:harvestly/components/producer/store_page.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/store.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/pages/profile_page.dart';
import 'package:harvestly/utils/keywords.dart';

// ignore: must_be_immutable
class ProductAdDetailScreen extends StatelessWidget {
  final ProductAd ad;
  int? promotion;

  ProductAdDetailScreen({Key? key, this.promotion, required this.ad})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deliveryMethods = [
      {
        'method': DeliveryMethod.HOME_DELIVERY.toDisplayString(),
        'icon': Icons.home,
        'type': DeliveryMethod.HOME_DELIVERY,
      },
      {
        'method': DeliveryMethod.COURIER.toDisplayString(),
        'icon': Icons.local_shipping,
        'type': DeliveryMethod.COURIER,
      },
      {
        'method': DeliveryMethod.PICKUP.toDisplayString(),
        'icon': Icons.storefront,
        'type': DeliveryMethod.PICKUP,
      },
    ];
    final producer = AuthService().users.whereType<ProducerUser>().firstWhere(
      (p) => p.store.productsAds?.any((a) => a.id == ad.id) ?? false,
    );
    final store = producer.store;

    final keywordMap = {for (var k in Keywords.keywords) k.name: k.icon};

    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageCarousel(imageUrls: ad.product.imageUrl),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                ad.product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child:
                  promotion != null
                      ? Row(
                        children: [
                          Text(
                            "${ad.product.price.toStringAsFixed(2)} €",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${(ad.product.price * (1 - promotion! / 100)).toStringAsFixed(2)} €/${ad.product.unit.toDisplayString()}",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      )
                      : Text(
                        "${ad.product.price.toStringAsFixed(2)} €/${ad.product.unit.toDisplayString()}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
            ),

            const SizedBox(height: 16),
            if (ad.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  ad.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 16),
            if (ad.keywords != null && ad.keywords!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8.0,
                  children:
                      ad.keywords!.map((k) {
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
                    children:
                        ad.preferredDeliveryMethods.map((method) {
                          return Chip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  store.deliveryIcon(method),
                                  size: 16,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  method.toDisplayString().split('.').last,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  InkWell(
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => ProfilePage(producer),
                          ),
                        ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            producer.imageUrl,
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text("${producer.firstName} ${producer.lastName}"),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => StorePage(store: store),
                          ),
                        ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                store.imageUrl!,
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
                                  "${store.name}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        RatingBarIndicator(
                                          rating: store.averageRating,
                                          itemBuilder:
                                              (context, index) => Icon(
                                                Icons.star,
                                                color: Colors.amber.shade700,
                                              ),
                                          itemCount: 5,
                                          itemSize: 24.0,
                                          direction: Axis.horizontal,
                                        ),
                                        Text(
                                          "(${store.averageRating.toStringAsFixed(1)}) ",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondaryFixed,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "📍${store.city ?? ''}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondaryFixed,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.message_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {},
                      icon: Icon(
                        Icons.shopping_cart,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      label: const Text("Adicionar ao Carrinho"),
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

class ProductImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ProductImageCarousel({super.key, required this.imageUrls});

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.imageUrls;

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.55,
          child: PageView.builder(
            controller: _pageController,
            itemCount: imageUrls.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final imageUrl = imageUrls[index];
              final isNetwork = imageUrl.startsWith('http');

              return isNetwork
                  ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                  : Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(imageUrls.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 12 : 8,
              height: isActive ? 12 : 8,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}
