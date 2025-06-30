import 'dart:math';

import 'package:flutter/material.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/models/consumer_user.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/shopping_cart.dart';
import 'package:harvestly/core/models/store.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:collection/collection.dart';
import 'package:harvestly/core/services/auth/notification_notifier.dart';
import 'package:provider/provider.dart';

import '../../core/services/auth/auth_notifier.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  late List<AppUser> users;
  late ProductAdFinder finder;
  late Map<Store, Map<ProductAd, double>> storeProductAdQuantities;
  late ShoppingCart? cart;
  late AuthNotifier authNotifier;
  late AppUser currentUser;

  bool _isLoading = false;
  final Map<Store, bool> _isCheckout = {};
  final Map<Store, GlobalKey<FormState>> _checkoutFormKeys = {};
  final Map<Store, DeliveryMethod?> _selectedDeliveryMethod = {};
  final Map<Store, String?> _address = {};
  final Map<Store, String?> _postalCode = {};
  final Map<Store, String?> _city = {};
  final Map<Store, String?> _phoneNumber = {};
  final Map<Store, String?> _discountCode = {};

  @override
  void initState() {
    super.initState();
    authNotifier = Provider.of(context, listen: false);
    currentUser = authNotifier.currentUser!;
    cart = (authNotifier.currentUser as ConsumerUser).shoppingCart;
    users = authNotifier.producerUsers;
    finder = ProductAdFinder(users);
    storeProductAdQuantities = {};

    _loadCartProducts();
  }

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  Future<void> sendOrderToFirestore({
    required Store store,
    required String consumerId,
    required String address,
    required String postalCode,
    required String phone,
    required String discountCode,
    required List<Map<String, dynamic>> cartItems,
    required double totalPrice,
    required DeliveryMethod deliveryMethod,
  }) async {
    setState(() => _isLoading = true);
    final orderId = await authNotifier.createOrder(
      consumerId: consumerId,
      storeId: store.id,
      address: address,
      cartItems: cartItems,
      totalPrice: roundDouble(totalPrice, 2),
      postalCode: postalCode,
      phone: phone,
      discountCode: discountCode,
      deliveryMethod: deliveryMethod,
    );
    await Provider.of<NotificationNotifier>(
      context,
      listen: false,
    ).addOrderPlacedNotification(currentUser, store.id, orderId);
    setState(() => _isLoading = false);
    _loadCartProducts();
  }

  void _loadCartProducts() {
    storeProductAdQuantities.clear();

    if (cart != null && cart!.productsQty != null) {
      for (var product in cart!.productsQty!) {
        final productAd = finder.findProductAdById(product.productAdId);
        final productStore = finder.findStoreByAdId(product.productAdId);

        if (productAd != null && productStore != null) {
          storeProductAdQuantities.putIfAbsent(productStore, () => {});
          storeProductAdQuantities[productStore]![productAd] = product.quantity;
        }
      }
    }

    for (var store in storeProductAdQuantities.keys) {
      _isCheckout.putIfAbsent(store, () => false);
      _checkoutFormKeys.putIfAbsent(store, () => GlobalKey<FormState>());
      _selectedDeliveryMethod.putIfAbsent(
        store,
        () =>
            store.preferredDeliveryMethod.length == 1
                ? store.preferredDeliveryMethod.first
                : null,
      );
      _address.putIfAbsent(store, () => null);
      _postalCode.putIfAbsent(store, () => null);
      _city.putIfAbsent(store, () => null);
      _phoneNumber.putIfAbsent(store, () => null);
      _discountCode.putIfAbsent(store, () => null);
    }

    setState(() {});
  }

  double _calculateTotal(Store store) {
    double total = 0;

    storeProductAdQuantities[store]?.forEach((ad, qty) {
      final promotion =
          cart?.productsQty
              ?.firstWhere(
                (regist) => regist.productAdId == ad.id,
                orElse:
                    () => ProductRegist(
                      productAdId: ad.id,
                      quantity: qty,
                      promotion: 0,
                    ),
              )
              .promotion;

      total += PriceUtils.calculateDiscountedPrice(ad, qty, promotion);
    });

    return total;
  }

  void _changeQuantity(Store store, ProductAd productAd, int delta) async {
    final consumer = authNotifier.currentUser as ConsumerUser;

    final currentQty = storeProductAdQuantities[store]![productAd]!;
    final newQty = currentQty + delta;

    if (newQty <= 0) {
      _removeProduct(store, productAd);
      return;
    }

    if (delta > 0) {
      await Provider.of<AuthNotifier>(
        context,
        listen: false,
      ).increaseQuantity(consumer.id, productAd.id);
    } else {
      await Provider.of<AuthNotifier>(
        context,
        listen: false,
      ).decreaseQuantity(consumer.id, productAd.id);
    }

    setState(() {
      storeProductAdQuantities[store]![productAd] = newQty;
    });
  }

  void _removeProduct(Store store, ProductAd productAd) async {
    final consumer = authNotifier.currentUser as ConsumerUser;

    await Provider.of<AuthNotifier>(
      context,
      listen: false,
    ).removeProduct(consumer.id, productAd.id);

    setState(() {
      storeProductAdQuantities[store]!.remove(productAd);
      if (storeProductAdQuantities[store]!.isEmpty) {
        storeProductAdQuantities.remove(store);
      }
    });
  }

  void _submitCheckoutForm(Store store) async {
    final formKey = _checkoutFormKeys[store]!;
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setState(() => _isLoading = true);

      final userId = AuthService().currentUser!.id;
      final cartItems =
          storeProductAdQuantities[store]!.entries
              .map(
                (entry) => {'productId': entry.key.id, 'quantity': entry.value},
              )
              .toList();

      await sendOrderToFirestore(
        store: store,
        consumerId: userId,
        address: "${_address[store]}, ${_postalCode[store]} ${_city[store]}",
        cartItems: cartItems,
        totalPrice: _calculateTotal(store),
        postalCode: _postalCode[store]!,
        phone: _phoneNumber[store]!,
        discountCode: _discountCode[store] ?? '',
        deliveryMethod: _selectedDeliveryMethod[store]!,
      );

      setState(() {
        _isLoading = false;
        _isCheckout[store] = false;
      });

      _loadCartProducts();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Pedido efetuado com sucesso!")));
    }
  }

  Widget _buildCheckoutForm(Store store) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _checkoutFormKeys[store],
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              "Finalizar Pedido - ${store.name}",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: "Morada de entrega"),
              onSaved: (value) => _address[store] = value,
              validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Código Postal"),
              onSaved: (value) => _postalCode[store] = value,
              validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              maxLength: 10,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Cidade"),
              onSaved: (value) => _city[store] = value,
              validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Telefone"),
              keyboardType: TextInputType.phone,
              onSaved: (value) => _phoneNumber[store] = value,
              validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              maxLength: 9,
            ),
            SizedBox(height: 24),
            (store.preferredDeliveryMethod.length > 1)
                ? DropdownButtonFormField<DeliveryMethod>(
                  dropdownColor: Theme.of(context).colorScheme.secondary,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                  decoration: InputDecoration(labelText: "Método de entrega"),
                  value: _selectedDeliveryMethod[store],
                  onChanged: (value) {
                    setState(() {
                      _selectedDeliveryMethod[store] = value;
                    });
                  },
                  validator:
                      (value) =>
                          value == null
                              ? "Selecione um método de entrega"
                              : null,
                  items:
                      store.preferredDeliveryMethod.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(method.toDisplayString()),
                        );
                      }).toList(),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Método de entrega:",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _selectedDeliveryMethod[store]!.toIcon(),
                              size: 20,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDeliveryMethod[store]!.toDisplayString(),
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed:
                      () => setState(() {
                        _selectedDeliveryMethod[store] = null;
                        _isCheckout[store] = false;
                      }),
                  child: Text("Cancelar"),
                ),
                (_isLoading)
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () => _submitCheckoutForm(store),
                      child: Text("Comprar"),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartView() {
    if (storeProductAdQuantities.isEmpty) {
      return Center(child: Text("Carrinho Vazio"));
    }

    return ListView.separated(
      itemCount: storeProductAdQuantities.entries.length,
      separatorBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(
              thickness: 3,
              color: Theme.of(context).colorScheme.primary.withAlpha(77),
            ),
          ),
      itemBuilder: (context, idx) {
        final entry = storeProductAdQuantities.entries.elementAt(idx);
        final store = entry.key;
        final productAdEntries = entry.value.entries.toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Banca: ${store.name}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Divider(),
              ...productAdEntries.map((productEntry) {
                final productAd = productEntry.key;
                final qty = productEntry.value;
                final product = productAd.product;
                final promotion =
                    cart?.productsQty
                        ?.where((p) => p.productAdId == productAd.id)
                        .first
                        .promotion ??
                    0;
                final oldPrice = product.price * qty;
                final totalPrice = PriceUtils.calculateDiscountedPrice(
                  productAd,
                  qty,
                  promotion,
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      product.imageUrls.isNotEmpty
                          ? Image.network(
                            product.imageUrls.first,
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                          )
                          : Icon(Icons.image_not_supported, size: 100),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Categoria: ${product.category}"),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                InkWell(
                                  onTap:
                                      () =>
                                          _changeQuantity(store, productAd, -1),
                                  child: Icon(Icons.remove_circle_outline),
                                ),
                                SizedBox(width: 5),
                                Row(
                                  children: [
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 250),
                                      child: Text(
                                        product.unit == Unit.KG
                                            ? qty.toStringAsFixed(2)
                                            : qty.toStringAsFixed(0),
                                        key: ValueKey<double>(qty),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      " ${product.unit == Unit.KG
                                          ? product.unit.toDisplayString()
                                          : (product.unit == Unit.UNIT && qty > 1)
                                          ? product.unit.toDisplayString() + "s"
                                          : product.unit.toDisplayString()}",
                                    ),
                                  ],
                                ),
                                SizedBox(width: 5),
                                InkWell(
                                  onTap:
                                      () =>
                                          _changeQuantity(store, productAd, 1),
                                  child: Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete_outline),
                            onPressed: () => _removeProduct(store, productAd),
                          ),
                          Row(
                            children: [
                              Text(
                                "${oldPrice.toStringAsFixed(2)}€",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondaryFixed,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${totalPrice.toStringAsFixed(2)}€",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Total: ',
                          style: TextStyle(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text:
                              '${_calculateTotal(store).toStringAsFixed(2)} €',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
                    onPressed:
                        productAdEntries.isEmpty
                            ? null
                            : () => setState(() {
                              _isCheckout.updateAll((key, value) => false);
                              _isCheckout[store] = true;
                              _selectedDeliveryMethod[store] ??=
                                  store.preferredDeliveryMethod.length == 1
                                      ? store.preferredDeliveryMethod.first
                                      : null;
                            }),
                    child: Text(
                      "Finalizar Compra",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Store? _getCheckoutStore() {
    try {
      return _isCheckout.entries.firstWhere((e) => e.value == true).key;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutStore = _getCheckoutStore();
    return Scaffold(
      appBar: AppBar(
        title: Text("Carrinho"),
        leading: Builder(
          builder: (context) {
            final checkoutStore = _getCheckoutStore();
            return IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (checkoutStore != null) {
                  setState(() {
                    _isCheckout[checkoutStore] = false;
                    _selectedDeliveryMethod[checkoutStore] = null;
                  });
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            );
          },
        ),
      ),
      body:
          checkoutStore != null
              ? _buildCheckoutForm(checkoutStore)
              : _buildCartView(),
    );
  }
}

class ProductAdFinder {
  final List<AppUser> allUsers;

  ProductAdFinder(this.allUsers);

  ProductAd? findProductAdById(String adId) {
    for (var user in allUsers) {
      if (user is ProducerUser) {
        for (var store in user.stores) {
          final productAd = store.productsAds?.firstWhereOrNull((ad) {
            return ad.id == adId;
          });
          if (productAd != null) return productAd;
        }
      }
    }
    return null;
  }

  Store? findStoreByAdId(String adId) {
    for (var user in allUsers) {
      if (user is ProducerUser) {
        for (var store in user.stores) {
          final exists = store.productsAds?.any((ad) => ad.id == adId) ?? false;
          if (exists) return store;
        }
      }
    }
    return null;
  }
}

class PriceUtils {
  static double calculateDiscountedPrice(
    ProductAd ad,
    double quantity,
    int? promotion,
  ) {
    final pricePerUnit = ad.product.price;
    final discount = promotion ?? 0;

    if (discount > 0) {
      final discountFactor = 1 - (discount / 100);
      return quantity * pricePerUnit * discountFactor;
    }

    return quantity * pricePerUnit;
  }

  static double unitPriceWithDiscount(ProductAd ad, int? promotion) {
    final pricePerUnit = ad.product.price;
    final discount = promotion ?? 0;

    if (discount > 0) {
      return pricePerUnit * (1 - (discount / 100));
    }

    return pricePerUnit;
  }

  static String formatPrice(double price) {
    return "${price.toStringAsFixed(2)} €";
  }
}
