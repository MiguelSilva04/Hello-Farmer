import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/models/product_ad.dart';

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

  Future<AppUser> loadUser() async {
    _currentUser = await AuthService().getCurrentUser();

    loadAllUsers();
    StoreService.instance.loadStores();

    if (_currentUser is ProducerUser) {
      await _loadProducerStoresAndAds();
    }

    notifyListeners();

    return _currentUser!;
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

  void changeStoreIndex(int index) async {
    if (index >= 0 && index < stores.length) {
      _selectedStoreIndex = index;
      notifyListeners();
    }
  }
}
