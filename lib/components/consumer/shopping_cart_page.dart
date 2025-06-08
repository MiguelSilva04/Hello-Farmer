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
  late Map<ProductAd, int> productAdQuantities;
  Store? store;
  bool multipleStoresDetected = false;
  late ShoppingCart cart;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<MapEntry<ProductAd, int>> productAdEntries = [];

  @override
  void initState() {
    super.initState();
    cart = (AuthService().currentUser as ConsumerUser).shoppingCart;
    users = AuthService().users;
    finder = ProductAdFinder(users);
    productAdQuantities = {};

    _loadCartProducts();
  }

  void _loadCartProducts() {
    productAdQuantities.clear();
    multipleStoresDetected = false;

    Store? detectedStore;

    for (var map in cart.productsQty ?? []) {
      for (var entry in map.entries) {
        final productId = entry.key;
        final qty = entry.value;

        final productAd = finder.findProductAdById(productId, context);
        final productStore = finder.findStoreByAdId(productId, context);

        if (detectedStore == null) {
          detectedStore = productStore;
        } else if (detectedStore.name != productStore?.name) {
          multipleStoresDetected = true;
          continue;
        }

        if (productAd != null) {
          productAdQuantities[productAd] = qty;
        }
      }
    }

    store = detectedStore;

    productAdEntries = productAdQuantities.entries.toList();

    setState(() {});
  }

  void _removeProduct(ProductAd productAd) {
    final index = productAdEntries.indexWhere(
      (entry) => entry.key == productAd,
    );
    if (index < 0) return;

    final removedEntry = productAdEntries[index];

    productAdQuantities.remove(productAd);
    productAdEntries.removeAt(index);

    _updateCartFromState();

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(removedEntry, index, animation),
      duration: Duration(milliseconds: 300),
    );

    setState(() {});
  }

  void _changeQuantity(ProductAd productAd, int delta) {
    final index = productAdEntries.indexWhere(
      (entry) => entry.key == productAd,
    );
    if (index < 0) return;

    setState(() {
      final currentQty = productAdQuantities[productAd] ?? 0;
      final newQty = currentQty + delta;
      if (newQty <= 0) {
        _removeProduct(productAd);
      } else {
        productAdQuantities[productAd] = newQty;
        productAdEntries[index] = MapEntry(productAd, newQty);
      }
      _updateCartFromState();
    });
  }

  void _updateCartFromState() {
    final List<Map<String, int>> updatedList = [];
    productAdQuantities.forEach((ad, qty) {
      updatedList.add({ad.id: qty});
    });

    cart.productsQty = updatedList;
  }

  double _calculateTotal() {
    double total = 0;
    productAdQuantities.forEach((ad, qty) {
      total += ad.product.price * qty;
    });
    return total;
  }

  Widget _buildItem(
    MapEntry<ProductAd, int> entry,
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
            product.imageUrl.isNotEmpty
                ? Image.asset(
                  product.imageUrl.first,
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
                      const SizedBox(width: 5),
                      Row(
                        children: [
                          Text(
                            qty.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            " ${product.unit.toDisplayString()}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        child: Icon(Icons.add_circle_outline),
                        onTap: () => _changeQuantity(productAd, 1),
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
    if (productAdQuantities.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Carrinho")),
        body: Center(child: Text("Carrinho vazio.")),
      );
    }

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

    if (store == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Carrinho")),
        body: Center(child: Text("Carrinho vazio ou dados inconsistentes.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Carrinho")),
      body: Column(
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
      ),
      bottomNavigationBar: Container(
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Total: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '${_calculateTotal().toStringAsFixed(2)} €',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      letterSpacing: 1.2,
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
                ).colorScheme.primary.withOpacity(0.5),
              ),
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Finalizar compra")));
              },
              child: Text(
                "Finalizar compra",
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
