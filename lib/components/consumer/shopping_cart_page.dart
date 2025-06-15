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
  late Map<ProductAd, double> productAdQuantities;
  Store? store;
  bool multipleStoresDetected = false;
  late ShoppingCart? cart;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<MapEntry<ProductAd, double>> productAdEntries = [];
  late AuthNotifier authNotifier;

  bool _isLoading = false;

  bool _isCheckout = false;
  final _checkoutFormKey = GlobalKey<FormState>();
  String? fullName, address, postalCode, city, phoneNumber, discountCode;

  @override
  void initState() {
    super.initState();
    authNotifier = Provider.of(context, listen: false);
    cart = (authNotifier.currentUser as ConsumerUser).shoppingCart;
    users = AuthService().users;
    finder = ProductAdFinder(users);
    productAdQuantities = {};

    _loadCartProducts();
  }

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  Future<void> sendOrderToFirestore({
    required String consumerId,
    required String storeId,
    required String address,
    required String postalCode,
    required String phone,
    required String discountCode,
    required List<Map<String, dynamic>> cartItems,
    required double totalPrice,
  }) async {
    setState(() => _isLoading = true);
    await authNotifier.createOrder(
      consumerId: consumerId,
      storeId: storeId,
      address: address,
      cartItems: cartItems,
      totalPrice: roundDouble(totalPrice, 2),
      postalCode: postalCode,
      phone: phoneNumber!,
      discountCode: discountCode,
    );
    setState(() => _isLoading = false);
    _loadCartProducts();
  }

  void _loadCartProducts() {
    productAdQuantities.clear();
    multipleStoresDetected = false;

    Store? detectedStore;

    if (cart != null && cart!.productsQty != null)
      cart!.productsQty!.forEach((product) {
        final productAd = finder.findProductAdById(
          product.productAdId,
          context,
        );
        final productStore = finder.findStoreByAdId(
          product.productAdId,
          context,
        );

        if (detectedStore == null) {
          detectedStore = productStore;
        } else if (detectedStore!.name != productStore?.name) {
          multipleStoresDetected = true;
        }

        if (productAd != null) {
          productAdQuantities[productAd] = product.quantity;
        }
      });

    store = detectedStore;

    productAdEntries = productAdQuantities.entries.toList();

    setState(() {});
  }

  void _changeQuantity(ProductAd productAd, int delta) async {
    final consumer = authNotifier.currentUser as ConsumerUser;

    int currentIndex = productAdEntries.indexWhere(
      (entry) => entry.key.id == productAd.id,
    );
    if (currentIndex == -1) return;

    final currentQty = productAdQuantities[productAd]!;
    final newQty = currentQty + delta;

    if (newQty <= 0) {
      _removeProduct(productAd);
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
      productAdQuantities[productAd] = newQty;
      productAdEntries[currentIndex] = MapEntry(productAd, newQty);
    });
  }

  void _removeProduct(ProductAd productAd) async {
    final consumer = authNotifier.currentUser as ConsumerUser;
    final index = productAdEntries.indexWhere(
      (entry) => entry.key.id == productAd.id,
    );
    if (index == -1) return;

    await Provider.of<AuthNotifier>(
      context,
      listen: false,
    ).removeProduct(consumer.id, productAd.id);

    setState(() {
      productAdQuantities.remove(productAd);
      productAdEntries.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) =>
            _buildItem(MapEntry(productAd, 0), index, animation),
        duration: Duration(milliseconds: 300),
      );
    });
  }

  double _calculateTotal() {
    double total = 0;
    productAdQuantities.forEach((ad, qty) {
      total += ad.product.price * qty;
    });
    return total;
  }

  void _submitCheckoutForm() async {
    if (_checkoutFormKey.currentState!.validate()) {
      _checkoutFormKey.currentState!.save();
      setState(() => _isLoading = true);

      final userId = AuthService().currentUser!.id;
      final cartItems =
          cart!.productsQty!
              .map(
                (item) => {
                  'productId': item.productAdId,
                  'quantity': item.quantity,
                },
              )
              .toList();

      await sendOrderToFirestore(
        consumerId: userId,
        storeId: store!.id,
        address: "$address, $postalCode $city",
        cartItems: cartItems,
        totalPrice: _calculateTotal(),
        postalCode: postalCode!,
        phone: phoneNumber!,
        discountCode: discountCode ?? '',
      );

      setState(() {
        _isLoading = false;
        _isCheckout = false;
      });

      _loadCartProducts();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Pedido efetuado com sucesso!")));
      Navigator.of(context).pop();
    }
  }

  Widget _buildCheckoutForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _checkoutFormKey,
        child: ListView(
          children: [
            Text(
              "Finalizar Pedido",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: "Morada de entrega"),
              onSaved: (value) => address = value,
              validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Código Postal"),
              onSaved: (value) => postalCode = value,
              validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              maxLength: 10,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Cidade"),
              onSaved: (value) => city = value,
              validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Telefone"),
              keyboardType: TextInputType.phone,
              onSaved: (value) => phoneNumber = value,
              validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              maxLength: 9,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Código de desconto (opcional)",
              ),
              onSaved: (value) => discountCode = value,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => _isCheckout = false),
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
                      onPressed: _submitCheckoutForm,
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
    return productAdQuantities.isEmpty
        ? Center(child: Text("Carrinho Vazio"))
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Banca: ${store!.name}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: AnimatedList(
                key: _listKey,
                padding: EdgeInsets.all(16),
                initialItemCount: productAdEntries.length,
                itemBuilder: (context, index, animation) {
                  return _buildItem(productAdEntries[index], index, animation);
                },
              ),
            ),
          ],
        );
  }

  Widget _buildItem(
    MapEntry<ProductAd, double> entry,
    int index,
    Animation<double> animation,
  ) {
    final productAd = entry.key;
    final qty = entry.value;
    final product = productAd.product;
    final pricePerProduct = product.price;
    final totalPrice = pricePerProduct * qty;

    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0.0,
      child: Padding(
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Categoria: ${product.category}"),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => _changeQuantity(productAd, -1),
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
                        onTap: () => _changeQuantity(productAd, 1),
                        child: Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () => _removeProduct(productAd),
                ),
                Text(
                  "${totalPrice.toStringAsFixed(2)}€",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (multipleStoresDetected) {
      return Scaffold(
        appBar: AppBar(title: Text("Carrinho")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "O carrinho contém produtos de várias bancas. "
              "Por favor, finalize compras separadamente para cada banca.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Carrinho")),
      body: _isCheckout ? _buildCheckoutForm() : _buildCartView(),
      bottomNavigationBar:
          _isCheckout
              ? null
              : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 22,
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
                            text: '${_calculateTotal().toStringAsFixed(2)} €',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      onPressed:
                          productAdQuantities.isEmpty
                              ? () {}
                              : () => setState(() => _isCheckout = true),
                      child: Text(
                        "Finalizar Compra",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class ProductAdFinder {
  final List<AppUser> allUsers;

  ProductAdFinder(this.allUsers);

  ProductAd? findProductAdById(String adId, BuildContext context) {
    for (var user in allUsers) {
      if (user is ProducerUser) {
        try {
          final productAd = user
              .stores[Provider.of<AuthNotifier>(
                context,
                listen: false,
              ).selectedStoreIndex]
              .productsAds
              ?.firstWhereOrNull((ad) => ad.id == adId);
          if (productAd != null) {
            return productAd;
          }
        } catch (_) {}
      }
    }
    return null;
  }

  Store? findStoreByAdId(String adId, BuildContext context) {
    for (var user in allUsers) {
      if (user is ProducerUser) {
        try {
          final productAd = user
              .stores[Provider.of<AuthNotifier>(
                context,
                listen: false,
              ).selectedStoreIndex]
              .productsAds
              ?.firstWhere((ad) => ad.id == adId);
          if (productAd != null) {
            return user.stores[Provider.of<AuthNotifier>(
              context,
              listen: false,
            ).selectedStoreIndex];
          }
        } catch (_) {}
      }
    }
    return null;
  }
}
