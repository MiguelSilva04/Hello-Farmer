import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:harvestly/components/consumer/map_page.dart';
import 'package:harvestly/components/consumer/product_ad_detail_screen.dart';
import 'package:harvestly/components/create_store.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/producer_user.dart';
import '../../core/models/product_ad.dart';
import '../../core/models/store.dart';
import '../../core/services/auth/auth_notifier.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/other/manage_section_notifier.dart';
import '../../pages/profile_page.dart';

// ignore: must_be_immutable
class StorePage extends StatefulWidget {
  final Store? store;
  const StorePage({super.key, this.store});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  bool showBanca = true;
  Store? myStore;

  void _openManageStoresMenu(
    ProducerUser currentProducerUser,
    List<Store> stores,
  ) {
    String? selectedStoreName =
        stores.any((s) => s.name == myStore?.name) ? myStore?.name : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Gerir Bancas",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedStoreName,
                isExpanded: true,
                iconEnabledColor: Theme.of(context).colorScheme.secondary,
                decoration: InputDecoration(
                  labelText: "Selecionar banca",
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  border: const OutlineInputBorder(),
                ),
                items:
                    stores.map((store) {
                      return DropdownMenuItem(
                        value: store.name,
                        child: Text(store.name!),
                      );
                    }).toList(),
                onChanged: (value) {
                  selectedStoreName = value;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateStore(isFirstTime: false),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Criar Nova Banca"),
              ),
              const SizedBox(height: 8),
              if (stores.length > 1)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    final storeToDelete = stores.firstWhere(
                      (store) => store.name == selectedStoreName,
                      orElse: () => stores.first,
                    );
                    _confirmDeleteStore(storeToDelete);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  label: Text(
                    "Eliminar Banca Selecionada",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
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
                  myStore = null;
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
    final user = Provider.of<AuthNotifier>(context).currentUser;

    if (user == null || !user.isProducer) {
      myStore = widget.store;

      return Scaffold(
        appBar: AppBar(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: const BorderRadius.only(
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

    return StreamBuilder<List<Store>>(
      stream: AuthService().getCurrentUserStoresStream(user.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Erro ao carregar as bancas."));
        }

        final stores = snapshot.data!;
        if (stores.isEmpty) {
          return const Center(child: Text("Nenhuma banca disponível."));
        }

        final selectedIndex =
            Provider.of<AuthNotifier>(context).selectedStoreIndex ?? 0;
        final safeIndex = selectedIndex < stores.length ? selectedIndex : 0;

        myStore = widget.store ?? stores[safeIndex];

        return Scaffold(
          appBar: widget.store != null ? AppBar() : null,
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Column(
            children: [
              if (widget.store == null)
                _buildStoreDropdownUI(context, stores, user as ProducerUser),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: const BorderRadius.only(
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
                child:
                    showBanca ? _buildStoreSection() : _buildReviewsSection(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreDropdownUI(
    BuildContext context,
    List<Store> stores,
    ProducerUser user,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              iconEnabledColor: Theme.of(context).colorScheme.secondary,
              decoration: InputDecoration(
                labelText: "Selecionar banca",
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                border: OutlineInputBorder(),
              ),
              value: myStore!.name,
              items:
                  stores.map((store) {
                    return DropdownMenuItem(
                      value: store.name,
                      child: Text(store.name!),
                    );
                  }).toList(),
              onChanged: (value) async {
                final index = stores.indexWhere((s) => s.name == value);
                if (index != -1) {
                  await Provider.of<AuthNotifier>(
                    context,
                    listen: false,
                  ).saveSelectedStoreIndex(index);
                  setState(() {
                    myStore = stores[index];
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _openManageStoresMenu(user, stores),
            child: const Text("Gerir Bancas"),
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
                        child: Image.network(
                          myStore!.imageUrl!,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            myStore!.name ?? "Sem nome",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (widget.store != null) const SizedBox(height: 8),
                          Text(
                            myStore!.slogan ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                          if (widget.store == null) ...[
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Provider.of<BottomNavigationNotifier>(
                                  context,
                                  listen: false,
                                ).setIndex(4);
                                Provider.of<ManageSectionNotifier>(
                                  context,
                                  listen: false,
                                ).setIndex(1);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              child: Text(
                                "Editar banca",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Text(
                  "Descrição",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  myStore!.description ?? "Sem descrição",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Detalhes",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.place, color: Colors.red, size: 20),
                    SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Municipio: ${myStore!.municipality ?? "Sem Municipio"}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.place, color: Colors.red, size: 20),
                    SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Cidade: ${myStore!.city ?? "Sem Cidade"}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Morada: ${myStore!.address}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapPage(initialStore: myStore),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    "Ver localização",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          if (myStore!.productsAds!.length > 0)
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
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 15,
                          top: 15,
                          bottom: 15,
                        ),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            myStore!.productsAds!.length.toString(),
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
                  ...myStore!.productsAds!
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
    final medianRating = myStore!.averageRating;

    myStore!.storeReviews!.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));

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
            (myStore!.storeReviews != null && myStore!.storeReviews!.isEmpty)
                ? Center(child: Text("Sem comentários"))
                : Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          medianRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 55,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            RatingBarIndicator(
                              rating: medianRating,
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
                              "(${myStore!.storeReviews!.length} avaliações)",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: myStore!.storeReviews!.length,
                      itemBuilder: (ctx, i) {
                        final user =
                            Provider.of<AuthNotifier>(context, listen: false)
                                .allUsers
                                .where(
                                  (u) =>
                                      u.id ==
                                      myStore!.storeReviews![i].reviewerId,
                                )
                                .first;
                        return Column(
                          children: [
                            Container(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onTertiaryContainer,
                              child: Column(
                                children: [
                                  ListTile(
                                    isThreeLine: true,
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          myStore!
                                              .storeReviews![i]
                                              .description!,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    title: InkWell(
                                      onTap:
                                          () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      ProfilePage(user),
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
                                                user.imageUrl,
                                              ),
                                              radius: 10,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                user.firstName +
                                                    " " +
                                                    user.lastName,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            RatingBarIndicator(
                                              rating:
                                                  myStore!
                                                      .storeReviews![i]
                                                      .rating!,
                                              itemBuilder:
                                                  (context, index) => Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.amber.shade700,
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
                                      children: [
                                        Text(
                                          getTimeReviewPosted(
                                            myStore!.storeReviews![i].dateTime!,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (widget.store == null)
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
                                                () => print(
                                                  "Respondido com sucesso!",
                                                ),
                                            child: Text(
                                              "Responder",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.surface,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap:
                                                () => print(
                                                  "Reportado com sucesso!",
                                                ),
                                            child: Text(
                                              "Reportar",
                                              style: TextStyle(
                                                fontSize: 14,
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
                        );
                      },
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  ProducerUser _getProducerFromAd(ProductAd ad) {
    final allProducers =
        Provider.of<AuthNotifier>(
          context,
          listen: false,
        ).allUsers.whereType<ProducerUser>();

    return allProducers.firstWhere(
      (producer) => producer.stores.any(
        (store) => store.productsAds?.any((a) => a.id == ad.id) ?? false,
      ),
    );
  }

  Widget _buildProductsAdsSection(ProductAd productAd) {
    final producer = _getProducerFromAd(productAd);
    void _onEdit(BuildContext context) {
      print('Editar: ${productAd.id}');
    }

    void _onDelete(BuildContext context) {
      Provider.of<BottomNavigationNotifier>(context, listen: false).setIndex(4);
      Provider.of<ManageSectionNotifier>(context, listen: false).setIndex(1);
    }

    return InkWell(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (ctx) =>
                      ProductAdDetailScreen(ad: productAd, producer: producer),
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                productAd.product.imageUrls.first,
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
                    productAd.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "${productAd.price}€/${productAd.product.unit.toDisplayString()}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    productAd.product.category,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    productAd.highlight,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.store == null)
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
      ),
    );
  }
}
