import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:harvestly/core/models/app_user.dart';
// import 'package:chat/core/services/auth/auth_mock_service.dart';

import '../../models/store.dart';
import 'auth_firebase_service.dart';

abstract class AuthService {
  AppUser? get currentUser;

  Future<AppUser?> getCurrentUser();

  List<AppUser> get users;

  bool get isLoggingIn;

  Store getMyStore();

  void setProducerState(bool state);

  void setLoggingInState(bool state);

  Stream<AppUser?> get userChanges;

  Future<void> addStore({
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
  });

  Future<void> publishAd(
    String title,
    String description,
    List<File> images,
    String category,
    int minQty,
    String unit,
    double price,
    int stock,
  );

  Future<void> signup(
    String firstName,
    String lastName,
    String email,
    String password,
    File? image,
    String gender,
    String phone,
    String recoverEmail,
    String dateOfBirth,
  );

  Future<void> login(String email, String password, String typeOfLogin);

  Future<void> logout();

  Future<void> recoverPassword(String email);

  Future<void> updateProfileImage(File? profileImage);

  Future<void> updateBackgroundImage(File? backgroundImage);

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
  });

  Future<void> syncEmailWithFirestore();

  Future<void> addFriend(String userId);
  Future<void> removeFriend(String userId);

  Future<AppUser?> initializeAndGetUser();

  factory AuthService() {
    // return AuthMockService();
    return AuthFirebaseService();
  }
}
