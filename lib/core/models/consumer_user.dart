import 'app_user.dart';

class ConsumerUser extends AppUser {
  ConsumerUser({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.isProducer,
    required super.phone,
    required super.gender,
    required super.imageUrl,
    super.recoveryEmail,
    super.dateOfBirth,
  });

  factory ConsumerUser.fromMap(Map<String, dynamic> map) {
    return ConsumerUser(
      id: map['id'] as String,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      isProducer: map['isProducer'] as bool,
      phone: map['phone'] as String,
      gender: map['gender'] as String,
      imageUrl: map['imageUrl'] as String,
      recoveryEmail: map['recoveryEmail'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
    );
  }

  factory ConsumerUser.fromJson(Map<String, dynamic> json) {
    return ConsumerUser.fromMap(json);
  }
}
