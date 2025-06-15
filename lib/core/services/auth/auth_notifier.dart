import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/shopping_cart.dart';

import '../../models/consumer_user.dart';
import '../../models/producer_user.dart';
import '../../models/store.dart';
import '../../models/order.dart';
import 'auth_service.dart';
import 'store_service.dart';
import 'package:collection/collection.dart';

class AuthNotifier extends ChangeNotifier {
  AppUser? _currentUser;
  int _selectedStoreIndex = 0;

  List<AppUser> _allUsers = [];
  List<AppUser> get allUsers => _allUsers;
  AppUser? get currentUser => _currentUser;
  bool get isProducer => _currentUser is ProducerUser;
  int get selectedStoreIndex => _selectedStoreIndex;
  List<Store> get stores =>
      isProducer ? (currentUser as ProducerUser).stores : [];
  Store? get selectedStore =>
      isProducer && stores.isNotEmpty ? stores[_selectedStoreIndex] : null;

  List<ProducerUser> get producerUsers =>
      _allUsers.whereType<ProducerUser>().toList();

  final fireStore = cf.FirebaseFirestore.instance;

  Future<void> loadAllUsers() async {
    final userSnapshot = await fireStore.collection('users').get();

    _allUsers =
        userSnapshot.docs.map((doc) {
          final data = doc.data();
          final isProducer = data['isProducer'] == true;
          final userId = doc.id;

          if (isProducer) {
            return ProducerUser.fromJson({...data, 'id': userId});
          } else {
            return ConsumerUser.fromJson({...data, 'id': userId});
          }
        }).toList();

    for (final user in _allUsers.whereType<ProducerUser>()) {
      await _loadStoresAndAdsForProducer(user);
    }

    notifyListeners();
  }

  ProductRegist? getExistingProduct(ShoppingCart? cart, String productId) {
    return cart?.productsQty?.firstWhereOrNull(
      (item) => item.productAdId == productId,
    );
  }

  Future<void> publishAd(
    String title,
    String description,
    List<File> images,
    String category,
    double minQty,
    String unit,
    double price,
    int stock,
    String storeId,
    List<String> keywords,
    String? highlight,
  ) async {
    final ad = await AuthService().createAd(
      title,
      description,
      images,
      category,
      minQty,
      unit,
      price,
      stock,
      storeId,
      keywords,
      highlight,
    );

    final store = (currentUser as ProducerUser).stores.firstWhere(
      (s) => s.id == storeId,
    );
    store.productsAds ??= [];
    store.productsAds!.add(ad);
    notifyListeners();
    notifyListeners();
  }

  Future<void> addToCart(ProductAd productAd, double quantity) async {
    await AuthService().addToCart(productAd, quantity);
    final consumer = _currentUser as ConsumerUser;
    final cart = consumer.shoppingCart;
    final productId = productAd.id;

    if (cart == null || cart.productsQty == null) {
      consumer.shoppingCart = ShoppingCart(
        productsQty: [
          ProductRegist(productAdId: productId, quantity: quantity),
        ],
        totalPrice: productAd.product.price * quantity,
      );
    } else {
      final existingProduct = getExistingProduct(cart, productId);

      if (existingProduct != null) {
        existingProduct.quantity += quantity;
      } else {
        cart.productsQty!.add(
          ProductRegist(productAdId: productId, quantity: quantity),
        );
      }

      cart.totalPrice =
          (cart.totalPrice ?? 0.0) + (productAd.product.price * quantity);
    }

    notifyListeners();
  }

  Future<void> _loadStoresAndAdsForProducer(ProducerUser producer) async {
    final storeSnapshot =
        await fireStore
            .collection('stores')
            .where('ownerId', isEqualTo: producer.id)
            .get();

    producer.stores.clear();

    for (final doc in storeSnapshot.docs) {
      final data = doc.data();

      final store = Store.fromJson({
        ...data,
        'id': doc.id,
        if (data['createdAt'] is cf.Timestamp)
          'createdAt': (data['createdAt'] as cf.Timestamp).toDate(),
        if (data['updatedAt'] is cf.Timestamp)
          'updatedAt': (data['updatedAt'] as cf.Timestamp).toDate(),
      });

      final adSnapshot =
          await fireStore
              .collection('stores')
              .doc(store.id)
              .collection('ads')
              .get();

      final ads =
          adSnapshot.docs.map((adDoc) {
            final adData = adDoc.data();
            return ProductAd.fromJson({
              ...adData,
              'id': adDoc.id,
              if (adData['createdAt'] is cf.Timestamp)
                'createdAt': (adData['createdAt'] as cf.Timestamp).toDate(),
              if (adData['updatedAt'] is cf.Timestamp)
                'updatedAt': (adData['updatedAt'] as cf.Timestamp).toDate(),
            });
          }).toList();

      store.productsAds = ads;
      producer.stores.add(store);
    }
  }

