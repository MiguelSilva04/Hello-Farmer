import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/invoice_page.dart';
import 'package:harvestly/components/producer/store_page.dart';
import 'package:harvestly/components/sendMessageButton.dart';
import 'package:harvestly/core/models/order.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/store.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timelines_plus/timelines_plus.dart';
import '../../core/models/app_user.dart';
import '../../core/models/consumer_user.dart';
import '../../core/services/auth/auth_notifier.dart';
import '../../core/services/auth/notification_notifier.dart';
import 'package:collection/collection.dart';

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
    final Store? store = producer.stores.cast<Store?>().firstWhere(
      (s) => s?.id == order.storeId,
      orElse: () => null,
    );

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
          GestureDetector(
            onTap: () {
              if (store != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => StorePage(store: store)),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      displayedUser is ConsumerUser
                          ? displayedUser.imageUrl
                          : store!.imageUrl!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayedUser is ConsumerUser
                              ? "${displayedUser.firstName} ${displayedUser.lastName}"
                              : store?.name ?? 'Sem nome',
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
                  SendMessageButton(
                    otherUser: displayedUser,
                    isIconButton: true,
                    store: authNotifier.currentUser!.id != producer.id ? store : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Encomenda")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: StreamBuilder<Order>(
            stream: authNotifier.orderStream(order.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(child: Text("Encomenda não encontrada"));
              }
              final curOrder = snapshot.data!;

              final date = DateFormat.yMMMEd(
                'pt_PT',
              ).format(curOrder.deliveryDate);
              final products = curOrder.ordersItems;
              final hasMissingProducts = products.any((item) {
                final ad = authNotifier.producerUsers
                    .expand((p) => p.stores.expand((s) => s.productsAds ?? []))
                    .cast<ProductAd?>()
                    .firstWhere(
                      (ad) => ad?.id == item.productAdId,
                      orElse: () => null,
                    );

                return ad?.product == null;
              });
              final deliveryMethod = curOrder.deliveryMethod!.toDisplayString();
              return Column(
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
                                  if ((order.state == OrderState.Pending ||
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
                                  if (order.state == OrderState.Abandoned) ...[
                                    AutoSizeText(
                                      "Abandonada desde: ",
                                      style: const TextStyle(fontSize: 15),
                                      maxLines: 1,
                                      minFontSize: 10,
                                    ),
                                    AutoSizeText(
                                      DateFormat.yMMMd(
                                        'pt_PT',
                                      ).format(curOrder.deliveryDate),
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
                                    "${curOrder.id}",
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
                              curOrder.address,
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
                      if (authNotifier.currentUser!.id == consumer?.id ||
                          !authNotifier.currentUser!.isProducer)
                        if (store != null)
                          buildUserContactSection(
                            context: context,
                            displayedUser: producer,
                            title: "Banca Vendedora",
                            subtitle: store.city,
                            isProducerSide: false,
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Text(
                              "Banca não disponível.",
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      if (authNotifier.currentUser!.id == producer.id)
                        buildUserContactSection(
                          context: context,
                          displayedUser: consumer!,
                          title: "Comprador",
                          subtitle: consumer!.city,
                          isProducerSide: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Valor: ", style: const TextStyle(fontSize: 16)),
                      Text(
                        "${curOrder.totalPrice.toStringAsFixed(2)} €",
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
                          text: deliveryMethod,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Consultar estado",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  OrderTimeline(order: curOrder),

                  const Divider(),
                  const Text(
                    "Produtos Encomendados",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = products[index];

                          final ad = authNotifier.producerUsers
                              .expand(
                                (p) =>
                                    p.stores.expand((s) => s.productsAds ?? []),
                              )
                              .cast<ProductAd?>()
                              .firstWhere(
                                (ad) => ad?.id == item.productAdId,
                                orElse: () => null,
                              );

                          final product = ad?.product;

                          if (ad == null || product == null) {
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      child: Icon(
                                        Icons.hide_image,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Produto eliminado pelo produtor",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Este produto foi removido e já não se encontra disponível.",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      if (!authNotifier.currentUser!.isProducer)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () async {
                                                await Provider.of<AuthNotifier>(
                                                  context,
                                                  listen: false,
                                                ).addToCart(ad, item.qty).then((
                                                  _,
                                                ) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Produto adicionado ao carrinho.",
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 2,
                                                      ),
                                                    ),
                                                  );
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.shopping_cart_checkout,
                                              ),
                                              label: const Text(
                                                "Comprar novamente",
                                              ),
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
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Para mais detalhes sobre a entrega, contacta o vendedor.",
                    style: TextStyle(fontSize: 12),
                  ),

                  if (!hasMissingProducts)
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          foregroundColor:
                              Theme.of(context).colorScheme.secondary,
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
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Fatura indisponível: um ou mais produtos foram removidos.",
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 10),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class OrderTimeline extends StatefulWidget {
  final Order order;

  OrderTimeline({required this.order});

  @override
  State<OrderTimeline> createState() => _OrderTimelineState();
}

class _OrderTimelineState extends State<OrderTimeline> {
  late List<OrderState> steps;
  late int currentStep;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    steps =
        widget.order.deliveryMethod == DeliveryMethod.PICKUP
            ? [OrderState.Pending, OrderState.Ready, OrderState.Delivered]
            : [OrderState.Pending, OrderState.Sent, OrderState.Delivered];

    currentStep = steps.indexOf(widget.order.state);
  }

  Future<void> updateOrderState() async {
    setState(() => _isLoading = true);
    final newOrderState = steps[currentStep];

    // Enviar notificação se o novo estado for OrderState.Sent
    if (newOrderState == OrderState.Sent) {
      final authNotifierInstance = Provider.of<AuthNotifier>(
        context,
        listen: false,
      );
      final notificationNotifier = Provider.of<NotificationNotifier>(
        context,
        listen: false,
      );

      final producer = authNotifierInstance.producerUsers.firstWhereOrNull(
        (p) => p.stores.any((s) => s.id == widget.order.storeId),
      );
      Store? store;
      if (producer != null) {
        store = producer.stores.cast<Store?>().firstWhereOrNull(
          (s) => s?.id == widget.order.storeId,
        );
      }

      if (store != null) {
        await notificationNotifier.addOrderSentNotification(
          store,
          widget.order.consumerId,
        );
      }
    }

    await Provider.of<AuthNotifier>(
      context,
      listen: false,
    ).changeOrderState(widget.order.id, newOrderState);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isProducer =
        Provider.of<AuthNotifier>(
          context,
          listen: false,
        ).currentUser!.isProducer;
    final canAdvance = isProducer && currentStep < steps.length - 1;
    return SizedBox(
      height: MediaQuery.of(context).size.height * ((canAdvance) ? 0.30 : 0.25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TimelineTheme(
              data: TimelineThemeData(
                direction: Axis.vertical,
                nodePosition: 0.3,
                connectorTheme: ConnectorThemeData(
                  color: Colors.grey.shade300,
                  thickness: 4.0,
                ),
                indicatorTheme: const IndicatorThemeData(size: 30),
              ),
              child: SingleChildScrollView(
                child: FixedTimeline.tileBuilder(
                  builder: TimelineTileBuilder.connected(
                    connectionDirection: ConnectionDirection.after,
                    itemExtent: 70,
                    itemCount: steps.length,
                    contentsBuilder: (context, index) {
                      final isActive = index <= currentStep;
                      return Padding(
                        padding: const EdgeInsets.only(top: 5, left: 8),
                        child: Text(
                          steps[index].toDisplayString(),
                          style: TextStyle(
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                            color:
                                isActive
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                    indicatorBuilder: (context, index) {
                      final isActive = index <= currentStep;
                      return DotIndicator(
                        size: 24,
                        color:
                            isActive
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade400,
                        child:
                            isActive
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                                : null,
                      );
                    },
                    connectorBuilder: (context, index, _) {
                      final isActive = index < currentStep;
                      return SolidLineConnector(
                        color:
                            isActive
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          if (canAdvance) ...[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.05,
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          shadowColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.4),
                        ),
                        icon: const Icon(Icons.next_plan_rounded, size: 28),
                        label: const Text(
                          "Próximo passo",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text("Aviso"),
                                  content: const Text(
                                    "Pretende avançar o estado da encomenda?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text("Não"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        setState(() => currentStep += 1);
                                        await updateOrderState();
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text("Sim"),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
