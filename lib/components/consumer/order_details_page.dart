// order_detail_page.dart

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/invoice_page.dart';
import 'package:harvestly/core/models/order.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/store.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/models/app_user.dart';
import '../../core/models/consumer_user.dart';
import '../../core/services/auth/auth_notifier.dart';
import '../../core/services/chat/chat_list_notifier.dart';
import '../../core/services/chat/chat_service.dart';
import '../../utils/app_routes.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;
  final ProducerUser producer;
  final ConsumerUser? consumer;

  const OrderDetailsPage({
    super.key,
    required this.order,
    required this.producer,
    this.consumer,
  });

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);
    bool verifyIfAlreadyExistsConversation(String userAId, String userBId) {
      final chatList =
          Provider.of<ChatListNotifier>(context, listen: false).chats;

      return chatList.any(
        (chat) =>
            (chat.consumerId == userAId && chat.producerId == userBId) ||
            (chat.producerId == userAId && chat.consumerId == userBId),
      );
    }

    Widget buildUserContactSection({
      required BuildContext context,
      required AppUser displayedUser,
      required String title,
      required String? subtitle,
      required bool isProducerSide,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      displayedUser.imageUrl != null
                          ? NetworkImage(displayedUser.imageUrl!)
                          : null,
                  child:
                      displayedUser.imageUrl == null
                          ? Icon(
                            isProducerSide ? Icons.store : Icons.person,
                            size: 30,
                          )
                          : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayedUser is ConsumerUser
                            ? "${displayedUser.firstName} ${displayedUser.lastName}"
                            : (displayedUser as ProducerUser)
                                .stores[Provider.of<AuthNotifier>(
                                  context,
                                  listen: false,
                                ).selectedStoreIndex]
                                .name!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (subtitle != null)
                        Row(
                          children: [
                            const Icon(Icons.pin_drop_rounded),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.secondaryFixed,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat),
                  tooltip:
                      isProducerSide
                          ? "Contactar consumidor"
                          : "Contactar produtor",
                  onPressed: () async {
                    final currentUser =
                        Provider.of<AuthNotifier>(
                          context,
                          listen: false,
                        ).currentUser!;
                    final otherUser = displayedUser;

                    final chatList =
                        Provider.of<ChatListNotifier>(
                          context,
                          listen: false,
                        ).chats;

                    final alreadyExists = chatList.any(
                      (chat) =>
                          (chat.consumerId == currentUser.id &&
                              chat.producerId == otherUser.id) ||
                          (chat.producerId == currentUser.id &&
                              chat.consumerId == otherUser.id),
                    );

                    if (alreadyExists) {
                      final existingChat = chatList.firstWhere(
                        (chat) =>
                            (chat.consumerId == currentUser.id &&
                                chat.producerId == otherUser.id) ||
                            (chat.producerId == currentUser.id &&
                                chat.consumerId == otherUser.id),
                      );
                      chatService.updateCurrentChat(existingChat);
                      Navigator.of(context).pushNamed(AppRoutes.CHAT_PAGE);
                      return;
                    }

                    final _messageController = TextEditingController();
                    final result = await showDialog<String>(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text("Enviar mensagem"),
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
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text("Fechar"),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(
                                      ctx,
                                    ).pop(_messageController.text.trim()),
                                child: const Text("Enviar"),
                              ),
                            ],
                          ),
                    );

                    if (result != null && result.isNotEmpty) {
                      final newChat = await chatService.createChat(
                        currentUser.isProducer ? otherUser.id : currentUser.id,
                        currentUser.isProducer ? currentUser.id : otherUser.id,
                      );

                      await chatService.save(result, currentUser, newChat.id);

                      Provider.of<ChatListNotifier>(
                        context,
                        listen: false,
                      ).addChat(newChat);
                      chatService.updateCurrentChat(newChat);
                      Navigator.of(context).pushNamed(AppRoutes.CHAT_PAGE);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    final currentUser = authNotifier.currentUser!;
    final date = DateFormat.yMMMEd('pt_PT').format(order.deliveryDate);
    final products = order.ordersItems;
    final deliveryMethod =
        (AuthService().users
                    .whereType<ProducerUser>()
                    .expand((p) {
                      if (p.stores.isNotEmpty) {
                        return p
                                .stores[Provider.of<AuthNotifier>(
                                  context,
                                  listen: false,
                                ).selectedStoreIndex]
                                .productsAds ??
                            [];
                      } else {
                        return [];
                      }
                    })
                    .firstWhere(
                      (ad) => ad.id == products.first.productAdId,
                      orElse:
                          () => throw Exception("ProductAd não encontrado."),
                    )
                as ProductAd)
            .preferredDeliveryMethods(authNotifier.producerUsers)
            .first;
    return Scaffold(
      appBar: AppBar(title: const Text("Encomenda")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.calendar_today, size: 25),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (order.state == OrderState.Delivered) ...[
                              AutoSizeText(
                                "Data da entrega: ",
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                minFontSize: 10,
                              ),
                              AutoSizeText(
                                date,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                minFontSize: 10,
                              ),
                            ],
                            if ((order.state == OrderState.Pendent ||
                                order.state == OrderState.Sent)) ...[
                              AutoSizeText(
                                "Entrega prevista para: ",
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                minFontSize: 10,
                              ),
                              AutoSizeText(
                                date,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                minFontSize: 10,
                              ),
                            ],
                            if (order.deliveryDate.isAfter(DateTime.now()) &&
                                order.state == OrderState.Sent) ...[
                              AutoSizeText(
                                "Abandonada desde: ",
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                minFontSize: 10,
                              ),
                              AutoSizeText(
                                DateFormat.yMMMd(
                                  'pt_PT',
                                ).format(order.deliveryDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                minFontSize: 10,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.inventory, size: 25),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              "Encomenda Nº ",
                              style: const TextStyle(fontSize: 15),
                              maxLines: 1,
                              minFontSize: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AutoSizeText(
                              "${order.id}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              minFontSize: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.home, size: 25),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Morada de entrega: ",
                        style: TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        order.address,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                if (!currentUser.isProducer)
                  buildUserContactSection(
                    context: context,
                    displayedUser: producer,
                    title: "Banca Vendedora",
                    subtitle:
                        producer.stores[authNotifier.selectedStoreIndex].city,
                    isProducerSide: true,
                  ),
                if (currentUser.isProducer)
                  buildUserContactSection(
                    context: context,
                    displayedUser: consumer!,
                    title: "Comprador",
                    subtitle: consumer!.city,
                    isProducerSide: false,
                  ),
              ],
            ),
            Row(
              children: [
                Text("Estado: ", style: const TextStyle(fontSize: 16)),
                Text(
                  order.state.toDisplayString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("Valor: ", style: const TextStyle(fontSize: 16)),
                Text(
                  "${order.totalPrice.toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: "Entrega: ",
                style: TextStyle(fontSize: 16),
                children: [
                  TextSpan(
                    text: deliveryMethod.toDisplayString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              "Produtos Encomendados",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            /// Lista de produtos
            Expanded(
              child: ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = products[index];
                  final ad =
                      AuthService().users
                              .whereType<ProducerUser>()
                              .expand((p) {
                                if (p.stores.isNotEmpty) {
                                  return p
                                          .stores[Provider.of<AuthNotifier>(
                                            context,
                                            listen: false,
                                          ).selectedStoreIndex]
                                          .productsAds ??
                                      [];
                                } else {
                                  return [];
                                }
                              })
                              .firstWhere(
                                (ad) => ad.id == item.productAdId,
                                orElse:
                                    () =>
                                        throw Exception(
                                          "ProductAd não encontrado.",
                                        ),
                              )
                          as ProductAd;

                  final product = ad.product;
                  final quantityText =
                      product.unit == Unit.KG
                          ? "${item.qty} ${product.unit.toDisplayString()}"
                          : "x${item.qty.toStringAsFixed(0)}";

                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.imageUrls.first,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$quantityText ${product.name}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${product.price.toStringAsFixed(2)}€/${product.unit.toDisplayString()}",
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondaryFixed,
                                  fontSize: 16,
                                ),
                              ),
                              if (!currentUser.isProducer)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.shopping_cart_checkout,
                                      ),
                                      label: const Text("Comprar novamente"),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Para mais detalhes sobre a entrega, contacta o vendedor.",
              style: TextStyle(fontSize: 12),
            ),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (ctx) => InvoicePageConsumer(
                              order: order,
                              producer: producer,
                            ),
                      ),
                    ),
                icon: Icon(
                  Icons.receipt,
                  size: 30,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                label: const Text(
                  "Consultar fatura",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
