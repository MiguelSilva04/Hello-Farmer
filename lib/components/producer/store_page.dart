import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:harvestly/components/consumer/product_ad_detail_screen.dart';
import 'package:harvestly/components/create_store.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/models/store.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/review.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/pages/loading_page.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../core/models/app_user.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/other/bottom_navigation_notifier.dart';
import '../../core/services/other/manage_section_notifier.dart';
import '../consumer/map_page.dart';

class StorePage extends StatefulWidget {
  final Store? store;

  StorePage({super.key, this.store});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Store? selectedStore;
  bool showDropdown = false;

  @override
  void initState() {
    super.initState();
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    if (widget.store != null) {
      selectedStore = widget.store;
    } else {
      selectedStore =
          (authNotifier.currentUser as ProducerUser).stores[authNotifier
              .selectedStoreIndex!];
    }
  }

  void _confirmDeleteStore(Store store) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar Banca"),
          content: Text("Tens a certeza que queres eliminar '${store.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await Provider.of<AuthNotifier>(
                  context,
                  listen: false,
                ).removeStore(store.id);

                await Provider.of<AuthNotifier>(
                  context,
                  listen: false,
                ).saveSelectedStoreIndex(0);

                setState(() {
                  selectedStore = null;
                });

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                "Eliminar",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    if (!(authNotifier.currentUser?.isProducer ?? false)) {
      return _buildStoreScaffold(context, authNotifier, selectedStore, null);
    }

    return StreamBuilder<List<Store>>(
      stream:
          authNotifier.currentUser != null
              ? AuthService().getCurrentUserStoresStream(
                authNotifier.currentUser!.id,
              )
              : null,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingPage();
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Erro ao carregar as bancas."));
        }

        final stores = snapshot.data!;
        if (stores.isEmpty) {
          return const Center(child: Text("Nenhuma banca disponível."));
        }

        final selectedIndex = authNotifier.selectedStoreIndex ?? 0;
        final safeIndex = selectedIndex < stores.length ? selectedIndex : 0;

        final isOwnStore =
            widget.store != null &&
            widget.store!.ownerId == authNotifier.currentUser!.id;

        final storeToShow =
            isOwnStore
                ? stores[safeIndex]
                : (widget.store ?? stores[safeIndex]);

