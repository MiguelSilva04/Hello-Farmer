import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/shopping_cart.dart';

import '../../models/consumer_user.dart';
import '../../models/producer_user.dart';
import '../../models/store.dart';
import 'auth_service.dart';
import 'store_service.dart';

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

  Future<void> loadAllUsers() async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

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

  Future<void> addToCart(ProductAd productAd, double quantity) async {
    await AuthService().addToCart(productAd, quantity);
  }

  Future<void> _loadStoresAndAdsForProducer(ProducerUser producer) async {
    final storeSnapshot =
        await FirebaseFirestore.instance
            .collection('stores')
            .where('ownerId', isEqualTo: producer.id)
            .get();

    producer.stores.clear();

    for (final doc in storeSnapshot.docs) {
      final data = doc.data();

      final store = Store.fromJson({
        ...data,
        'id': doc.id,
        if (data['createdAt'] is Timestamp)
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
        if (data['updatedAt'] is Timestamp)
          'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
      });

      final adSnapshot =
          await FirebaseFirestore.instance
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
              if (adData['createdAt'] is Timestamp)
                'createdAt': (adData['createdAt'] as Timestamp).toDate(),
              if (adData['updatedAt'] is Timestamp)
                'updatedAt': (adData['updatedAt'] as Timestamp).toDate(),
            });
          }).toList();

      store.productsAds = ads;
      producer.stores.add(store);
    }
  }

  Future<void> _loadProducerStoresAndAds() async {
    final storeSnapshot =
        await FirebaseFirestore.instance
            .collection('stores')
            .where('ownerId', isEqualTo: currentUser!.id)
            .get();

    (currentUser as ProducerUser).stores.clear();

    for (final doc in storeSnapshot.docs) {
      final data = doc.data();

      final store = Store.fromJson({
        ...data,
        'id': doc.id,
        if (data['createdAt'] is Timestamp)
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
        if (data['updatedAt'] is Timestamp)
          'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
      });

      final adSnapshot =
          await FirebaseFirestore.instance
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
              if (adData['createdAt'] is Timestamp)
                'createdAt': (adData['createdAt'] as Timestamp).toDate(),
              if (adData['updatedAt'] is Timestamp)
                'updatedAt': (adData['updatedAt'] as Timestamp).toDate(),
            });
          }).toList();

      store.productsAds = ads;
      (currentUser as ProducerUser).stores.add(store);
      notifyListeners();
    }
  }

  Future<AppUser> loadUser() async {
    print("Obtendo utilizador...");
    _currentUser = await AuthService().getCurrentUser();
    print("Utilizador carregado: $_currentUser");

    loadAllUsers();
    StoreService.instance.loadStores();

    if (_currentUser is ProducerUser) {
      print("É produtor");
      await _loadProducerStoresAndAds();
    }

    if (_currentUser is ConsumerUser) {
      print("É consumidor");
      await _loadShoppingCart();
    }

    notifyListeners();
    print("Notificações enviadas");

    return _currentUser!;
  }

  Future<void> _loadShoppingCart() async {
    if (_currentUser is! ConsumerUser) {
      print('Erro: _currentUser não é ConsumerUser');
      return;
    }
    final consumer = _currentUser as ConsumerUser;

    print("Carregando carrinho para: ${consumer.id}");

    final cartQuery =
        await FirebaseFirestore.instance
            .collection('shoppingCarts')
            .where('ownerId', isEqualTo: consumer.id)
            .limit(1)
            .get();

    print("Consulta ao carrinho concluída");

    if (cartQuery.docs.isEmpty) {
      print("Carrinho não encontrado");
      consumer.shoppingCart = ShoppingCart(productsQty: [], totalPrice: 0);
      return;
    }

    final cartDoc = cartQuery.docs.first;
    final data = cartDoc.data();

    final List<ProductRegist> productsQty = [];

    if (data['productsQty'] != null) {
      for (final item in List.from(data['productsQty'])) {
        final productAdId = item['productAdId'];
        final quantity = item['quantity'];

        if (productAdId == null || quantity == null) {
          print("Item inválido no carrinho: $item");
          continue; // Ignora este item
        }

        productsQty.add(
          ProductRegist(productAdId: productAdId, quantity: quantity),
        );
      }
    }

    consumer.shoppingCart = ShoppingCart(productsQty: productsQty);
    print("Carrinho carregado com ${productsQty.length} produtos");

    notifyListeners();
  }

  Future<DocumentReference?> _getCartDocRef(String ownerId) async {
    final cartQuery =
        await FirebaseFirestore.instance
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
  }

  Future<void> removeProduct(String ownerId, String productAdId) async {
    final docRef = await _getCartDocRef(ownerId);
    if (docRef == null) return;

    final cart = await docRef.get();
    final data = cart.data() as Map<String, dynamic>;
    final products = List.from(data['productsQty'] ?? []);

    products.removeWhere((item) => item['productAdId'] == productAdId);
    await docRef.update({'productsQty': products});
  }

  void changeStoreIndex(int index) async {
    if (index >= 0 && index < stores.length) {
      _selectedStoreIndex = index;
      notifyListeners();
    }
  }
}
