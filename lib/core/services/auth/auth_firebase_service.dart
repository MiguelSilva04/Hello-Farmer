import 'dart:io';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:harvestly/core/models/chat_user.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../models/store.dart';
import '../chat/chat_list_notifier.dart';

class AuthFirebaseService implements AuthService {
  static bool? _isLoggingIn;
  static bool? _isProducer;
  static ClientUser? _currentUser;
  static final List<ClientUser> _users = [];
  static StreamSubscription? _userChangesSubscription;
  static final _userStream = Stream<ClientUser?>.multi((controller) async {
    final authChanges = FirebaseAuth.instance.authStateChanges();
    await for (final user in authChanges) {
      _currentUser = user == null ? null : _toClientUser(user);
      controller.add(_currentUser);
    }
  });
  static Store? _myStore;

  AuthFirebaseService() {
    _listenToUserChanges();
  }

  void _listenToUserChanges() {
    _userChangesSubscription = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((snapshot) async {
          _users.clear();
          for (var doc in snapshot.docs) {
            _users.add(
              ClientUser(
                id: doc.id,
                firstName: doc['firstName'],
                lastName: doc['lastName'],
                email: doc['email'],
                gender: doc['gender'],
                phone: doc['phone'],
                recoveryEmail: doc['recoveryEmail'],
                imageUrl:
                    doc.data().containsKey('imageUrl') ? doc['imageUrl'] : '',
                backgroundUrl:
                    doc.data().containsKey('backgroundImageUrl')
                        ? doc['backgroundImageUrl']
                        : '',
                nickname:
                    doc.data().containsKey('nickname') ? doc['nickname'] : '',
                status: doc.data().containsKey('status') ? doc['status'] : '',
                iconStatus:
                    doc.data().containsKey('iconStatus')
                        ? doc['iconStatus']
                        : '',
                aboutMe:
                    doc.data().containsKey('aboutMe') ? doc['aboutMe'] : '',
                customIconStatus:
                    doc.data().containsKey('customIconStatus')
                        ? doc['customIconStatus']
                        : '',
                friendsIds:
                    doc.data().containsKey('friendsIds') &&
                            doc['friendsIds'] is List
                        ? List<String>.from(doc['friendsIds'])
                        : [],
                dateOfBirth: doc['dateOfBirth'],
                isProducer: doc['isProducer'],
              ),
            );
            if (_currentUser != null) {
              if (_currentUser!.id == doc.id) {
                _currentUser!.gender = doc['gender'];
                _currentUser!.phone = doc['phone'];
                _currentUser!.recoveryEmail = doc['recoveryEmail'];
                if (doc.data().containsKey('backgroundImageUrl') &&
                    doc['backgroundImageUrl'] != null)
                  _currentUser!.backgroundUrl = doc['backgroundImageUrl'];
                if (doc.data().containsKey('isProducer') &&
                    doc['isProducer'] != null)
                  _currentUser!.isProducer = doc['isProducer'];
                if (doc.data().containsKey('nickname') &&
                    doc['nickname'] != null)
                  _currentUser!.nickname = doc['nickname'];
                if (doc.data().containsKey('status') && doc['status'] != null)
                  _currentUser!.status = doc['status'];
                if (doc.data().containsKey('customStatus') &&
                    doc['customStatus'] != null)
                  _currentUser!.customStatus = doc['customStatus'];
                if (doc.data().containsKey('customIconStatus') &&
                    doc['customIconStatus'] != null)
                  _currentUser!.customIconStatus = doc['customIconStatus'];
                if (doc.data().containsKey('dateOfBirth') &&
                    doc['dateOfBirth'] != null)
                  _currentUser!.dateOfBirth = doc['dateOfBirth'];
                if (doc.data().containsKey('aboutMe') && doc['aboutMe'] != null)
                  _currentUser!.aboutMe = doc['aboutMe'];
                if (doc.data().containsKey('friendsIds') &&
                    doc['friendsIds'] != null)
                  _currentUser!.friendsIds = List<String>.from(
                    doc['friendsIds'],
                  );
              }
            }
          }
        });
  }

  @override
  List<ClientUser> get users => _users;

  @override
  bool get isLoggingIn => _isLoggingIn!;

  @override
  bool get isProducer => _isProducer!;

  @override
  Store getMyStore() => _myStore!;

  @override
  void setProducerState(bool state) => _isProducer = state;

  @override
  void setLoggingInState(bool state) => _isLoggingIn = state;

  @override
  ClientUser? get currentUser {
    return _currentUser;
  }

