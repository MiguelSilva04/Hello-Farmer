import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:harvestly/components/producer/store_page.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/store.dart';
import 'package:harvestly/core/services/auth/notification_notifier.dart';
import 'package:harvestly/pages/profile_page.dart';
import 'package:harvestly/utils/keywords.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../core/models/offer.dart';
import '../../core/models/review.dart';
import '../../core/services/auth/auth_notifier.dart';
import '../../core/services/chat/chat_list_notifier.dart';
import '../sendMessageButton.dart';

class ProductAdDetailScreen extends StatefulWidget {
  final ProductAd ad;
  final ProducerUser producer;
  final Offer? promotion;

  ProductAdDetailScreen({
    Key? key,
    this.promotion,
    required this.ad,
    required this.producer,
  }) : super(key: key);

  @override
  State<ProductAdDetailScreen> createState() => _ProductAdDetailScreenState();
}

class _ProductAdDetailScreenState extends State<ProductAdDetailScreen> {
  double _rating = 0;
  bool _isLoading = false;
  final reviewController = TextEditingController();
  bool hasReviewed = false;
  late AuthNotifier authNotifier;
  late NotificationNotifier notificationNotifier;
  late Store curStore;
  late List<Review> reviews;
  String? replyToUserId;
  bool _isFavorite = false;
  bool? userHasOrderedThisProduct;

  double get rating {
    final repliedReviews = reviews.where((r) => r.replyTo != null).toList();

    if (repliedReviews.isEmpty) return 0.0;

    final total = repliedReviews.fold<double>(
      0.0,
      (sum, review) => sum + review.rating!,
    );

    return total / repliedReviews.length;
  }

  void getStoreAd() {
    for (var user in authNotifier.producerUsers) {
      for (var store in user.stores) {
        if (store.productsAds?.any((ad) => ad.id == widget.ad.id) ?? false) {
          curStore = store;
        }
      }
    }
    setState(() {
      reviews = widget.ad.adReviews ?? [];
    });
  }

  void setReviews(List<Review> newReviews) {
    setState(() => reviews = newReviews);
  }

  Future<void> checkIfUserReviewed() async {
    final userId = authNotifier.currentUser?.id;

    if (userId != null) {
      setState(() {
        hasReviewed = reviews.any((review) {
          return review.reviewerId == userId;
        });
      });
    }
  }

  Future<void> loadUserHasOrdered() async {
    final userId = authNotifier.currentUser?.id;
    if (userId != null && !authNotifier.currentUser!.isProducer) {
      final hasOrdered = await authNotifier.checkIfUserAlreadyOrdered(
        userId,
        widget.ad.id,
      );
      setState(() {
        userHasOrderedThisProduct = hasOrdered;
      });
    } else {
      setState(() {
        userHasOrderedThisProduct = false;
      });
    }
  }