  Future<void> _loadProducerStoresAndAds() async {
    final storeSnapshot =
        await fireStore
            .collection('stores')
            .where('ownerId', isEqualTo: currentUser!.id)
            .get();

    (currentUser as ProducerUser).stores.clear();

    for (final doc in storeSnapshot.docs) {
      final data = doc.data();

      final store = Store.fromJson({
        ...data,
        'id': doc.id,
        if (data['createdAt'] is cf.Timestamp)
          'createdAt': (data['createdAt'] as cf.Timestamp).toDate(),
        if (data['updatedAt'] is cf.Timestamp)
          'updatedAt': (data['updatedAt'] as cf.Timestamp).toDate(),
      });

      final adSnapshot =
          await fireStore
              .collection('stores')
              .doc(store.id)
              .collection('ads')
              .get();

      final ads =
          adSnapshot.docs.map((adDoc) {
            final adData = adDoc.data();
            print(adData);
            return ProductAd.fromJson({
              ...adData,
              'id': adDoc.id,
              if (adData['createdAt'] is cf.Timestamp)
                'createdAt': (adData['createdAt'] as cf.Timestamp).toDate(),
              if (adData['updatedAt'] is cf.Timestamp)
                'updatedAt': (adData['updatedAt'] as cf.Timestamp).toDate(),
            });
          }).toList();

      store.productsAds = ads;
      (currentUser as ProducerUser).stores.add(store);
      notifyListeners();
    }
  }

  Future<AppUser> loadUser() async {
    _currentUser = await AuthService().getCurrentUser();

    StoreService.instance.loadStores();

    if (_currentUser is ProducerUser) {
      await _loadProducerStoresAndAds();
    }

    if (_currentUser is ConsumerUser) {
      await _loadShoppingCart();
    }

    notifyListeners();

    return _currentUser!;
  }

  Future<void> _loadShoppingCart() async {
    if (_currentUser is! ConsumerUser) {
      print('Erro: _currentUser não é ConsumerUser');
      return;
    }
    final consumer = _currentUser as ConsumerUser;

    final cartQuery =
        await fireStore
            .collection('shoppingCarts')
            .where('ownerId', isEqualTo: consumer.id)
            .limit(1)
            .get();

    if (cartQuery.docs.isEmpty) {
      consumer.shoppingCart = ShoppingCart(productsQty: [], totalPrice: 0);
      return;
    }

    final cartDoc = cartQuery.docs.first;
    final data = cartDoc.data();

    final List<ProductRegist> productsQty = [];

    if (data['productsQty'] != null) {
      final List<dynamic> rawList = data['productsQty'];

      for (final dynamic rawItem in rawList) {
        final productAdId = rawItem['productAdId'];
        final quantity = rawItem['quantity'];

        if (productAdId == null || quantity == null) {
          print("Item inválido no carrinho: $rawItem");
          continue;
        }

        productsQty.add(
          ProductRegist(productAdId: productAdId, quantity: quantity),
        );
      }
    }

    (_currentUser as ConsumerUser).shoppingCart = ShoppingCart(
      productsQty: productsQty,
    );

    notifyListeners();
  }

  ConsumerUser? getConsumerUserById(String id) {
    final user = allUsers.whereType<ConsumerUser>().firstWhere(
      (u) => u.id == id,
      orElse: () => throw Exception("Usuário não encontrado"),
    );
    return user;
  }

  Future<void> loadOrders() async {
    final orderSnapshot = await fireStore.collection('orders').get();

    for (final doc in orderSnapshot.docs) {
      final data = doc.data();
      final consumerId = data['consumerId'];
      final order = Order.fromJson({...data, 'id': doc.id});

      final consumer = getConsumerUserById(consumerId);

      if (consumer != null) {
        consumer.orders = [];
        consumer.orders!.add(order);
      }
    }

    notifyListeners();
  }

  Future<void> changePersonalDetailsCurrentUser({
    String? firstName,
    String? lastName,
    String? country,
    String? city,
    String? municipality,
    String? phone,
    String? imageUrl,
    String? backgroundImageUrl,
  }) async {
    _currentUser!.firstName = firstName!;
    _currentUser!.lastName = lastName!;
    _currentUser!.country = country!;
    _currentUser!.city = city!;
    _currentUser!.municipality = municipality!;
    _currentUser!.phone = phone!;
    if (imageUrl != null) _currentUser!.imageUrl = imageUrl;
    if (backgroundImageUrl != null)
      _currentUser!.backgroundUrl = backgroundImageUrl;

    notifyListeners();
  }