        return _buildStoreScaffold(context, authNotifier, storeToShow, stores);
      },
    );
  }

  Widget _buildStoreScaffold(
    BuildContext context,
    AuthNotifier authNotifier,
    Store? store,
    List<Store>? stores,
  ) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(13),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38),
                blurRadius: 10,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            tooltip: 'Voltar',
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 260,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                          ),
                          child:
                              store?.backgroundImageUrl != null &&
                                      store!.backgroundImageUrl!.isNotEmpty
                                  ? Image.network(
                                    store.backgroundImageUrl!,
                                    width: double.infinity,
                                    height: 220,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Container(
                                          color: Colors.grey.shade300,
                                        ),
                                  )
                                  : null,
                        ),
                        Positioned(
                          left: 20,
                          top: 180,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      (store?.imageUrl != null &&
                                              store!.imageUrl!.isNotEmpty)
                                          ? NetworkImage(store.imageUrl!)
                                          : null,
                                  backgroundColor: Colors.white,
                                  child:
                                      (store?.imageUrl == null ||
                                              store!.imageUrl!.isEmpty)
                                          ? Icon(
                                            Icons.store,
                                            size: 40,
                                            color: Colors.grey,
                                          )
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Builder(
                                builder: (context) {
                                  final rating = store!.averageRating;
                                  return Row(
                                    children: [
                                      RatingBarIndicator(
                                        rating: rating,
                                        itemBuilder:
                                            (context, index) => const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                        itemCount: 5,
                                        itemSize: 28,
                                        unratedColor: Colors.white,
                                        direction: Axis.horizontal,
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Text(
                                          rating.toStringAsFixed(2),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (authNotifier.currentUser!.isProducer)
                    TextButton(
                      onPressed: () {
                        Provider.of<BottomNavigationNotifier>(
                          context,
                          listen: false,
                        ).setIndex(4);
                        Provider.of<ManageSectionNotifier>(
                          context,
                          listen: false,
                        ).setIndex(1);
                        Navigator.of(context).pop();
                      },
                      child: Text("Editar banca"),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (authNotifier.currentUser!.isProducer &&
                                stores != null &&
                                stores.length > 1)
                              Expanded(
                                child: DropdownButtonFormField<Store>(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 40,
                                  ),
                                  value: store,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge?.copyWith(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items:
                                      stores
                                          .map(
                                            (s) => DropdownMenuItem<Store>(
                                              value: s,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      s.name ?? 'Nome da Banca',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  if (s != store)
                                                    IconButton(
                                                      onPressed: () {
                                                        final storeToDelete =
                                                            stores.firstWhere(
                                                              (ss) =>
                                                                  ss.name ==
                                                                  s.name,
                                                              orElse:
                                                                  () =>
                                                                      stores
                                                                          .first,
                                                            );
                                                        _confirmDeleteStore(
                                                          storeToDelete,
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (s) {
                                    if (s != null) {
                                      setState(() {
                                        selectedStore = s;
                                        showDropdown = false;
                                      });
                                      final index = stores.indexOf(s);
                                      Provider.of<AuthNotifier>(
                                        context,
                                        listen: false,
                                      ).saveSelectedStoreIndex(index);
                                    }
                                  },
                                  dropdownColor:
                                      Theme.of(context).colorScheme.secondary,
                                  autofocus: true,
                                  selectedItemBuilder:
                                      (context) =>
                                          stores
                                              .map(
                                                (s) => Text(
                                                  s.name ?? 'Nome da Banca',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineLarge
                                                      ?.copyWith(
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              )
                                              .toList(),
                                ),
                              )
                            else
                              Expanded(
                                child: Text(
                                  store?.name ?? 'Nome da Banca',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge?.copyWith(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (store?.slogan != null)
                          Text(
                            "'${store?.slogan}'",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 15),
                        Text(
                          store?.description ?? 'Descrição da banca...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            ActionChip(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              labelPadding: EdgeInsets.zero,
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.pin_drop,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    store?.city ?? "Cidade",
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => MapPage(initialStore: store),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Anúncios publicados",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${store?.productsAds?.length ?? 0}",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 170,
                          child: Builder(
                            builder: (context) {
                              final isProducer =
                                  authNotifier.currentUser?.isProducer ?? false;
                              List<ProductAd> ads = store?.productsAds ?? [];

                              if (!isProducer) {
                                ads =
                                    ads
                                        .where((ad) => ad.visibility == true)
                                        .toList();
                              }

                              ads.sort((a, b) {
                                final aDate = a.createdAt;
                                final bDate = b.createdAt;
                                return bDate.compareTo(aDate);
                              });

                              if (ads.isEmpty) {
                                return Center(
                                  child: Text(
                                    "Sem anúncios publicados",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                );
                              }

                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: ads.length,
                                itemBuilder: (ctx, index) {
                                  final ad = ads[index];
                                  return _ProductCard(ad: ad);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Avaliações",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${store?.storeReviews?.length ?? 0}",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if ((store?.storeReviews?.isEmpty ?? true))
                          Text("Ainda sem comentários"),
                        ...((store?.storeReviews ?? [])
                            .where(
                              (review) => (review.replyTo?.isEmpty ?? true),
                            )
                            .take(3)
                            .map((review) {
                              final reply = (store?.storeReviews ?? [])
                                  .firstWhereOrNull(
                                    (r) =>
                                        (r.replyTo?.isNotEmpty ?? false) &&
                                        r.replyTo == review.reviewerId,
                                  );
                              AppUser? reviewer;
                              if (reply != null)
                                reviewer =
                                    Provider.of<AuthNotifier>(
                                          context,
                                          listen: false,
                                        ).allUsers
                                        .where((u) => u.id == reply.reviewerId)
                                        .first;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ReviewCard(review: review),
                                  if (reply != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 32.0,
                                        top: 4.0,
                                      ),
                                      child: Card(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withValues(alpha: 0.8),
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                          reviewer!.imageUrl,
                                                        ),
                                                    radius: 20,
                                                    backgroundColor:
                                                        Colors.grey.shade200,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      reviewer.firstName +
                                                          " " +
                                                          reviewer.lastName,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                      ),
                                                    ),
                                                  ),
                                                  // Tempo do comentário alinhado à direita
                                                  Builder(
                                                    builder: (context) {
                                                      final now =
                                                          DateTime.now();
                                                      final createdAt =
                                                          reply.dateTime;
                                                      final diff = now
                                                          .difference(
                                                            createdAt!,
                                                          );

                                                      String timeText;
                                                      if (diff.inSeconds < 60) {
                                                        timeText =
                                                            "${diff.inSeconds}s atrás";
                                                      } else if (diff
                                                              .inMinutes <
                                                          60) {
                                                        timeText =
                                                            "${diff.inMinutes}m atrás";
                                                      } else if (diff.inHours <
                                                              24 &&
                                                          now.day ==
                                                              createdAt.day) {
                                                        timeText =
                                                            "${diff.inHours}h atrás";
                                                      } else if (now
                                                              .difference(
                                                                DateTime(
                                                                  createdAt
                                                                      .year,
                                                                  createdAt
                                                                      .month,
                                                                  createdAt.day,
                                                                ),
                                                              )
                                                              .inDays ==
                                                          1) {
                                                        timeText = "Ontem";
                                                      } else {
                                                        timeText =
                                                            "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}";
                                                      }
                                                      return Text(
                                                        timeText,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color:
                                                                  Colors
                                                                      .grey[700],
                                                            ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                reply.description ?? "",
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            })),
                        if ((store?.storeReviews?.length ?? 0) > 3)
                          TextButton(
                            onPressed: () {},
                            child: const Text("Ver todos os comentários"),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          authNotifier.currentUser!.isProducer
              ? FloatingActionButton.extended(
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => CreateStore(isFirstTime: false),
                      ),
                    ),
                label: Text(
                  "Nova Banca",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )
              : null,
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductAd ad;

  const _ProductCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    final producer = Provider.of<AuthNotifier>(
      context,
      listen: false,
    ).producerUsers.firstWhere(
      (producer) => producer.stores.any(
        (store) => store.productsAds?.any((a) => a.id == ad.id) ?? false,
      ),
      orElse: () => throw Exception('Producer not found for this ad'),
    );
    return InkWell(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (ctx) => ProductAdDetailScreen(ad: ad, producer: producer),
            ),
          ),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border:
                        ad.highlightType != null
                            ? Border.all(color: Colors.amber.shade700, width: 5)
                            : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      ad.product.imageUrls.firstOrNull ?? '',
                      height: 100,
                      width: 140,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            height: 100,
                            width: 140,
                            color: Colors.grey.shade300,
                          ),
                    ),
                  ),
                ),
                if (ad.highlightType != null)
                  Positioned(
                    top: -5,
                    left: 0,
                    child: Chip(
                      backgroundColor: Colors.amber.shade700,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            ad.highlightType! == HighlightType.HOME
                                ? "Pagina Principal"
                                : "Pesquisa",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 0,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              ad.product.name,
              style: Theme.of(context).textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "${ad.price}€/${ad.product.unit.toDisplayString()}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final reviewer =
        Provider.of<AuthNotifier>(
          context,
          listen: false,
        ).allUsers.where((u) => u.id == review.reviewerId).first;
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(reviewer.imageUrl),
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(reviewer.firstName + " " + reviewer.lastName),
                ),
                const SizedBox(width: 4),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text("${review.rating?.toStringAsFixed(1) ?? ""}"),
                      ],
                    ),
                    Builder(
                      builder: (context) {
                        final now = DateTime.now();
                        final createdAt = review.dateTime;
                        final diff = now.difference(createdAt!);

                        String timeText;
                        if (diff.inSeconds < 60) {
                          timeText = "${diff.inSeconds}s atrás";
                        } else if (diff.inMinutes < 60) {
                          timeText = "${diff.inMinutes}m atrás";
                        } else if (diff.inHours < 24 &&
                            now.day == createdAt.day) {
                          timeText = "${diff.inHours}h atrás";
                        } else if (now
                                .difference(
                                  DateTime(
                                    createdAt.year,
                                    createdAt.month,
                                    createdAt.day,
                                  ),
                                )
                                .inDays ==
                            1) {
                          timeText = "Ontem";
                        } else {
                          timeText =
                              "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}";
                        }
                        return Text(
                          timeText,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[700]),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              review.description ?? "",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
