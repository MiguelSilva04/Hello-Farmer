import 'package:harvestly/core/models/shopping_cart.dart';
import '../services/auth/auth_service.dart';
import 'app_user.dart';
import 'notification.dart';
import 'offer.dart';
import 'order.dart';
import 'producer_user.dart';

class ConsumerUser extends AppUser {
  List<Offer>? offers;
  ShoppingCart? shoppingCart;
  List<String>? favouritesProductsIds;
  List<NotificationItem>? notifications = [];
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
    this.notifications,
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
      token: map['token'] as String?,
      notifications: map['notifications'] as List<NotificationItem>?,
      orders: map['orders'] as List<Order>?,
    );
  }

  List<Order>? getOrders() {
    final producers = AuthService().users.whereType<ProducerUser>().toList();
    final ordersList =
        producers
            .where((p) => p.stores.isNotEmpty)
            .expand<Order>(
              (p) => p.stores.expand<Order>((store) => store.orders ?? []),
            )
            .where((order) => order.consumerId == id)
            .toList();

    return ordersList;
  }

  factory ConsumerUser.fromJson(Map<String, dynamic> json) {
    return ConsumerUser.fromMap(json);
  }
}
