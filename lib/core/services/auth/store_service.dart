import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:harvestly/core/models/store.dart';
import '../../models/order.dart';
import '../../models/product_ad.dart';
import '../../models/review.dart';

class StoreService with ChangeNotifier {
  StoreService._privateConstructor();
  static final StoreService instance = StoreService._privateConstructor();

  final firestore = cf.FirebaseFirestore.instance;

  final Map<String, StreamSubscription> _orderSubscriptions = {};
  StreamSubscription? _storeListener;

  final List<Store> _allStores = [];
  List<Store> get allStores => List.unmodifiable(_allStores);

  Future<void> startStoresListener() async {
    _storeListener?.cancel();

    _storeListener = firestore.collection('stores').snapshots().listen((
      snapshot,
    ) async {
      _allStores.clear();

      for (final doc in snapshot.docs) {
        final storeData = doc.data();
        final storeId = doc.id;

        final store = Store.fromJson({...storeData, 'id': storeId});

        final adsSnapshot =
            await firestore
                .collection('stores')
                .doc(storeId)
                .collection('ads')
                .get();

        final List<ProductAd> ads = [];

        for (final adDoc in adsSnapshot.docs) {
          try {
            final adData = adDoc.data();
            final ad = ProductAd.fromJson(adData);

            final reviewsSnapshot =
                await firestore
                    .collection('stores')
                    .doc(storeId)
                    .collection('ads')
                    .doc(ad.id)
                    .collection('reviews')
                    .get();

            final reviews =
                reviewsSnapshot.docs
                    .map((reviewDoc) => Review.fromJson(reviewDoc.data()))
                    .toList();

            ad.adReviews = reviews;
            ads.add(ad);
          } catch (e) {
            print('Erro ao carregar ad ou reviews: $e');
          }
        }

        store.productsAds = ads;

        _allStores.add(store);
        listenToOrdersForStore(store);
      }

      notifyListeners();
    });
  }

  Future<void> stopStoresListener() async {
    await _storeListener?.cancel();
    _storeListener = null;

    await cancelAllOrderSubscriptions();
    _allStores.clear();
    notifyListeners();
  }

  Future<void> cancelAllOrderSubscriptions() async {
    for (var sub in _orderSubscriptions.values) {
      await sub.cancel();
    }
    _orderSubscriptions.clear();
  }

  void listenToOrdersForStore(Store store) {
    final sub = firestore
        .collection('orders')
        .where('storeId', isEqualTo: store.id)
        .snapshots()
        .listen((snapshot) {
          store.orders =
              snapshot.docs
                  .map((doc) => Order.fromJson({...doc.data(), 'id': doc.id}))
                  .toList();
          notifyListeners();
        });

    _orderSubscriptions[store.id] = sub;
  }

  Future<void> loadStores() async {
    final snapshot = await firestore.collection('stores').get();
    _allStores.clear();

    for (final doc in snapshot.docs) {
      final storeData = doc.data();
      final storeId = doc.id;

      final store = Store.fromJson({...storeData, 'id': storeId});

      final adsSnapshot =
          await firestore
              .collection('stores')
              .doc(storeId)
              .collection('ads')
              .get();

      final List<ProductAd> ads = [];

      for (final adDoc in adsSnapshot.docs) {
        try {
          final adData = adDoc.data();
          final ad = ProductAd.fromJson(adData);

          final reviewsSnapshot =
              await firestore
                  .collection('stores')
                  .doc(storeId)
                  .collection('ads')
                  .doc(ad.id)
                  .collection('reviews')
                  .get();

          final reviews =
              reviewsSnapshot.docs.map((reviewDoc) {
                final review = Review.fromJson(reviewDoc.data());
                return review;
              }).toList();

          ad.adReviews = reviews;
          ads.add(ad);
        } catch (e) {
          print('Erro ao carregar ad ou reviews: $e');
        }
      }

      store.productsAds = ads;

      _allStores.add(store);
    }

    notifyListeners();
  }

  Future<void> clearStores() async {
    await cancelAllOrderSubscriptions();
    _allStores.clear();
    notifyListeners();
  }

  List<Store> getStoresByOwner(String ownerId) {
    final stores =
        _allStores.where((store) => store.ownerId == ownerId).toList();

    for (final store in stores) {
      if (store.orders == null) {
        listenToOrdersForStore(store);
      }
    }

    List<int> idsList = [];
    for (int i = 0; i < stores.length; i++) {
      idsList.add(i);
    }

    return stores;
  }

  Future<void> updateStoreData({
    required String name,
    required String slogan,
    required String description,
    required String address,
    required String city,
    required String municipality,
    required LatLng? coordinates,
    String? profileImageUrl,
    String? backgroundImageUrl,
    required String storeId,
  }) async {
    final storeRef = firestore.collection('stores').doc(storeId);

    await storeRef.update({
      'name': name,
      'subName': slogan,
      'description': description,
      'address': address,
      'city': city,
      'municipality': municipality,
      'coordinates': {
        'latitude': coordinates!.latitude,
        'longitude': coordinates.longitude,
      },
      if (profileImageUrl != null) 'imageUrl': profileImageUrl,
      if (backgroundImageUrl != null) 'backgroundImageUrl': backgroundImageUrl,
    });
  }

  Future<String> updateProfileImage(File file, String storeId) async {
    final ref = FirebaseStorage.instance.ref().child(
      'stores/$storeId/profile.jpg',
    );
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> updateBackgroundImage(File file, String storeId) async {
    final ref = FirebaseStorage.instance.ref().child(
      'stores/$storeId/background.jpg',
    );
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> editProductAd(ProductAd ad, String storeId, bool stockChanged) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      final docRef = firestore
          .collection('stores')
          .doc(storeId)
          .collection('ads')
          .doc(ad.id);

      final List<String> imageUrls = [];

      for (int i = 0; i < ad.product.imageUrls.length; i++) {
        final image = ad.product.imageUrls[i];

        if (image.startsWith('http')) {
          imageUrls.add(image);
        } else {
          final imageFile = File(image);
          final imageRef = _storage.ref().child(
            'stores/$storeId/ads/${ad.id}/image_$i.jpg',
          );
          final uploadTask = await imageRef.putFile(imageFile);
          final imageUrl = await uploadTask.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }
      }

      await docRef.set({
        'title': ad.product.name,
        'description': ad.description,
        'imageUrls': imageUrls,
        'category': ad.product.category,
        'minQty': ad.product.minAmount,
        'unit': ad.product.unit.name,
        'price': ad.product.price,
        'stock': ad.product.stock,
        'visibility': ad.visibility,
        'highlightType': ad.highlightType?.name,
        'highlightDate': ad.highlightDate,
        'keywords': ad.keywords,
        'updatedAt': cf.FieldValue.serverTimestamp(),
        if (stockChanged) 'stockChangedDate': cf.FieldValue.serverTimestamp(),
      }, cf.SetOptions(merge: true));
    } catch (e) {
      print("Erro ao editar anúncio: $e");
      rethrow;
    }
  }
}
