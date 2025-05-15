import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:harvestly/core/models/store_review.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:intl/intl.dart';

import '../../core/models/product_ad.dart';
import '../../core/models/store.dart';
import '../../pages/profile_page.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  bool showBanca = true;

  final Store myStore = Store(
    name: "Quinta Sol Nascente",
    subName: "Produzimos com foco na sustentabilidade",
    description:
        "Bem-vindo à Quinta Sol Nascente 🙂 | Produzimos com foco na sustentabilidade e bem-estar | Agricultura regenerativa | Do campo diretamente para a sua mesa, com amor e responsabilidade 🌱",
    location: "Almeirim",
    address: "-8.6235, 39.2081",
    preferredMarkets: [
      "Mercado Biológico de Lisboa",
      "Feira Rural de Torres Vedras",
      "Mercado Eco de Santarém",
    ],
    imageUrl: 'assets/images/mock_images/quinta.jpg',
    productsAds: [
      ProductAd(
        imageUrl: 'assets/images/mock_images/centeio.jpg',
        name: 'Centeio',
        price: '13.5€/Kg',
        category: 'Cereais',
        highlight: 'Este anuncio está destacado há mais de 3 dias!',
      ),
      ProductAd(
        imageUrl: 'assets/images/mock_images/trigo.jpg',
        name: 'Trigo',
        price: '12.5€/Kg',
        category: 'Cereais',
        highlight: 'Este anúncio não está em destaque!',
      ),
    ],
    storeReviews: [
      StoreReview(
        rating: 4.6,
        description: "Excelente produto, adorei o centeio",
        dateTime: DateTime(2025, 5, 3, 14, 50),
        reviewerId: "rmcilPMCHGUDHXA1NmyZKZsWCVE3",
      ),
      StoreReview(
        rating: 4.3,
        description: "Entrega em mãos impecável, correu tudo bem e rápido!",
        dateTime: DateTime(2025, 4, 1, 11, 45),
        reviewerId: "vjjzySrSiIYy1c3QcduZhlKglNh2",
      ),
      StoreReview(
        rating: 4.5,
        description: "Chegou tudo em condições e com ótima qualidade!",
        dateTime: DateTime(2025, 5, 6, 09, 05),
        reviewerId: "YScblT6Hx2RswFie1JKZX5hgn5F2",
      ),
      StoreReview(
        rating: 3.6,
        description:
            "Em excelente condição podia ter sido é um pouco mais rápido...",
        dateTime: DateTime(2025, 2, 26, 19, 13),
        reviewerId: "pxgE59JoVgaDHsxbOijA9VKMfKL2",
      ),
      StoreReview(
        rating: 4.1,
        description: "Entrega no ponto de encontro e produto tudo impecável.",
        dateTime: DateTime(2025, 5, 12, 12, 00),
        reviewerId: "BABXdZ7vwKVFtpIjQQeri4mC71v2",
      ),
      StoreReview(
        rating: 4.9,
        description: "Adorei as cenouras que comprei, é para repetir!!",
        dateTime: DateTime(2025, 5, 12, 12, 08, 01),
        reviewerId: "IyxNeUyr6QNA3lwSALZBHsV75ap2",
      ),
      StoreReview(
        rating: 4.8,
        description: "Comprei beterrabas e eram incriveis, adorei!",
        dateTime: DateTime(2025, 5, 8, 08, 10),
        reviewerId: "pxgE59JoVgaDHsxbOijA9VKMfKL2",
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  _buildTopButton("Banca", showBanca, () {
                    setState(() => showBanca = true);
                  }, isLeft: true),
                  _buildTopButton("Avaliações", !showBanca, () {
                    setState(() => showBanca = false);
                  }, isLeft: false),
                ],
              ),
            ),
          ),
          Expanded(
            child: showBanca ? _buildStoreSection() : _buildReviewsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(
    String text,
    bool isActive,
    VoidCallback onTap, {
    required bool isLeft,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isActive
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.transparent,
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.only(
              topLeft: isLeft ? const Radius.circular(12) : Radius.zero,
              topRight: !isLeft ? const Radius.circular(12) : Radius.zero,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          myStore.imageUrl!,
                          height: 100,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            myStore.name ?? "Sem nome",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(myStore.subName ?? ""),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            child: Text(
                              "Editar banca",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Text(
                  "Descrição",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(myStore.description ?? "Sem descrição"),

                const SizedBox(height: 16),

                const Text(
                  "Detalhes",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.place, color: Colors.red, size: 18),
                    SizedBox(width: 4),
                    Text(
                      "Localização: ${myStore.location ?? "Sem localização"}",
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text("Morada: ${myStore.address}"),
                  ],
                ),

                const SizedBox(height: 16),

                if (myStore.preferredMarkets != null) ...[
                  Text(
                    "Mercados Habituais",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  for (var mercado in myStore.preferredMarkets!)
                    Row(
                      children: [
                        const Text("• "),
                        Expanded(child: Text(mercado)),
                      ],
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          if (myStore.preferredMarkets != null)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, top: 10),
                        child: Text(
                          "Anúncios publicados",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15, top: 10),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            myStore.productsAds!.length.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...myStore.productsAds!
                      .map((prod) => _buildProductsAdsSection(prod))
                      .toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String getTimeReviewPosted(DateTime date) {
    final dateNow = DateTime.now();
    final difference = dateNow.difference(date);

    if (difference.inSeconds < 60) {
      return "há ${difference.inSeconds} segundos";
    } else if (difference.inMinutes < 60) {
      return "há ${difference.inMinutes} minutos";
    } else if (difference.inHours < 24) {
      return "há ${difference.inHours} horas";
    } else {
      return DateFormat('dd/MM/y', 'pt_PT').format(date);
    }
  }

  Widget _buildReviewsSection() {
    final users = AuthService().users.where(
      (u) => myStore.storeReviews!.any((review) => review.reviewerId == u.id),
    );
    final medianRating =
        myStore.storeReviews!.fold(0.0, (sum, review) => sum + review.rating!) /
        myStore.storeReviews!.length;

    myStore.storeReviews!.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  medianRating.toStringAsFixed(1),
                  style: TextStyle(fontSize: 55, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    RatingBarIndicator(
                      rating: medianRating,
                      itemBuilder:
                          (context, index) =>
                              Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 24.0,
                      direction: Axis.horizontal,
                    ),
                    Text(
                      "(${myStore.storeReviews!.length} avaliações)",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: myStore.storeReviews!.length,
              itemBuilder:
                  (ctx, i) => Column(
                    children: [
                      Container(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                        child: Column(
                          children: [
                            ListTile(
                              isThreeLine: true,
                              subtitle: Column(
                                children: [
                                  Text(
                                    myStore.storeReviews![i].description!,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              title: InkWell(
                                onTap:
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ProfilePage(
                                              users
                                                  .where(
                                                    (el) =>
                                                        el.id ==
                                                        myStore
                                                            .storeReviews![i]
                                                            .reviewerId,
                                                  )
                                                  .first,
                                            ),
                                      ),
                                    ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.tertiary,
                                        backgroundImage: NetworkImage(
                                          users
                                              .where(
                                                (el) =>
                                                    el.id ==
                                                    myStore
                                                        .storeReviews![i]
                                                        .reviewerId,
                                              )
                                              .first
                                              .imageUrl,
                                        ),
                                        radius: 10,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          users
                                                  .where(
                                                    (el) =>
                                                        el.id ==
                                                        myStore
                                                            .storeReviews![i]
                                                            .reviewerId,
                                                  )
                                                  .first
                                                  .firstName +
                                              " " +
                                              users
                                                  .where(
                                                    (el) =>
                                                        el.id ==
                                                        myStore
                                                            .storeReviews![i]
                                                            .reviewerId,
                                                  )
                                                  .first
                                                  .lastName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      RatingBarIndicator(
                                        rating:
                                            myStore.storeReviews![i].rating!,
                                        itemBuilder:
                                            (context, index) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                        itemCount: 5,
                                        itemSize: 18,
                                        direction: Axis.horizontal,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    getTimeReviewPosted(
                                      myStore.storeReviews![i].dateTime!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 12,
                                left: 12,
                                right: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap:
                                        () => print("Respondido com sucesso!"),
                                    child: Text(
                                      "Responder",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap:
                                        () => print("Reportado com sucesso!"),
                                    child: Text(
                                      "Reportar",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 5,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsAdsSection(ProductAd productAd) {
    void _onEdit(BuildContext context) {
      print('Editar: ${productAd.id}');
    }

    void _onDelete(BuildContext context) {
      print('Apagar: ${productAd.id}');
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              productAd.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productAd.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(productAd.price),
                Text(productAd.category),
                Text(
                  productAd.highlight,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => _onEdit(context),
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () => _onDelete(context),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
