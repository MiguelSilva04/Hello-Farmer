import '../services/auth/store_service.dart';
import 'app_user.dart';
import 'basket.dart';
import 'store.dart';

class ProducerUser extends AppUser {
  final String? billingAddress;
  final List<Basket> baskets;

  ProducerUser({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.isProducer,
    required super.phone,
    required super.imageUrl,
    super.recoveryEmail,
    super.dateOfBirth,
    super.country,
    super.city,
    super.municipality,
    super.iban,
    super.taxpayerNumber,
    super.backgroundUrl,
    super.aboutMe,
    super.token,
    required this.baskets,
    this.billingAddress,
  });
  factory ProducerUser.fromMap(Map<String, dynamic> map) {
    return ProducerUser(
      id: map['id'] as String,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      aboutMe: map['aboutMe'] as String?,
      isProducer: map['isProducer'] as bool,
      phone: map['phone'] as String,
      imageUrl: map['imageUrl'] as String,
      recoveryEmail: map['recoveryEmail'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      baskets:
          (map['baskets'] as List<dynamic>?)
              ?.map((e) => Basket.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      billingAddress: map['billingAddress'] as String?,
      token: map['token'] as String?,
    );
  }

  factory ProducerUser.fromJson(Map<String, dynamic> json) {
    return ProducerUser(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      aboutMe: json['aboutMe'] as String?,
      country: json['country'] as String,
      city: json['city'] as String,
      municipality: json['municipality'] as String,
      isProducer: json['isProducer'] as bool,
      phone: json['phone'] as String,
      imageUrl: json['imageUrl'] as String,
      recoveryEmail: json['recoveryEmail'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      token: json['token'] as String?,
      baskets:
          (json['baskets'] as List<dynamic>?)
              ?.map((e) => Basket.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  ProducerUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    bool? isProducer,
    String? phone,
    String? gender,
    String? imageUrl,
    String? recoveryEmail,
    String? dateOfBirth,
    List<Basket>? baskets,
  }) {
    return ProducerUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isProducer: isProducer ?? this.isProducer,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      recoveryEmail: recoveryEmail ?? this.recoveryEmail,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      baskets: baskets ?? this.baskets,
    );
  }

  List<Store> get stores {
    return StoreService.instance.getStoresByOwner(id);
  }

  double get rating {
    if (stores.isEmpty) return 0.0;
    double sumRatings = stores.fold(0.0, (a, b) => a + b.averageRating);
    return double.parse((sumRatings / stores.length).toStringAsFixed(1));
  }
}
