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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/services/auth/auth_notifier.dart';
import '../../core/services/chat/chat_list_notifier.dart';
import '../../core/services/chat/chat_service.dart';
import '../../utils/app_routes.dart';

// ignore: must_be_immutable
class ProductAdDetailScreen extends StatefulWidget {
  final ProductAd ad;
  final ProducerUser producer;
  int? promotion;

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
  Future<void> addToCart(double quantity) async {
    await Provider.of<AuthNotifier>(
      context,
      listen: false,
    ).addToCart(widget.ad, quantity).then((_) {
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
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser!;
    final otherUser = widget.producer;
    final alreadyExists = verifyIfAlreadyExistsConversation(
      currentUser.id,
      otherUser.id,
    );
    final chatService = Provider.of<ChatService>(context, listen: false);
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final store =
        widget.producer.stores[Provider.of<AuthNotifier>(
          context,
          listen: false,
        ).selectedStoreIndex];

    final keywordMap = {for (var k in Keywords.keywords) k.name: k.icon};

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

    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageCarousel(imageUrls: widget.ad.product.imageUrl),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.ad.product.name,
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
                            "${(widget.ad.product.price * (1 - widget.promotion! / 100)).toStringAsFixed(2)} €/${widget.ad.product.unit.toDisplayString()}",
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                      method.toDisplayString().split('.').last,
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
                          onPressed: () async {
                            if (alreadyExists) {
                              final chatList =
                                  Provider.of<ChatListNotifier>(
                                    context,
                                    listen: false,
                                  ).chats;
                              final existingChat = chatList.firstWhere(
                                (chat) =>
                                    (chat.consumerId == currentUser.id &&
                                        chat.producerId == otherUser.id) ||
                                    (chat.producerId == currentUser.id &&
                                        chat.consumerId == otherUser.id),
                              );
                              chatService.updateCurrentChat(existingChat);
                              Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.CHAT_PAGE);
                              return;
                            }

                            // Criar nova conversa
                            final _messageController = TextEditingController();
                            final result = await showDialog<String>(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: Text("Enviar mensagem"),
                                    content: TextField(
                                      controller: _messageController,
                                      decoration: const InputDecoration(
                                        hintText: "Escreve a tua mensagem...",
                                      ),
                                      maxLines: null,
                                      autofocus: true,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(),
                                        child: const Text("Fechar"),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(
                                              _messageController.text.trim(),
                                            ),
                                        child: const Text("Enviar"),
                                      ),
                                    ],
                                  ),
                            );

                            if (result != null && result.isNotEmpty) {
                              final newChat = await chatService.createChat(
                                currentUser.isProducer
                                    ? otherUser.id
                                    : currentUser.id,
                                currentUser.isProducer
                                    ? currentUser.id
                                    : otherUser.id,
                              );

                              await chatService.save(
                                result,
                                currentUser,
                                newChat.id,
                              );

                              Provider.of<ChatListNotifier>(
                                context,
                                listen: false,
                              ).addChat(newChat);

                              chatService.updateCurrentChat(newChat);

                              Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.CHAT_PAGE);
                            }
                          },
                          icon: Icon(Icons.message_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (widget.ad.adReviews != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "Comentários:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.ad.adReviews!.length,
                          itemBuilder:
                              (ctx, i) => Column(
                                children: [
                                  Column(
                                    children: [
                                      ListTile(
                                        isThreeLine: true,
                                        subtitle: Column(
                                          children: [
                                            Text(
                                              widget
                                                  .ad
                                                  .adReviews![i]
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
                                                      (context) => ProfilePage(
                                                        AuthService().users
                                                            .where(
                                                              (el) =>
                                                                  el.id ==
                                                                  widget
                                                                      .ad
                                                                      .adReviews![i]
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
                                                    AuthService().users
                                                        .where(
                                                          (el) =>
                                                              el.id ==
                                                              widget
                                                                  .ad
                                                                  .adReviews![i]
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
                                                    AuthService().users
                                                            .where(
                                                              (el) =>
                                                                  el.id ==
                                                                  widget
                                                                      .ad
                                                                      .adReviews![i]
                                                                      .reviewerId,
                                                            )
                                                            .first
                                                            .firstName +
                                                        " " +
                                                        AuthService().users
                                                            .where(
                                                              (el) =>
                                                                  el.id ==
                                                                  widget
                                                                      .ad
                                                                      .adReviews![i]
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
                                                ),
                                                RatingBarIndicator(
                                                  rating:
                                                      widget
                                                          .ad
                                                          .adReviews![i]
                                                          .rating!,
                                                  itemBuilder:
                                                      (context, index) => Icon(
                                                        Icons.star,
                                                        color:
                                                            Colors
                                                                .amber
                                                                .shade700,
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
                                                widget
                                                    .ad
                                                    .adReviews![i]
                                                    .dateTime!,
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
                                  const Divider(),
                                ],
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Comentar:"),
                              const SizedBox(height: 10),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Comentário',
                                  hintText: 'Escreve o teu comentário...',

                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondaryFixed,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      width: 0.5,
                                    ), // cor quando focado
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: Text("Publicar"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                      onPressed:
                          () => showDialog(
                            context: context,
                            builder:
                                (_) => QuantityDialog(
                                  onConfirm: (double quantity) {
                                    addToCart(
                                      quantity,
                                    ); // envia quantidade como parâmetro
                                  },
                                  unit: widget.ad.product.unit,
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
  final Unit unit;

  const QuantityDialog({Key? key, required this.onConfirm, required this.unit})
    : super(key: key);

  @override
  State<QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  double _quantity = 1.0;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '1');
  }

  void _updateQuantity(double newValue) {
    setState(() {
      _quantity = newValue.clamp(1, 999).toDouble();
      _controller.text =
          widget.unit == Unit.KG
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
