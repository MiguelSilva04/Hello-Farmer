import 'package:harvestly/core/models/notification.dart';

abstract class AppUser {
  final String id;
  final String email;
  String firstName;
  String lastName;
  String? aboutMe;
  String phone;
  String imageUrl;
  String? country;
  String? city;
  String? municipality;
  final int? taxpayerNumber;
  String? backgroundUrl;
  String? recoveryEmail;
  String? dateOfBirth;
  bool isProducer;
  String? iban;
  List<NotificationItem>? notifications = null;

  AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.imageUrl,
    this.aboutMe,
    this.backgroundUrl,
    this.recoveryEmail,
    this.dateOfBirth,
    required this.isProducer,
    this.taxpayerNumber,
    this.iban,
    this.country,
    this.municipality,
    this.city,
  });

  @override
  String toString() {
    return 'AppUser(id: $id, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, recoveryEmail: $recoveryEmail, dateOfBirth: $dateOfBirth, imageUrl: $imageUrl, backgroundUrl: $backgroundUrl, isProducer: $isProducer)';
  }
}