  @override
  Stream<ClientUser?> get userChanges {
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
      // 1. Upload da foto do usuário
      final imageName = '${credential.user!.uid}_profile.jpg';
      final imageUrl = await _uploadUserImage(image, imageName);

      // 2. Atualizar os atributos do usuário
      final fullName = '$firstName $lastName';
      await credential.user?.updateDisplayName(fullName);
      await credential.user?.updatePhotoURL(imageUrl);

      // 2.5 Fazer o login do usuário
      await login(email, password, "Normal");

      // 3. Salvar usuário na base de dados (opcional)
      _currentUser = _toClientUser(
        credential.user!,
        firstName,
        lastName,
        gender,
        phone,
        recoveryEmail,
        imageUrl,
        dateOfBirth,
        isProducer,
      );
      await _saveClientUser(_currentUser!);

      // 4. Salvar primeiro e último nome no Firestore
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
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Once signed in, return the UserCredential
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

    // ChatListNotifier().clearChats();

    await auth.signOut();
  }

  @override
  Future<void> recoverPassword(String email) async {
    final auth = FirebaseAuth.instance;
    auth.sendPasswordResetEmail(email: email);
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
    String? nickname,
    String? status,
    String? iconStatus,
    String? aboutMe,
    String? dateOfBirth,
    String? customStatus,
    String? customIconStatus,
    String? gender,
    String? recoveryEmail,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(user.uid);

    if (firstName != null) {
      await user.updateDisplayName("${firstName} ${lastName}");
      await docRef.update({'firstName': firstName});
      _currentUser!.firstName = firstName;
    }

    if (lastName != null) {
      await user.updateDisplayName("${firstName} ${lastName}");
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

    if (nickname != null) {
      await docRef.update({'nickname': nickname});
      _currentUser!.nickname = nickname;
    }
    if (status != null) {
      await docRef.update({'status': status});
      _currentUser!.status = status;
    }
    if (iconStatus != null) {
      await docRef.update({'iconStatus': iconStatus});
      _currentUser!.iconStatus = iconStatus;
    }
    if (aboutMe != null) {
      await docRef.update({'aboutMe': aboutMe});
      _currentUser!.aboutMe = aboutMe;
    }
    if (dateOfBirth != null) {
      await docRef.update({'dateOfBirth': dateOfBirth});
      _currentUser!.dateOfBirth = dateOfBirth;
    }
    if (customStatus != null) {
      await docRef.update({'customStatus': customStatus});
      _currentUser!.customStatus = customStatus;
    }
    if (customIconStatus != null) {
      await docRef.update({'customIconStatus': customIconStatus});
      _currentUser!.customIconStatus = customIconStatus;
    }
    if (gender != null) {
      await docRef.update({'gender': gender});
      _currentUser!.gender = gender;
    }
    if (recoveryEmail != null) {
      await docRef.update({'recoveryEmail': recoveryEmail});
      _currentUser!.recoveryEmail = recoveryEmail;
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

  Future<void> _saveClientUser(ClientUser user) async {
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
    });
  }

  static ClientUser _toClientUser(
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
    return ClientUser(
      id: user.uid,
      firstName:
          firstName ??
          user.displayName?.split(' ')[0] ??
          user.email!.split('@')[0],
      lastName:
          lastName ??
          (user.displayName!.split(' ').length > 1
              ? user.displayName?.split(' ')[1]
              : "") ??
          "",
      email: user.email!,
      gender: gender ?? '',
      phone: phone ?? '',
      recoveryEmail: recoveryEmail ?? '',
      // gender: gender != null ? gender : curUser.gender,
      // phone: phone != null ? phone : curUser.phone,
      // recoveryEmail: recoveryEmail != null ? recoveryEmail : curUser.recoveryEmail,
      imageUrl: imageUrl ?? user.photoURL ?? 'assets/images/avatar.png',
      dateOfBirth: dateOfBirth ?? '',
      isProducer: isProducer ?? false,
    );
  }

  @override
  Future<void> addFriend(String userId) {
    final store = FirebaseFirestore.instance;
    if (_currentUser == null) throw Exception("No current user selected.");
    final chatDoc = store.collection('users').doc(_currentUser!.id);
    return chatDoc.update({
      'friendsIds': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> removeFriend(String userId) {
    final store = FirebaseFirestore.instance;
    if (_currentUser == null) throw Exception("No current user selected.");
    final chatDoc = store.collection('users').doc(_currentUser!.id);
    return chatDoc.update({
      'friendsIds': FieldValue.arrayRemove([userId]),
    });
  }
}
