import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvestly/core/models/store.dart';

import '../../models/product_ad.dart';

class StoreService with ChangeNotifier {
  StoreService._privateConstructor();

  static final StoreService instance = StoreService._privateConstructor();

  final List<Store> _allStores = [];

  List<Store> get allStores => List.unmodifiable(_allStores);

  Future<void> loadStores() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('stores').get();

    _allStores.clear();

    for (final doc in snapshot.docs) {
      final storeData = doc.data();
      final storeId = doc.id;

      final store = Store.fromJson({...storeData, 'id': storeId});

      final adsSnapshot =
          await FirebaseFirestore.instance
              .collection('stores')
              .doc(storeId)
              .collection('ads')
              .get();

      final ads =
          adsSnapshot.docs.map((adDoc) {
            print(adDoc.data());
            return ProductAd.fromJson(adDoc.data());
          }).toList();

      store.productsAds = ads;

      _allStores.add(store);

      print('Store: ${store.name} tem ads? ${ads.length}');
    }

    notifyListeners();
  }

  List<Store> getStoresByOwner(String ownerId) {
    return _allStores.where((store) => store.ownerId == ownerId).toList();
  }
}
