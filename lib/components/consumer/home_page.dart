import 'dart:async';

import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/product_ad_detail_screen.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:harvestly/pages/profile_page.dart';
import 'package:harvestly/utils/categories.dart';
import 'package:provider/provider.dart';
import '../../core/models/producer_user.dart';

class ConsumerHomePage extends StatefulWidget {
  const ConsumerHomePage({super.key});

  @override
  State<ConsumerHomePage> createState() => _ConsumerHomePageState();
}

class _ConsumerHomePageState extends State<ConsumerHomePage> {
  late String userName;
  late List<ProductAd> recommendedAds;
  late List<ProducerUser> nearbyProducers;
  late final ScrollController _scrollController;
  late final List<String> promoImages;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser!;
    userName = user.firstName;
    final producer =
        (AuthService().users.where((u) => u.runtimeType == ProducerUser)).first
            as ProducerUser;
    recommendedAds =
        producer
            .stores[Provider.of<AuthNotifier>(
              context,
              listen: false,
            ).selectedStoreIndex]
            .productsAds
            ?.take(5)
            .toList() ??
        [];
    nearbyProducers =
        AuthService().users.whereType<ProducerUser>().take(5).toList();

    promoImages = [
      'assets/images/discounts_images/75%PT.png',
      'assets/images/discounts_images/50%PT.png',
      'assets/images/discounts_images/25%PT.png',
      'assets/images/discounts_images/10%PT.png',
      'assets/images/discounts_images/5%PT.png',
    ];

    _scrollController = ScrollController();

    _scrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final current = _scrollController.offset;
        double next = current + 130;

        if (next >= maxScroll) next = 0;

        _scrollController.animateTo(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Olá, $userName!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Text(
              'Descobre os melhores produtos frescos na tua zona!',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),

          _buildPromotionsBanner(),
          const SizedBox(height: 16),
          _buildCategories(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Text(
              'Recomendados para ti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendedAds.length,
              itemBuilder: (context, index) {
                final ad = recommendedAds[index];
                return _buildProductItem(ad);
              },
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Text(
              'Produtores perto de ti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: nearbyProducers.length,
              itemBuilder: (context, index) {
                return _buildProducerItem(nearbyProducers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildPromotionsBanner() {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: promoImages.length,
            padding: const EdgeInsets.only(bottom: 30),
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(promoImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              color: Colors.black.withValues(alpha: 0.5),
              child: const Text(
                'Promoções até 75% em todas a fruta da tua zona!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories =
        Categories.categories.map((c) => c.name).take(5).toList();
    final icons = Categories.categories.map((c) => c.icon).take(5).toList();

    return SizedBox(
      height: 100,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(categories.length, (index) {
              return InkWell(
                onTap:
                    () => Provider.of<BottomNavigationNotifier>(
                      context,
                      listen: false,
                    ).setIndex(2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.green[100],
                        child: Icon(icons[index], color: Colors.green[800]),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        categories[index],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(ProductAd ad) {
    final product = ad.product;
    return InkWell(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => ProductAdDetailScreen(ad: ad)),
          ),
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage(product.imageUrl.first),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProducerItem(ProducerUser user) {
    return InkWell(
      onTap:
          () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => ProfilePage(user))),
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(user.imageUrl),
            ),
            const SizedBox(height: 6),
            Text(
              '${user.firstName} ${user.lastName}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              user
                      .stores[Provider.of<AuthNotifier>(
                        context,
                        listen: false,
                      ).selectedStoreIndex]
                      .city ??
                  'Cidade desconhecida',
              style: const TextStyle(fontSize: 10),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user.rating.toString(), style: TextStyle(fontSize: 10)),
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text(
                  '(${user.stores[Provider.of<AuthNotifier>(context, listen: false).selectedStoreIndex].storeReviews?.length ?? 0})',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
