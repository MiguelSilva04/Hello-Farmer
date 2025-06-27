import 'dart:io';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../models/consumer_user.dart';
import '../../models/offer.dart';
import '../../models/order.dart';
import '../../models/producer_user.dart';
import '../../models/product_ad.dart';
import '../../models/review.dart';
import '../../models/store.dart';
import '../chat/chat_list_notifier.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    listenToUserChanges();
  }
  static bool? _isLoggingIn;
  static bool? _isProducer;
  static AppUser? _currentUser;
  static final List<AppUser> _users = [];
  static StreamSubscription? _userChangesSubscription;
  static List<Store> _myStores = [];
  static StreamSubscription? _storesSubscription;
  static final _myStoresController = StreamController<List<Store>>.broadcast();
  Stream<List<Store>> get myStoresStream => _myStoresController.stream;
  List<Store> get myStores => _myStores;
  final StreamController<AppUser?> _userController =
      StreamController.broadcast();
  final fireStore = FirebaseFirestore.instance;
  Stream<AppUser?> get userChanges => _userController.stream;
  static final _userStream = Stream<AppUser?>.multi((controller) async {
    final authChanges = FirebaseAuth.instance.authStateChanges();

    await for (final user in authChanges) {
      if (user == null) {
        _currentUser = null;
        controller.add(null);
      } else {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (doc.exists) {
          final data = doc.data()!;
          if (data['isProducer'] == true) {
            final producer = ProducerUser.fromJson({...data, 'id': user.uid});

            final storeSnapshot =
                await FirebaseFirestore.instance
                    .collection('stores')
                    .where('ownerId', isEqualTo: user.uid)
                    .get();

            producer.stores.clear();
            for (var doc in storeSnapshot.docs) {
              final data = doc.data();
              final store = Store.fromJson({
                ...data,
                'id': doc.id,
                if (data['createdAt'] is Timestamp)
                  'createdAt': (data['createdAt'] as Timestamp).toDate(),
                if (data['updatedAt'] is Timestamp)
                  'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
              });
              producer.stores.add(store);
            }

            _currentUser = producer;
          } else {
            _currentUser = ConsumerUser.fromJson({...data, 'id': user.uid});
          }
        } else {
          _currentUser = _toAppUser(user);
        }

        controller.add(_currentUser);
      }
    }
  });

  Future<void> registLog() async {
    final userDoc = fireStore.collection('users').doc(currentUser!.id);
    await userDoc.update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setUserOnlineStatus(String userId, bool isOnline) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isOnline': isOnline,
    });
  }

  Future<Map<String, dynamic>?> getCurrentUserData(String userId) async {
    final querySnapshot =
        await fireStore
            .collection('stores')
            .where('ownerId', isEqualTo: userId)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return null;
  }

  void listenToMyStores() {
    if (_currentUser is ProducerUser) {
      _storesSubscription?.cancel();
      _storesSubscription = fireStore
          .collection('stores')
          .where('ownerId', isEqualTo: _currentUser!.id)
          .snapshots()
          .listen((snapshot) {
            _myStores =
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  return Store.fromJson({
                    ...data,
                    'id': doc.id,
                    if (data['createdAt'] is Timestamp)
                      'createdAt': (data['createdAt'] as Timestamp).toDate(),
                    if (data['updatedAt'] is Timestamp)
                      'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
                  });
                }).toList();

            _myStoresController.add(_myStores);
          });
    }
  }

  static Store? _myStore;

  Future<AppUser?> initializeAndGetUser() async {
    final user = await getCurrentUser();

    if (user is ProducerUser) {
      final completer = Completer<void>();

      fireStore
          .collection('stores')
          .where('ownerId', isEqualTo: user.id)
          .get()
          .then((snapshot) {
            user.stores.clear();
            for (var doc in snapshot.docs) {
              final data = doc.data();
              final store = Store.fromJson({
                ...data,
                'id': doc.id,
                if (data['createdAt'] is Timestamp)
                  'createdAt': (data['createdAt'] as Timestamp).toDate(),
                if (data['updatedAt'] is Timestamp)
                  'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
              });
              user.stores.add(store);
            }
            completer.complete();
          });

      await completer.future;
    }

    return user;
  }

  Future<AppUser?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    return await _userStream.firstWhere(
      (user) => user != null || FirebaseAuth.instance.currentUser == null,
    );
  }

  Stream<List<Store>> getCurrentUserStoresStream(String userId) {
    return fireStore
        .collection('stores')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          final stores = await Future.wait(
            snapshot.docs.map((doc) async {
              final store = Store.fromMap(doc.data(), doc.id);

              final adsSnapshot =
                  await fireStore
                      .collection('stores')
                      .doc(doc.id)
                      .collection('ads')
                      .get();

              store.productsAds = await Future.wait(
                adsSnapshot.docs.map((adDoc) async {
                  final productAd = ProductAd.fromJson(adDoc.data());

                  final reviewsSnapshot =
                      await fireStore
                          .collection('stores')
                          .doc(doc.id)
                          .collection('ads')
                          .doc(adDoc.id)
                          .collection('reviews')
                          .get();

                  productAd.adReviews =
                      reviewsSnapshot.docs
                          .map((reviewDoc) => Review.fromJson(reviewDoc.data()))
                          .toList();

                  return productAd;
                }),
              );

              return store;
            }),
          );

          return stores;
        });
  }

  void listenToUserChanges() {
    _userChangesSubscription?.cancel();
    _userChangesSubscription = FirebaseAuth.instance.authStateChanges().listen((
      firebaseUser,
    ) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _userController.add(null);
        return;
      }

      final doc =
          await fireStore.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        if (data['isProducer'] == true) {
          final producer = ProducerUser.fromJson({
            ...data,
            'id': firebaseUser.uid,
          });

          final storeSnapshot =
              await fireStore
                  .collection('stores')
                  .where('ownerId', isEqualTo: firebaseUser.uid)
                  .get();

          producer.stores.clear();
          for (var doc in storeSnapshot.docs) {
            final data = doc.data();
            final store = Store.fromJson({
              ...data,
              'id': doc.id,
              if (data['createdAt'] is Timestamp)
                'createdAt': (data['createdAt'] as Timestamp).toDate(),
              if (data['updatedAt'] is Timestamp)
                'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
            });
            producer.stores.add(store);
          }

          _currentUser = producer;
        } else {
          _currentUser = ConsumerUser.fromJson({
            ...data,
            'id': firebaseUser.uid,
          });
        }
      } else {
        _currentUser = _toAppUser(firebaseUser);
      }

      _userController.add(_currentUser);
    });
  }

  List<AppUser> get users => _users;

  bool get isLoggingIn => _isLoggingIn ?? false;

  Store getMyStore() => _myStore!;

  void setProducerState(bool state) => _isProducer = state;

  void setLoggingInState(bool state) => _isLoggingIn = state;

  AppUser? get currentUser {
    return _currentUser;
  }

  Future<void> signup(
    String firstName,
    String lastName,
    String email,
    String password,
    File? image,
    String phone,
    String recoveryEmail,
    String dateOfBirth,
    String country,
    String city,
    String municipality,
    List<Offer>? offers,
  ) async {
    final signup = await Firebase.initializeApp(
      name: 'userSignup',
      options: Firebase.app().options,
    );

    final auth = FirebaseAuth.instanceFor(app: signup);

    UserCredential credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      final imageName = '${credential.user!.uid}_profile.jpg';
      final imageUrl = await _uploadUserImage(image, imageName);

      final fullName = '$firstName $lastName';
      await credential.user?.updateDisplayName(fullName);
      await credential.user?.updatePhotoURL(imageUrl);

      await login(email, password, "Normal");

      _currentUser = _toAppUser(
        credential.user!,
        firstName,
        lastName,
        phone,
        recoveryEmail,
        imageUrl,
        dateOfBirth,
        _isProducer ?? false,
        country,
        city,
        municipality,
        offers,
      );
      await _saveAppUser(_currentUser!);

      final store = fireStore;
      final docRef = store.collection('users').doc(credential.user!.uid);
      await docRef.update({'firstName': firstName, 'lastName': lastName});
    }

    await signup.delete();
  }

  Future<void> login(String email, String password, String typeOfLogin) async {
    if (typeOfLogin == "Normal")
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    else if (typeOfLogin == "Google")
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      } on Exception catch (e) {
        print('exception->$e');
      }
    else if (typeOfLogin == "Facebook") {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    }
    ChatListNotifier.instance.listenToChats();
  }

  Future<void> logout() async {
    if (_currentUser == null) return;
    await _userChangesSubscription?.cancel();
    _userChangesSubscription = null;

    await _storesSubscription?.cancel();
    _storesSubscription = null;

    await _myStoresController.close();

    _currentUser = null;
    _users.clear();
    _myStores = [];
    _isLoggingIn = null;
    _isProducer = null;

    await FirebaseAuth.instance.signOut();
  }

  Future<void> recoverPassword(String email) async {
    final auth = FirebaseAuth.instance;
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<String> updateProfileImage(File? profileImage) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "";

    if (profileImage != null) {
      final profileImageName = '${user.uid}_profile.jpg';
      final profileImageUrl = await _uploadUserImage(
        profileImage,
        profileImageName,
      );
      await user.updatePhotoURL(profileImageUrl);
      _currentUser!.imageUrl = profileImageUrl!;

      final store = fireStore;
      final docRef = store.collection('users').doc(user.uid);
      await docRef.update({'imageUrl': profileImageUrl});
      return profileImageUrl;
    }
    return "";
  }

  Future<String> updateBackgroundImage(File? backgroundImage) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) "";

    if (backgroundImage != null) {
      final backgroundImageName = '${user!.uid}_background.jpg';
      final backgroundImageUrl = await _uploadUserImage(
        backgroundImage,
        backgroundImageName,
      );
      _currentUser!.backgroundUrl = backgroundImageUrl;

      final store = fireStore;
      final docRef = store.collection('users').doc(user.uid);
      await docRef.update({'backgroundImageUrl': backgroundImageUrl});
      return backgroundImageUrl!;
    }
    return "";
  }

  Future<String?> _uploadUserImage(File? image, String imageName) async {
    if (image == null) return null;

    final storage = FirebaseStorage.instance;
    final imageRef = storage.ref().child('user_images').child(imageName);
    await imageRef.putFile(image);
    return await imageRef.getDownloadURL();
  }

  Future<void> updateSingleUserField({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? aboutMe,
    String? dateOfBirth,
    String? recoveryEmail,
    String? country,
    String? city,
    String? municipality,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final store = fireStore;
    final docRef = store.collection('users').doc(user.uid);

    if (firstName != null) {
      await user.updateDisplayName(
        "${firstName} ${lastName ?? _currentUser?.lastName ?? ''}",
      );
      await docRef.update({'firstName': firstName});
      _currentUser!.firstName = firstName;
    }

    if (lastName != null) {
      await user.updateDisplayName(
        "${firstName ?? _currentUser?.firstName ?? ''} ${lastName}",
      );
      await docRef.update({'lastName': lastName});
      _currentUser!.lastName = lastName;
    }

    if (email != null) {
      try {
        await user.verifyBeforeUpdateEmail(email);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw Exception('Please re-authenticate to update your email.');
        } else {
          rethrow;
        }
      }
    }

    if (phone != null) {
      await docRef.update({'phone': phone});
      _currentUser!.phone = phone;
    }

    if (aboutMe != null) {
      await docRef.update({'aboutMe': aboutMe});
      _currentUser!.aboutMe = aboutMe;
    }
    if (dateOfBirth != null) {
      await docRef.update({'dateOfBirth': dateOfBirth});
      _currentUser!.dateOfBirth = dateOfBirth;
    }
    if (recoveryEmail != null) {
      await docRef.update({'recoveryEmail': recoveryEmail});
      _currentUser!.recoveryEmail = recoveryEmail;
    }
    if (country != null) {
      await docRef.update({'country': country});
      _currentUser!.country = country;
    }
    if (city != null) {
      await docRef.update({'city': city});
      _currentUser!.city = city;
    }
    if (municipality != null) {
      await docRef.update({'municipality': municipality});
      _currentUser!.municipality = municipality;
    }
  }

  Future<void> syncEmailWithFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final store = fireStore;
    final docRef = store.collection('users').doc(user.uid);

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final firestoreEmail = docSnapshot.data()?['email'];
        final authEmail = user.email;

        if (firestoreEmail != authEmail) {
          await docRef.update({'email': authEmail});
        }
      }
    } catch (e) {
      print("Erro ao sincronizar email com Firestore: $e");
    }
  }

  Future<void> _saveAppUser(AppUser user) async {
    final store = fireStore;
    final docRef = store.collection('users').doc(user.id);

    return docRef.set({
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'phone': user.phone,
      'recoveryEmail': user.recoveryEmail,
      'imageUrl': user.imageUrl,
      'dateOfBirth': user.dateOfBirth,
      'isProducer': user.isProducer,
      'aboutMe': user.aboutMe,
      'backgroundImageUrl': user.backgroundUrl,
      'country': user.country,
      'city': user.city,
      'municipality': user.municipality,
    });
  }

  static AppUser _toAppUser(
    User user, [
    String? firstName,
    String? lastName,
    String? phone,
    String? recoveryEmail,
    String? imageUrl,
    String? dateOfBirth,
    bool? isProducer,
    String? country,
    String? city,
    String? municipality,
    List<Offer>? offers,
  ]) {
    final bool producer = isProducer ?? false;
    if (producer) {
      return ProducerUser(
        id: user.uid,
        email: user.email!,
        firstName:
            firstName ??
            user.displayName?.split(' ')[0] ??
            user.email!.split('@')[0],
        lastName:
            lastName ??
            (((user.displayName?.split(' ').length ?? 0) > 1)
                ? user.displayName?.split(' ')[1]
                : "") ??
            "",
        isProducer: true,
        phone: phone ?? '',
        imageUrl: imageUrl ?? user.photoURL ?? 'assets/images/avatar.png',
        recoveryEmail: recoveryEmail ?? '',
        dateOfBirth: dateOfBirth ?? '',
        baskets: [],
        country: country ?? '',
        city: city ?? '',
        municipality: municipality ?? "",
      );
    } else {
      return ConsumerUser(
        id: user.uid,
        email: user.email!,
        firstName:
            firstName ??
            user.displayName?.split(' ')[0] ??
            user.email!.split('@')[0],
        lastName:
            lastName ??
            ((user.displayName?.split(' ').length ?? 0) > 1
                ? user.displayName?.split(' ')[1]
                : "") ??
            "",
        isProducer: false,
        phone: phone ?? '',
        imageUrl: imageUrl ?? user.photoURL ?? 'assets/images/avatar.png',
        recoveryEmail: recoveryEmail ?? '',
        dateOfBirth: dateOfBirth ?? '',
        country: country ?? '',
        city: city ?? '',
        municipality: municipality ?? '',
        offers: offers ?? [],
      );
    }
  }

  Future<Store> addStore({
    required String name,
    required String subName,
    required String description,
    required String city,
    required String municipality,
    required String address,
    required File imageFile,
    required File backgroundImageFile,
    required List<String> deliveryMethods,
    required LatLng coordinates,
    required String billingAddress,
  }) async {
    final FirebaseFirestore _firestore = fireStore;
    final FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      final docRef = _firestore.collection('stores').doc();
      final storeId = docRef.id;

      final imageRef = _storage.ref().child('stores/$storeId/image.jpg');
      final imageUploadTask = await imageRef.putFile(imageFile);
      final imageUrl = await imageUploadTask.ref.getDownloadURL();

      final bgRef = _storage.ref().child('stores/$storeId/background.jpg');
      final bgUploadTask = await bgRef.putFile(backgroundImageFile);
      final backgroundImageUrl = await bgUploadTask.ref.getDownloadURL();
      final dateTime = Timestamp.now();

      final querySnapshot =
          await _firestore
              .collection('stores')
              .where('ownerId', isEqualTo: currentUser!.id)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;

        await docRef.update({'billingAddress': billingAddress});
      } else {
        print('Nenhuma loja encontrada para este ownerId.');
      }

      await _firestore.collection('stores').doc(storeId).set({
        'id': storeId,
        'ownerId': currentUser!.id,
        'name': name,
        'subName': subName,
        'description': description,
        'city': city,
        'municipality': municipality,
        'address': address,
        'imageUrl': imageUrl,
        'backgroundImageUrl': backgroundImageUrl,
        'deliveryMethods': deliveryMethods,
        'coordinates': {
          'latitude': coordinates.latitude,
          'longitude': coordinates.longitude,
        },
        'createdAt': dateTime,
      });
      final store = Store.fromJson({
        'id': storeId,
        'ownerId': currentUser!.id,
        'name': name,
        'subName': subName,
        'description': description,
        'city': city,
        'municipality': municipality,
        'address': address,
        'imageUrl': imageUrl,
        'backgroundImageUrl': backgroundImageUrl,
        'deliveryMethods': deliveryMethods,
        'coordinates': {
          'latitude': coordinates.latitude,
          'longitude': coordinates.longitude,
        },
        'createdAt': dateTime.toDate(),
      });

      return store;
    } catch (e) {
      print("Erro ao criar store: $e");
      rethrow;
    }
  }

  Future<ProductAd> createAd(
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
    final FirebaseFirestore _firestore = fireStore;
    final FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      final docRef =
          _firestore.collection('stores').doc(storeId).collection('ads').doc();

      final String adId = docRef.id;
      final List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        final imageRef = _storage.ref().child(
          'stores/$storeId/ads/$adId/image_$i.jpg',
        );
        final uploadTask = await imageRef.putFile(images[i]);
        final imageUrl = await uploadTask.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      await docRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'stockChangedDate': FieldValue.serverTimestamp(),
        'id': adId,
        'title': title,
        'description': description,
        'imageUrls': imageUrls,
        'category': category,
        'minQty': minQty,
        'unit': unit,
        'price': price,
        'stock': stock,
        'storeId': storeId,
        'visibility': true,
        'keywords': keywords,
        'highlightType': highlight ?? '',
      });
      final adSnap = await docRef.get();

      final productAd = ProductAd.fromJson(adSnap.data()!);
      return productAd;
    } catch (e) {
      print("Erro ao publicar anúncio: $e");
      rethrow;
    }
  }

  Future<Review> submitNewReview(
    String storeId,
    String adId,
    double rating,
    String description,
    String reviewerId,
    String? replyTo,
  ) async {
    final docRef =
        fireStore
            .collection('stores')
            .doc(storeId)
            .collection('ads')
            .doc(adId)
            .collection('reviews')
            .doc();
    final dateTimeNow = Timestamp.now();

    if (replyTo != null) {
      await docRef.set({
        'id': docRef.id,
        'createdAt': dateTimeNow,
        'reviewerId': currentUser!.id,
        'rating': rating,
        'description': description,
        'replyTo': replyTo,
      });
    } else {
      await docRef.set({
        'id': docRef.id,
        'createdAt': dateTimeNow,
        'reviewerId': currentUser!.id,
        'rating': rating,
        'description': description,
      });
    }
    return Review(
      id: docRef.id,
      dateTime: dateTimeNow.toDate(),
      description: description,
      rating: rating,
      reviewerId: reviewerId,
      replyTo: replyTo,
    );
  }

  Future<void> changeOrderState(String orderId, OrderState state) async {
    try {
      final docRef = fireStore.collection('orders').doc(orderId);

      await docRef.update({'status': state.toDisplayString()});
    } catch (e) {
      print("Erro ao mudar o estado");
    }
  }

  Future<void> addToCart(ProductAd productAd, double quantity) async {
    final user = currentUser;
    if (user == null) return;

    final cartsRef = fireStore.collection('shoppingCarts');

    final query =
        await cartsRef.where('ownerId', isEqualTo: user.id).limit(1).get();

    DocumentReference? cartDocRef;
    Map<String, dynamic> cartData;

    if (query.docs.isEmpty) {
      cartDocRef = await cartsRef.add({
        'ownerId': user.id,
        'createdAt': FieldValue.serverTimestamp(),
        'productsQty': [
          {'productAdId': productAd.id, 'quantity': quantity},
        ],
      });
    } else {
      final doc = query.docs.first;
      cartDocRef = doc.reference;
      cartData = doc.data();

      final products = List<Map<String, dynamic>>.from(
        cartData['productsQty'] ?? [],
      );
      final index = products.indexWhere(
        (p) => p['productAdId'] == productAd.id,
      );

      if (index != -1) {
        products[index]['quantity'] += quantity;
      } else {
        products.add({'productAdId': productAd.id, 'quantity': quantity});
      }

      await cartDocRef.update({'productsQty': products});
    }
  }

  Future<void> removeStore(String storeId) async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    try {
      final storageRef = storage.ref().child('stores/$storeId');

      final ListResult listResult = await storageRef.listAll();

      for (var item in listResult.items) {
        await item.delete();
      }

      for (var prefix in listResult.prefixes) {
        final subList = await prefix.listAll();
        for (var subItem in subList.items) {
          await subItem.delete();
        }
      }

      final docRef = firestore.collection('stores').doc(storeId);
      await docRef.delete();
    } catch (e) {
      print('Erro ao remover a loja: $e');
      rethrow;
    }
  }

  Future<void> removeAd(String storeId, String adId) async {
    final fireStore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    try {
      final folderRef = storage.ref().child('stores/$storeId/ads/$adId/');
      final ListResult files = await folderRef.listAll();

      for (final file in files.items) {
        await file.delete();
      }

      final docRef = fireStore
          .collection('stores')
          .doc(storeId)
          .collection('ads')
          .doc(adId);

      await docRef.delete();
    } catch (e) {
      print("Erro ao remover anúncio e imagens: $e");
      rethrow;
    }
  }

  Future<void> addStoreVisit(String storeId, String userId) async {
    final docRef = fireStore.collection('stores').doc(storeId);

    await docRef.update({
      'viewsByUserDateTime': FieldValue.arrayUnion([
        {DateTime.now().toIso8601String(): userId},
      ]),
    });
  }

  Future<void> addAdVisit(String storeId, String adId, String userId) async {
    final docRef = fireStore
        .collection('stores')
        .doc(storeId)
        .collection('ads')
        .doc(adId);

    await docRef.update({
      'viewsByUserDateTime': FieldValue.arrayUnion([
        {DateTime.now().toIso8601String(): userId},
      ]),
    });
  }

  Future<List<String>> getUserFavorites(String userId) async {
    final doc = await fireStore.collection('users').doc(userId).get();
    final data = doc.data();
    if (data == null) return [];
    return List<String>.from(data['favorites'] ?? []);
  }

  Future<void> addToFavorites(String userId, String productAdId) async {
    final docRef = fireStore.collection('users').doc(userId);
    await docRef.update({
      'favorites': FieldValue.arrayUnion([productAdId]),
    });
  }

  Future<void> removeFromFavorites(String userId, String productAdId) async {
    final docRef = fireStore.collection('users').doc(userId);
    await docRef.update({
      'favorites': FieldValue.arrayRemove([productAdId]),
    });
  }

  Future<void> sendOffer(String discount, String adId) async {
    String? storeId;
    final storesSnapshot = await fireStore.collection('stores').get();
    for (final storeDoc in storesSnapshot.docs) {
      final adsSnapshot =
          await storeDoc.reference
              .collection('ads')
              .where('id', isEqualTo: adId)
              .limit(1)
              .get();
      if (adsSnapshot.docs.isNotEmpty) {
        storeId = storeDoc.id;
        break;
      }
    }

    if (storeId == null) {
      return;
    }

    final storeSnapshot =
        await fireStore.collection('stores').doc(storeId).get();
    if (!storeSnapshot.exists) {
      print('Store not found');
      return;
    }
    final storeCity = storeSnapshot.data()?['city'];

    final usersSnapshot =
        await fireStore
            .collection('users')
            .where('isProducer', isEqualTo: false)
            .where('city', isEqualTo: storeCity)
            .get();

    final now = DateTime.now();
    final startDate = now;
    final endDate = now.add(Duration(days: 20));

    final offerId = fireStore.collection('offers').doc().id;

    final offer = Offer(
      id: offerId,
      discountValue: DiscountValueExtension.fromString(discount),
      productAdId: adId,
      startDate: startDate,
      endDate: endDate,
      discountCode: offerId,
    );

    for (final userDoc in usersSnapshot.docs) {
      await fireStore
          .collection('users')
          .doc(userDoc.id)
          .collection('offers')
          .doc(offerId)
          .set({
            'id': offer.id,
            'discountValue': offer.discountValue.toJson(),
            'productAdId': offer.productAdId,
            'startDate': offer.startDate.toIso8601String(),
            'endDate': offer.endDate.toIso8601String(),
            'discountCode': offer.discountCode,
          });
    }
  }

  Stream<List<Offer>> getUserOffersStream(String userId) {
    return fireStore
        .collection('users')
        .doc(userId)
        .collection('offers')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Offer.fromJson(doc.data())).toList(),
        );
  }
}
