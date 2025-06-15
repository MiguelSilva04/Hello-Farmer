// import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/models/shopping_cart.dart';

import 'app_user.dart';
import 'offer.dart';
import 'order.dart';

class ConsumerUser extends AppUser {
  List<Offer>? offers;
  ShoppingCart? shoppingCart;
  List<String>? favouritesProductsIds;
  List<Order>? orders;

  ConsumerUser({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.isProducer,
    required super.phone,
    required super.imageUrl,
    required super.country,
    required super.city,
    required super.municipality,
    super.recoveryEmail,
    super.dateOfBirth,
    super.token,
    this.offers,
    this.shoppingCart,
    this.orders,
  });

  factory ConsumerUser.fromMap(Map<String, dynamic> map) {
    return ConsumerUser(
      id: map['id'] as String,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      country: map['country'] as String,
      city: map['city'] as String,
      municipality: map['municipality'] as String,
      isProducer: map['isProducer'] as bool,
      phone: map['phone'] as String,
      imageUrl: map['imageUrl'] as String,
      recoveryEmail: map['recoveryEmail'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      offers: map['offers'] as List<Offer>?,
      shoppingCart: map['shoppingCart'] as ShoppingCart?,
      orders: map['orders'] as List<Order>?,
      token: map['token'] as String?,
    );
  }

  factory ConsumerUser.fromJson(Map<String, dynamic> json) {
    return ConsumerUser.fromMap(json);
  }
}
