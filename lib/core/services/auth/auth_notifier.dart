import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/shopping_cart.dart';
import 'package:harvestly/core/models/user_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../components/producer/manageSection/manageProductsSection.dart';
import '../../models/consumer_user.dart';
import '../../models/producer_user.dart';
import '../../models/review.dart';
import '../../models/store.dart';
import '../../models/order.dart';
import 'auth_service.dart';
import 'store_service.dart';
import 'package:collection/collection.dart';

class AuthNotifier extends ChangeNotifier {
  AppUser? _currentUser;
  int? _selectedStoreIndex = null;
  bool _isOrdersLoading = false;
  List<AppUser> _allUsers = [];
  List<AppUser> get allUsers => _allUsers;
  AppUser? get currentUser => _currentUser;
  bool get isProducer => _currentUser is ProducerUser;
  int? get selectedStoreIndex => _selectedStoreIndex;
  List<Store> get stores =>
      isProducer ? (currentUser as ProducerUser).stores : [];
  Store? get selectedStore =>
      isProducer && stores.isNotEmpty ? stores[_selectedStoreIndex!] : null;
  final StreamController<List<ProductAd>> _productAdsController =
      StreamController<List<ProductAd>>.broadcast();
  List<String> favorites = [];

  Stream<List<ProductAd>> get productAdsStream => _productAdsController.stream;

  List<ProducerUser> get producerUsers =>
      _allUsers.whereType<ProducerUser>().toList();

  final fireStore = cf.FirebaseFirestore.instance;
  bool get isOrdersLoading => _isOrdersLoading;

  void setLocalSelectedStoreIndex(int? index) {
    _selectedStoreIndex = index;
    notifyListeners();
  }