  Future<cf.DocumentReference?> _getCartDocRef(String ownerId) async {
    final cartQuery =
        await fireStore
            .collection('shoppingCarts')
            .where('ownerId', isEqualTo: ownerId)
            .limit(1)
            .get();

    if (cartQuery.docs.isEmpty) return null;
    return cartQuery.docs.first.reference;
  }

  Future<void> increaseQuantity(String ownerId, String productAdId) async {
    final docRef = await _getCartDocRef(ownerId);
    if (docRef == null) return;

    final cart = await docRef.get();
    final data = cart.data() as Map<String, dynamic>;
    final products = List.from(data['productsQty'] ?? []);

    final index = products.indexWhere(
      (item) => item['productAdId'] == productAdId,
    );
    if (index >= 0) {
      products[index]['quantity'] += 1;
    } else {
      products.add({'productAdId': productAdId, 'quantity': 1});
    }

    await docRef.update({'productsQty': products});

    final cartList = (_currentUser as ConsumerUser).shoppingCart?.productsQty;
    if (cartList != null) {
      final localIndex = cartList.indexWhere(
        (p) => p.productAdId == productAdId,
      );
      if (localIndex >= 0) {
        cartList[localIndex].quantity += 1;
      } else {
        cartList.add(ProductRegist(productAdId: productAdId, quantity: 1));
      }
    }

    notifyListeners();
  }

  Future<void> decreaseQuantity(String ownerId, String productAdId) async {
    final docRef = await _getCartDocRef(ownerId);
    if (docRef == null) return;

    final cart = await docRef.get();
    final data = cart.data() as Map<String, dynamic>;
    final products = List.from(data['productsQty'] ?? []);

    final index = products.indexWhere(
      (item) => item['productAdId'] == productAdId,
    );
    if (index >= 0) {
      final currentQty = products[index]['quantity'];
      if (currentQty <= 1) {
        products.removeAt(index);
      } else {
        products[index]['quantity'] = currentQty - 1;
      }
      await docRef.update({'productsQty': products});
    }

    final cartList = (_currentUser as ConsumerUser).shoppingCart?.productsQty;
    if (cartList != null) {
      final localIndex = cartList.indexWhere(
        (p) => p.productAdId == productAdId,
      );
      if (localIndex >= 0) {
        final currentQty = cartList[localIndex].quantity;
        if (currentQty <= 1) {
          cartList.removeAt(localIndex);
        } else {
          cartList[localIndex].quantity -= 1;
        }
      }
    }

    notifyListeners();
  }

  Future<void> removeProduct(String ownerId, String productAdId) async {
    final docRef = await _getCartDocRef(ownerId);
    if (docRef == null) return;

    final cart = await docRef.get();
    final data = cart.data() as Map<String, dynamic>;
    final products = List.from(data['productsQty'] ?? []);

    products.removeWhere((item) => item['productAdId'] == productAdId);
    await docRef.update({'productsQty': products});

    final cartList = (_currentUser as ConsumerUser).shoppingCart?.productsQty;
    if (cartList != null) {
      cartList.removeWhere((p) => p.productAdId == productAdId);
    }

    notifyListeners();
  }

  Future<void> createOrder({
    required String consumerId,
    required String storeId,
    required String address,
    required String postalCode,
    required String phone,
    required String discountCode,
    required List<Map<String, dynamic>> cartItems,
    required double totalPrice,
  }) async {
    final docRef = fireStore.collection('orders').doc();

    final orderData = {
      'id': docRef.id,
      'consumerId': consumerId,
      'storeId': storeId,
      'address': address,
      "postalCode": postalCode,
      "phone": phone,
      "discountCode": discountCode,
      'status': 'Pendente',
      'createdAt': cf.Timestamp.now(),
      'deliveryDate': cf.Timestamp.fromDate(
        DateTime.now().add(Duration(days: 2)),
      ),
      'items': cartItems,
      'totalPrice': totalPrice,
    };

    await docRef.set(orderData);

    final shoppingCartQuery =
        await fireStore
            .collection('shoppingCarts')
            .where('ownerId', isEqualTo: consumerId)
            .get();

    for (final doc in shoppingCartQuery.docs) {
      await doc.reference.delete();
    }

    (_currentUser as ConsumerUser).shoppingCart?.productsQty?.clear();
    (_currentUser as ConsumerUser).shoppingCart?.totalPrice = 0;

    notifyListeners();
  }

  void changeStoreIndex(int index) async {
    if (index >= 0 && index < stores.length) {
      _selectedStoreIndex = index;
      notifyListeners();
    }
  }

  Future<void> deleteProductAd(String storeId, String productAdId) async {
    final docRef = cf.FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('ads')
        .doc(productAdId);
    await docRef.delete();
    (currentUser as ProducerUser).stores[selectedStoreIndex].productsAds!
        .removeWhere((ad) => ad.id == productAdId);
    notifyListeners();
  }
}
