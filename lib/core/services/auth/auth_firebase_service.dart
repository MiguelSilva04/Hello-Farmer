import 'dart:io';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../models/app_user.dart';
import '../../models/consumer_user.dart';
import '../../models/producer_user.dart';
import '../../models/store.dart';
import '../chat/chat_list_notifier.dart';

class AuthFirebaseService implements AuthService {
  static bool? _isLoggingIn;
  static bool? _isProducer;
  static AppUser? _currentUser;
  static final List<AppUser> _users = [];
  static StreamSubscription? _userChangesSubscription;
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
            _currentUser = ProducerUser.fromJson({
              ...data,
              'id': user.uid,
            });
          } else {
            _currentUser = ConsumerUser.fromJson({
              ...data,
              'id': user.uid,
            });
          }
        } else {
          _currentUser = _toAppUser(user);
        }

        controller.add(_currentUser);
      }
    }
  });

  static Store? _myStore;

  AuthFirebaseService() {
    listenToUserChanges();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    return await _userStream.firstWhere(
      (user) => user != null || FirebaseAuth.instance.currentUser == null,
    );
  }

  void listenToUserChanges() {
    _userChangesSubscription = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((snapshot) async {
          _users.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            if (data['isProducer'] == true) {
              _users.add(ProducerUser.fromJson({
                ...data,
                'id': doc.id,
              }));
            } else {
              _users.add(ConsumerUser.fromJson({
                ...data,
                'id': doc.id,
              }));
            }
            if (_currentUser != null && _currentUser!.id == doc.id) {
              // Atualiza campos mutáveis do usuário atual
              _currentUser!.firstName = data['firstName'];
              _currentUser!.lastName = data['lastName'];
              _currentUser!.gender = data['gender'];
              _currentUser!.phone = data['phone'];
              _currentUser!.recoveryEmail = data['recoveryEmail'];
              _currentUser!.imageUrl = data['imageUrl'];
              _currentUser!.backgroundUrl = data['backgroundImageUrl'];
              _currentUser!.dateOfBirth = data['dateOfBirth'];
              _currentUser!.aboutMe = data['aboutMe'];
              _currentUser!.isProducer = data['isProducer'];
            }
          }
        });
  }

  @override
  List<AppUser> get users => _users;

  @override
  bool get isLoggingIn => _isLoggingIn ?? false;

  @override
  Store getMyStore() => _myStore!;

  @override
  void setProducerState(bool state) => _isProducer = state;

  @override
  void setLoggingInState(bool state) => _isLoggingIn = state;

  @override
  AppUser? get currentUser {
    return _currentUser;
  }

  @override
  Stream<AppUser?> get userChanges {
    return _userStream;
  }

  @override
  Future<void> signup(
    String firstName,
    String lastName,
    String email,
    String password,
    File? image,
    String gender,
    String phone,
    String recoveryEmail,
    String dateOfBirth,
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
        gender,
        phone,
        recoveryEmail,
        imageUrl,
        dateOfBirth,
        _isProducer ?? false,
      );
      await _saveAppUser(_currentUser!);

      final store = FirebaseFirestore.instance;
      final docRef = store.collection('users').doc(credential.user!.uid);
      await docRef.update({'firstName': firstName, 'lastName': lastName});
    }

    await signup.delete();
  }

  @override
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

  @override
  Future<void> logout() async {
    if (_currentUser == null) return;

    await _userChangesSubscription?.cancel();
    _userChangesSubscription = null;

    final auth = FirebaseAuth.instance;

    _currentUser = null;
    _users.clear();

    await auth.signOut();
  }

  @override
  Future<void> recoverPassword(String email) async {
    final auth = FirebaseAuth.instance;
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateProfileImage(File? profileImage) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (profileImage != null) {
      final profileImageName = '${user.uid}_profile.jpg';
      final profileImageUrl = await _uploadUserImage(
        profileImage,
        profileImageName,
      );
      await user.updatePhotoURL(profileImageUrl);
      _currentUser!.imageUrl = profileImageUrl!;

      final store = FirebaseFirestore.instance;
      final docRef = store.collection('users').doc(user.uid);
      await docRef.update({'imageUrl': profileImageUrl});
    }
  }

  Future<void> updateBackgroundImage(File? backgroundImage) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (backgroundImage != null) {
      final backgroundImageName = '${user.uid}_background.jpg';
      final backgroundImageUrl = await _uploadUserImage(
        backgroundImage,
        backgroundImageName,
      );
      _currentUser!.backgroundUrl = backgroundImageUrl;

      final store = FirebaseFirestore.instance;
      final docRef = store.collection('users').doc(user.uid);
      await docRef.update({'backgroundImageUrl': backgroundImageUrl});
    }
  }

  Future<String?> _uploadUserImage(File? image, String imageName) async {
    if (image == null) return null;

    final storage = FirebaseStorage.instance;
    final imageRef = storage.ref().child('user_images').child(imageName);
    await imageRef.putFile(image);
    return await imageRef.getDownloadURL();
  }

  @override
  Future<void> updateSingleUserField({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? aboutMe,
    String? dateOfBirth,
    String? gender,
    String? recoveryEmail,
    String? customIconStatus,
    String? customStatus,
    String? iconStatus,
    String? nickname,
    String? status,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(user.uid);

    if (firstName != null) {
      await user.updateDisplayName("${firstName} ${lastName ?? _currentUser?.lastName ?? ''}");
      await docRef.update({'firstName': firstName});
      _currentUser!.firstName = firstName;
    }

    if (lastName != null) {
      await user.updateDisplayName("${firstName ?? _currentUser?.firstName ?? ''} ${lastName}");
      await docRef.update({'lastName': lastName});
      _currentUser!.lastName = lastName;
    }

    if (email != null) {
      await user.verifyBeforeUpdateEmail(email);
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
    if (gender != null) {
      await docRef.update({'gender': gender});
      _currentUser!.gender = gender;
    }
    if (recoveryEmail != null) {
      await docRef.update({'recoveryEmail': recoveryEmail});
      _currentUser!.recoveryEmail = recoveryEmail;
    }
    if (customIconStatus != null) {
      await docRef.update({'customIconStatus': customIconStatus});
      // Optionally update _currentUser if this field exists
    }
    if (customStatus != null) {
      await docRef.update({'customStatus': customStatus});
      // Optionally update _currentUser if this field exists
    }
    if (iconStatus != null) {
      await docRef.update({'iconStatus': iconStatus});
      // Optionally update _currentUser if this field exists
    }
    if (nickname != null) {
      await docRef.update({'nickname': nickname});
      // Optionally update _currentUser if this field exists
    }
    if (status != null) {
      await docRef.update({'status': status});
      // Optionally update _currentUser if this field exists
    }
  }

  @override
  Future<void> syncEmailWithFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final store = FirebaseFirestore.instance;
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
    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(user.id);

    return docRef.set({
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'gender': user.gender,
      'phone': user.phone,
      'recoveryEmail': user.recoveryEmail,
      'imageUrl': user.imageUrl,
      'dateOfBirth': user.dateOfBirth,
      'isProducer': user.isProducer,
      'aboutMe': user.aboutMe,
      'backgroundImageUrl': user.backgroundUrl,
    });
  }

  static AppUser _toAppUser(
    User user, [
    String? firstName,
    String? lastName,
    String? gender,
    String? phone,
    String? recoveryEmail,
    String? imageUrl,
    String? dateOfBirth,
    bool? isProducer,
  ]) {
    final bool producer = isProducer ?? false;
    if (producer) {
      return ProducerUser(
        id: user.uid,
        email: user.email!,
        firstName: firstName ?? user.displayName?.split(' ')[0] ?? user.email!.split('@')[0],
        lastName: lastName ?? (((user.displayName?.split(' ').length ?? 0) > 1) ? user.displayName?.split(' ')[1] : "") ?? "",
        isProducer: true,
        phone: phone ?? '',
        gender: gender ?? '',
        imageUrl: imageUrl ?? user.photoURL ?? 'assets/images/avatar.png',
        recoveryEmail: recoveryEmail ?? '',
        dateOfBirth: dateOfBirth ?? '',
        baskets: [],
      );
    } else {
      return ConsumerUser(
        id: user.uid,
        email: user.email!,
        firstName: firstName ?? user.displayName?.split(' ')[0] ?? user.email!.split('@')[0],
        lastName: lastName ?? ((user.displayName?.split(' ').length ?? 0) > 1 ? user.displayName?.split(' ')[1] : "") ?? "",
        isProducer: false,
        phone: phone ?? '',
        gender: gender ?? '',
        imageUrl: imageUrl ?? user.photoURL ?? 'assets/images/avatar.png',
        recoveryEmail: recoveryEmail ?? '',
        dateOfBirth: dateOfBirth ?? '',
      );
    }
  }

  @override
  Future<void> addFriend(String userId) async {
    // Não implementado pois não existe mais friendsIds na nova estrutura
    throw UnimplementedError('addFriend não faz parte da nova estrutura de AppUser');
  }

  @override
  Future<void> removeFriend(String userId) async {
    // Não implementado pois não existe mais friendsIds na nova estrutura
    throw UnimplementedError('removeFriend não faz parte da nova estrutura de AppUser');
  }
}