  Future<void> updateSelectedStoreIndex() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedStoreIndex = prefs.getInt("selectedStoreIndex");
    notifyListeners();
  }

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

  void setSelectedStoreIndex(int index) {
    if (index >= 0 && index < stores.length) {
      _selectedStoreIndex = index;
      notifyListeners();
    }
  }

  void addStore(store) {
    (currentUser! as ProducerUser).stores.add(store);
    stores.add(store);
    notifyListeners();
  }

  Future<List<Review>> getReviewsForAd(String storeId, String adId) async {
    final snapshot =
        await fireStore
            .collection('stores')
            .doc(storeId)
            .collection('ads')
            .doc(adId)
            .collection('reviews')
            .get();

    return snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList();
  }

  Stream<List<ProductAd>> getAllProductAdsStream() {
    final storeCollection = fireStore.collection('stores');

    return storeCollection.snapshots().asyncMap((storeSnapshot) async {
      final List<Future<List<ProductAd>>> adsFutures = [];

      for (var storeDoc in storeSnapshot.docs) {
        final productAdsRef = storeDoc.reference.collection('ads');

        final adsFuture = productAdsRef.snapshots().first.then((
          adsSnapshot,
        ) async {
          final List<ProductAd> productAds = [];

          for (var adDoc in adsSnapshot.docs) {
            try {
              final adData = adDoc.data();
              final ProductAd ad = ProductAd.fromJson(adData);

              final reviewsSnapshot =
                  await adDoc.reference.collection('reviews').get();

              final reviews =
                  reviewsSnapshot.docs
                      .map((reviewDoc) => Review.fromJson(reviewDoc.data()))
                      .toList();

              ad.adReviews = reviews;
              productAds.add(ad);
            } catch (e) {
              print("Erro ao carregar anúncio ou reviews: $e");
            }
          }

          return productAds;
        });

        adsFutures.add(adsFuture);
      }

      final allAdsLists = await Future.wait(adsFutures);
      return allAdsLists.expand((ads) => ads).toList();
    });
  }

  Future<List<ProductAd>> fetchAllProductAdsOnce() async {
    final storeCollection = fireStore.collection('stores');
    final storeSnapshot = await storeCollection.get();

    final List<Future<List<ProductAd>>> adsFutures = [];

    for (var storeDoc in storeSnapshot.docs) {
      final productAdsRef = storeDoc.reference.collection('ads');

      final adsFuture = productAdsRef.get().then((adsSnapshot) async {
        final List<ProductAd> productAds = [];

        for (var adDoc in adsSnapshot.docs) {
          try {
            final adData = adDoc.data();
            final ProductAd ad = ProductAd.fromJson(adData);

            final reviewsSnapshot =
                await adDoc.reference.collection('reviews').get();

            final reviews =
                reviewsSnapshot.docs
                    .map((reviewDoc) => Review.fromJson(reviewDoc.data()))
                    .toList();

            ad.adReviews = reviews;
            productAds.add(ad);
          } catch (e) {
            print("Erro ao carregar anúncio ou reviews: $e");
          }
        }

        return productAds;
      });

      adsFutures.add(adsFuture);
    }

    final allAdsLists = await Future.wait(adsFutures);
    return allAdsLists.expand((ads) => ads).toList();
  }

  Future<void> refreshProductAds() async {
    final ads = await fetchAllProductAdsOnce();
    _productAdsController.add(ads);
  }

  Stream<Order> orderStream(String orderId) {
    return fireStore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((docSnap) => Order.fromMap(docSnap.data()!));
  }

  Stream<List<Order>> consumerOrdersStream(String consumerId) {
    return fireStore
        .collection('orders')
        .where('consumerId', isEqualTo: consumerId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return Order.fromJson(data);
              }).toList(),
        );
  }

  Stream<List<Order>> storeOrdersStream(String storeId) {
    return fireStore
        .collection('orders')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return Order.fromJson(data);
              }).toList(),
        );
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
  }

  Future<void> submitNewReview(
    String adId,
    double rating,
    String description,
    String? replyTo,
  ) async {
    Store? curStore = producerUsers
        .expand((producer) => producer.stores)
        .firstWhereOrNull(
          (store) => store.productsAds?.any((ad) => ad.id == adId) ?? false,
        );

    final review = await AuthService().submitNewReview(
      curStore!.id,
      adId,
      rating,
      description,
      currentUser!.id,
      replyTo,
    );
    curStore.storeReviews!.add(review);
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

    await StoreService.instance.loadStores();

    if (_currentUser is ProducerUser) {
      await _loadProducerStoresAndAds();
      final prefs = await SharedPreferences.getInstance();
      final storedIndex = prefs.getInt("selectedStoreIndex");

      if (storedIndex != null &&
          storedIndex >= 0 &&
          storedIndex < (currentUser as ProducerUser).stores.length) {
        setSelectedStoreIndex(storedIndex);
      } else if ((currentUser as ProducerUser).stores.isNotEmpty) {
        setSelectedStoreIndex(0);
        await saveSelectedStoreIndex(0);
      }
    }

    if (_currentUser is ConsumerUser) {
      await _loadShoppingCart();
      favorites = await AuthService().getUserFavorites(_currentUser!.id);
    }

    notifyListeners();

    return _currentUser!;
  }

  Future<void> saveSelectedStoreIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedStoreIndex', index);
    setSelectedStoreIndex(prefs.getInt("selectedStoreIndex")!);
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

  Future<void> changeProductStockOrPrice(
    String storeId,
    ProductAd productAd,
    ManageViewMode mode,
  ) async {
    await fireStore
        .collection('stores')
        .doc(storeId)
        .collection('ads')
        .doc(productAd.id)
        .update({
          mode == ManageViewMode.stock ? 'stock' : 'price':
              mode == ManageViewMode.stock
                  ? productAd.product.stock
                  : productAd.product.price,
        });
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
    required DeliveryMethod deliveryMethod,
  }) async {
    final docRef = fireStore.collection('orders').doc();

    final orderData = {
      'id': docRef.id,
      'consumerId': consumerId,
      'storeId': storeId,
      'address': address,
      'postalCode': postalCode,
      'phone': phone,
      'discountCode': discountCode,
      'status': 'Pendente',
      'createdAt': cf.Timestamp.now(),
      'deliveryDate': cf.Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 2)),
      ),
      'items': cartItems,
      'totalPrice': totalPrice,
      'deliveryMethod': deliveryMethod.toDisplayString(),
    };

    await docRef.set(orderData);

    for (final item in cartItems) {
      final productId = item['productId'] as String;
      final quantityOrdered = item['quantity'] as double;

      final adRef = fireStore
          .collection('stores')
          .doc(storeId)
          .collection('ads')
          .doc(productId);

      await fireStore.runTransaction((transaction) async {
        final adSnapshot = await transaction.get(adRef);

        if (adSnapshot.exists) {
          final data = adSnapshot.data();
          final currentStock = (data?['stock'] as int?) ?? 0;
          final newStock = (currentStock - quantityOrdered).clamp(
            0,
            currentStock,
          );

          transaction.update(adRef, {'stock': newStock});
        }
      });
    }

    final shoppingCartQuery =
        await fireStore
            .collection('shoppingCarts')
            .where('ownerId', isEqualTo: consumerId)
            .get();

    for (final doc in shoppingCartQuery.docs) {
      await doc.reference.delete();
    }

    final shoppingCart = (_currentUser as ConsumerUser).shoppingCart;
    shoppingCart?.productsQty?.clear();
    shoppingCart?.totalPrice = 0;

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
    (currentUser as ProducerUser).stores[selectedStoreIndex!].productsAds!
        .removeWhere((ad) => ad.id == productAdId);
    notifyListeners();
  }

  Future<void> changeOrderState(String orderId, OrderState state) async {
    await AuthService().changeOrderState(orderId, state);
    (currentUser as ProducerUser).stores[selectedStoreIndex!].orders!
        .where((o) => o.id == orderId)
        .first
        .changeState(state);
    notifyListeners();
  }

  Future<void> addStoreVisit(String storeId) async {
    await AuthService().addStoreVisit(storeId, currentUser!.id);
    producerUsers.forEach((p) {
      p.stores.forEach((s) {
        if (s.id == storeId) {
          s.viewsByUserDateTime!.add(
            UserView(date: DateTime.now(), user: currentUser!.id),
          );
        }
      });
    });
    notifyListeners();
  }

  Future<void> addAdVisit(String storeId, String adId) async {
    await AuthService().addAdVisit(storeId, adId, currentUser!.id);
    producerUsers.forEach((p) {
      p.stores.forEach((s) {
        if (s.productsAds!.isNotEmpty) {}
        s.productsAds!.forEach((a) {
          if (a.id == adId) {
            a.viewsByUserDateTime?.add(
              UserView(date: DateTime.now(), user: currentUser!.id),
            );
          }
        });
      });
    });
    notifyListeners();
  }

  Future<void> addFavorite(String adId) async {
    if (_currentUser == null || _currentUser is! ConsumerUser) return;

    if (!favorites.contains(adId)) {
      favorites.add(adId);
      notifyListeners();
      await AuthService().addToFavorites(_currentUser!.id, adId);
    }
  }

  Future<void> removeFavorite(String adId) async {
    if (_currentUser == null || _currentUser is! ConsumerUser) return;

    if (favorites.contains(adId)) {
      favorites.remove(adId);
      notifyListeners();
      await AuthService().removeFromFavorites(_currentUser!.id, adId);
    }
  }

  bool isFavorite(String adId) {
    return favorites.contains(adId);
  }

  Future<void> toggleFavorite(String adId) async {
    if (isFavorite(adId)) {
      await removeFavorite(adId);
    } else {
      await addFavorite(adId);
    }
  }
}
