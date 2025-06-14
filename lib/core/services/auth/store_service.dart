import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:harvestly/core/models/store.dart';

import '../../models/order.dart';
import '../../models/product_ad.dart';

class StoreService with ChangeNotifier {
  StoreService._privateConstructor();

  static final StoreService instance = StoreService._privateConstructor();

  final List<Store> _allStores = [];

  List<Store> get allStores => List.unmodifiable(_allStores);

  final firestore = cf.FirebaseFirestore.instance;

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

      final ads =
          adsSnapshot.docs.map((adDoc) {
            return ProductAd.fromJson(adDoc.data());
          }).toList();

      store.productsAds = ads;

      _allStores.add(store);
    }

    notifyListeners();
  }

  List<Store> getStoresByOwner(String ownerId) {
    final stores =
        _allStores.where((store) => store.ownerId == ownerId).toList();

    for (final store in stores) {
      _loadOrdersForStore(store);
    }

    return stores;
  }

  Future<void> _loadOrdersForStore(Store store) async {
    final orderSnapshot =
        await firestore
            .collection('orders')
            .where('storeId', isEqualTo: store.id)
            .get();

    store.orders =
        orderSnapshot.docs.map((doc) {
          final data = doc.data();
          print(data);
          return Order.fromJson({...data, 'id': doc.id});
        }).toList();

    notifyListeners();
  }
}