  Future<void> addToCart(double quantity) async {
    await Provider.of<AuthNotifier>(
      context,
      listen: false,
    ).addToCart(widget.ad, quantity, widget.promotion?.value ?? 0).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto adicionado ao carrinho!')),
      );
    });
  }

  bool verifyIfAlreadyExistsConversation(
    String currentUserId,
    String otherUserId,
  ) {
    final chatList =
        Provider.of<ChatListNotifier>(context, listen: false).chats;

    return chatList.any(
      (chat) =>
          (chat.consumerId == currentUserId &&
              chat.producerId == otherUserId) ||
          (chat.producerId == currentUserId && chat.consumerId == otherUserId),
    );
  }

  @override
  void initState() {
    super.initState();
    authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    notificationNotifier = Provider.of<NotificationNotifier>(
      context,
      listen: false,
    );
    final store = authNotifier.producerUsers
        .expand((producer) => producer.stores)
        .firstWhereOrNull(
          (store) =>
              store.productsAds?.any((ad) => ad.id == widget.ad.id) ?? false,
        );
    reviews = widget.ad.adReviews ?? [];
    getStoreAd();
    checkIfUserReviewed();
    loadUserHasOrdered();
    if (widget.producer.id != authNotifier.currentUser!.id) {
      try {
        authNotifier.addAdVisit(store!.id, widget.ad.id);
      } catch (e) {
        print("Ocorreu um erro em processar a visita à banca!");
      }
    }

    if (!authNotifier.currentUser!.isProducer) {
      _isFavorite = authNotifier.isFavorite(widget.ad.id);
    }
  }

  Future<void> toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        await authNotifier.addFavorite(widget.ad.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Produto adicionado aos favoritos!")),
        );
      } else {
        await authNotifier.removeFavorite(widget.ad.id);
      }
    } catch (e) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao atualizar favorito")));
    }
  }

  Future<void> updateStoreRating() async {
    print("Nova rating: ${_rating}");
    final allAds = curStore.productsAds ?? [];
    List<Review> allReviews = [];
    for (var ad in allAds) {
      if (ad.adReviews != null) {
        allReviews.addAll(
          ad.adReviews!.where((r) => r.replyTo == "" && r.rating != null),
        );
      }
    }
    allReviews.add(Review(rating: _rating, replyTo: ""));
    if (allReviews.isEmpty) return;
    final total = allReviews.fold<double>(
      0.0,
      (sum, review) => sum + (review.rating ?? 0.0),
    );
    final avg = total / allReviews.length;
    await authNotifier.updateStoreRating(curStore.id, avg);
    setState(() {
      curStore = curStore.copyWith(averageRating: avg);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userHasOrderedThisProduct == null) {
      return Scaffold(
        appBar: AppBar(title: Text("")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final otherUser = widget.producer;
    final store =
        widget.producer.stores.where((s) => s.id == curStore.id).first;

    final keywordMap = {for (var k in Keywords.keywords) k.name: k.icon};

    String getTimeReviewPosted(DateTime date) {
      final difference = DateTime.now().difference(date);

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

    Future<void> submitReview() async {
      setState(() => _isLoading = true);
      if (_rating == 0.0 || reviewController.text == "") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Preencha o campo de comentário e a respetiva avaliação",
            ),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Aviso"),
              content: Text(
                "Só pode avaliar uma vez neste anúncio, tem a certeza que pretender publicar a avaliação?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Publicar"),
                ),
              ],
            ),
      );

      if (confirm == false) {
        setState(() => _isLoading = false);
        return;
      }

      try {
        await authNotifier.submitNewReview(
          widget.ad.id,
          _rating,
          reviewController.text,
          replyToUserId,
        );
        await notificationNotifier.addNewReviewNotification(
          curStore.id,
          authNotifier.currentUser!.id,
        );
      } catch (e) {
        print("Erro $e");
      }
      reviews = await authNotifier.getReviewsForAd(curStore.id, widget.ad.id);
      setReviews(reviews);
      checkIfUserReviewed();
      await updateStoreRating();
      setState(() {
        _isLoading = false;
        hasReviewed = true;
        replyToUserId = null;
      });
      reviewController.clear();
      _rating = 0;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Comentário publicado!")));
    }

    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: () async {
          reviews = await authNotifier.getReviewsForAd(
            curStore.id,
            widget.ad.id,
          );
          setReviews(reviews);
          checkIfUserReviewed();
          await loadUserHasOrdered();
          await updateStoreRating();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImageCarousel(imageUrls: widget.ad.product.imageUrls),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.ad.product.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!authNotifier.currentUser!.isProducer)
                      Tooltip(
                        message:
                            _isFavorite
                                ? 'Remover dos favoritos'
                                : 'Adicionar aos favoritos',
                        child: GestureDetector(
                          onTap: toggleFavorite,
                          child: AnimatedScale(
                            duration: Duration(milliseconds: 200),
                            scale: _isFavorite ? 1.3 : 1.0,
                            curve: Curves.easeInOut,
                            child: Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  _isFavorite
                                      ? Colors.redAccent
                                      : Colors.grey[600],
                              size: 32,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child:
                    widget.promotion != null
                        ? Row(
                          children: [
                            Text(
                              "${widget.ad.product.price.toStringAsFixed(2)} €",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${(widget.ad.product.price * (1 - widget.promotion!.value / 100)).toStringAsFixed(2)} €/${widget.ad.product.unit.toDisplayString()}",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        )
                        : Text(
                          "${widget.ad.product.price.toStringAsFixed(2)} €/${widget.ad.product.unit.toDisplayString()}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
              ),

              const SizedBox(height: 16),
              if (widget.ad.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.ad.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              const SizedBox(height: 16),
              if (widget.ad.keywords != null && widget.ad.keywords!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8.0,
                    children:
                        widget.ad.keywords!.map((k) {
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children:
                          widget.ad
                              .preferredDeliveryMethods(
                                authNotifier.producerUsers,
                              )
                              .map((method) {
                                return Chip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        store.deliveryIcon(method),
                                        size: 16,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        method
                                            .toDisplayString()
                                            .split('.')
                                            .last,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
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
                              builder: (ctx) => ProfilePage(widget.producer),
                            ),
                          ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              widget.producer.imageUrl,
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${widget.producer.firstName} ${widget.producer.lastName}",
                          ),
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
                                child: Image.network(
                                  store.imageUrl!,
                                  width: 75,
                                  height: 75,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          RatingBarIndicator(
                                            rating: curStore.averageRating,
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
                                            "(${curStore.averageRating.toStringAsFixed(1)}) ",
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
                          SendMessageButton(
                            otherUser: otherUser,
                            isIconButton: true,
                            store: store,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (widget.ad.adReviews != null)
                getReviewsSection(context, getTimeReviewPosted, submitReview),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          foregroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed:
                            () => showDialog(
                              context: context,
                              builder:
                                  (_) => QuantityDialog(
                                    onConfirm: (double quantity) {
                                      addToCart(quantity);
                                    },
                                    product: widget.ad.product,
                                  ),
                            ),

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
      ),
    );
  }

  Review? getReplyUser(String reviewerId) {
    return reviews.firstWhereOrNull((r) => r.replyTo == reviewerId);
  }

  Widget getReviewsSection(
    BuildContext context,
    String Function(DateTime date) getTimeReviewPosted,
    Future<void> Function() submitReview,
  ) {
    final canReview =
        userHasOrderedThisProduct == true &&
        !hasReviewed &&
        authNotifier.currentUser!.id != widget.producer.id;
    print("Pode dar review: $canReview");
    final mainReviews = reviews.where((r) => r.replyTo == "").toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "Comentários:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          mainReviews.length > 0
              ? Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: mainReviews.length,
                    itemBuilder: (ctx, i) {
                      final replyReview = getReplyUser(
                        mainReviews[i].reviewerId!,
                      );
                      return Column(
                        children: [
                          Column(
                            children: [
                              ListTile(
                                isThreeLine: true,
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mainReviews[i].description!,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                title: InkWell(
                                  onTap:
                                      () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ProfilePage(
                                                authNotifier.allUsers
                                                    .where(
                                                      (el) =>
                                                          el.id ==
                                                          mainReviews[i]
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
                                            authNotifier.allUsers
                                                .where(
                                                  (u) =>
                                                      u.id ==
                                                      mainReviews[i].reviewerId,
                                                )
                                                .first
                                                .imageUrl,
                                          ),
                                          radius: 10,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            authNotifier.allUsers
                                                    .where(
                                                      (el) =>
                                                          el.id ==
                                                          mainReviews[i]
                                                              .reviewerId,
                                                    )
                                                    .first
                                                    .firstName +
                                                " " +
                                                authNotifier.allUsers
                                                    .where(
                                                      (el) =>
                                                          el.id ==
                                                          mainReviews[i]
                                                              .reviewerId,
                                                    )
                                                    .first
                                                    .lastName,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        RatingBarIndicator(
                                          rating: mainReviews[i].rating!,
                                          itemBuilder:
                                              (context, index) => Icon(
                                                Icons.star,
                                                color: Colors.amber.shade700,
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
                                        mainReviews[i].dateTime!,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (authNotifier.currentUser!.id ==
                                      widget.producer.id &&
                                  replyReview == null)
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
                                        onTap: () {
                                          setState(() {
                                            replyToUserId =
                                                mainReviews[i].reviewerId;
                                          });
                                        },
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
                                            () =>
                                                print("Reportado com sucesso!"),
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
                              if (replyReview != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: ListTile(
                                    isThreeLine: true,
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          replyReview.description!,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    title: InkWell(
                                      onTap:
                                          () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ProfilePage(
                                                    authNotifier.allUsers
                                                        .where(
                                                          (el) =>
                                                              el.id ==
                                                              replyReview
                                                                  .reviewerId,
                                                        )
                                                        .first,
                                                  ),
                                            ),
                                          ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.tertiary,
                                              backgroundImage: NetworkImage(
                                                authNotifier.allUsers
                                                    .where(
                                                      (u) =>
                                                          u.id ==
                                                          replyReview
                                                              .reviewerId,
                                                    )
                                                    .first
                                                    .imageUrl,
                                              ),
                                              radius: 10,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    authNotifier.allUsers
                                                            .where(
                                                              (el) =>
                                                                  el.id ==
                                                                  replyReview
                                                                      .reviewerId,
                                                            )
                                                            .first
                                                            .firstName +
                                                        " " +
                                                        authNotifier.allUsers
                                                            .where(
                                                              (el) =>
                                                                  el.id ==
                                                                  replyReview
                                                                      .reviewerId,
                                                            )
                                                            .first
                                                            .lastName,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Flexible(
                                                    child: Card(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              5,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.person,
                                                              size: 20,
                                                            ),
                                                            FittedBox(
                                                              fit:
                                                                  BoxFit
                                                                      .scaleDown,
                                                              child: Text(
                                                                "Produtor",
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                            replyReview.dateTime!,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (replyToUserId == mainReviews[i].reviewerId)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Responder à avaliação:"),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: reviewController,
                                              decoration: InputDecoration(
                                                labelText: 'Comentário',
                                                hintText:
                                                    'Escreve o teu comentário...',
                                                border:
                                                    const OutlineInputBorder(),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .secondaryFixed,
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .surface,
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                alignLabelWithHint: true,
                                              ),
                                              maxLines: null,
                                              minLines: 4,
                                              keyboardType:
                                                  TextInputType.multiline,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.close),
                                                onPressed: () {
                                                  setState(() {
                                                    replyToUserId = null;
                                                  });
                                                },
                                              ),
                                              (_isLoading)
                                                  ? const SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                  : ElevatedButton(
                                                    onPressed:
                                                        () => submitReview(),
                                                    child: const Text(
                                                      "Publicar",
                                                    ),
                                                  ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  ),
                ],
              )
              : Padding(
                padding: const EdgeInsets.all(15),
                child: Text("Sem comentários..."),
              ),
          if (canReview) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Avaliação:"),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      labelText: 'Comentário',
                      hintText: 'Escreve o teu comentário...',
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondaryFixed,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.surface,
                          width: 0.5,
                        ),
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: null,
                    minLines: 4,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder:
                      (context, _) =>
                          Icon(Icons.star, color: Colors.amberAccent),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      (_isLoading)
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            onPressed: () => submitReview(),
                            child: Text("Publicar"),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
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
                  : Image.network(
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

class QuantityDialog extends StatefulWidget {
  final void Function(double quantity) onConfirm;
  final Product product;

  const QuantityDialog({
    Key? key,
    required this.onConfirm,
    required this.product,
  }) : super(key: key);

  @override
  State<QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  late double _quantity;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _quantity = 1;
    _controller = TextEditingController(
      text:
          widget.product.unit == Unit.KG
              ? widget.product.minAmount!.toStringAsFixed(2)
              : widget.product.minAmount!.toStringAsFixed(0),
    );
  }

  void _updateQuantity(double newValue) {
    setState(() {
      _quantity =
          newValue
              .clamp(
                widget.product.minAmount!.toDouble(),
                widget.product.stock!,
              )
              .toDouble();
      _controller.text =
          widget.product.unit == Unit.KG
              ? _quantity.toStringAsFixed(2)
              : _quantity.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Escolha a quantidade"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              if (_quantity > 1) _updateQuantity(_quantity - 1);
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      _updateQuantity(parsed);
                    }
                  },
                ),
              ),
              SizedBox(width: 4),
              Text(
                " ${widget.product.unit == Unit.KG
                    ? widget.product.unit.toDisplayString()
                    : (widget.product.unit == Unit.UNIT && _quantity > 1)
                    ? widget.product.unit.toDisplayString() + "s"
                    : widget.product.unit.toDisplayString()}",
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _updateQuantity(_quantity + 1);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.secondary,
          ),
          child: const Text("Confirmar"),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onConfirm(_quantity);
          },
        ),
      ],
    );
  }
}
