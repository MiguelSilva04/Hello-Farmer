import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'basket.dart';
import 'notification.dart';
import 'order.dart';
import 'product_ad.dart';
import 'review.dart';
import 'user_view.dart';

enum DeliveryMethod { HOME_DELIVERY, COURIER, PICKUP }

extension DeliveryMethodExtension on DeliveryMethod {
  String toDisplayString() {
    switch (this) {
      case DeliveryMethod.HOME_DELIVERY:
        return "Entrega ao Domicílio";
      case DeliveryMethod.COURIER:
        return "Transportadora";
      case DeliveryMethod.PICKUP:
        return "Recolha do Consumidor";
    }
  }

  IconData toIcon() {
    switch (this) {
      case DeliveryMethod.COURIER:
        return Icons.local_shipping;
      case DeliveryMethod.HOME_DELIVERY:
        return Icons.home;
      case DeliveryMethod.PICKUP:
        return Icons.store;
    }
  }

  static DeliveryMethod fromString(String value) {
    switch (value) {
      case "Entrega ao Domicílio":
        return DeliveryMethod.HOME_DELIVERY;
      case "Transportadora":
        return DeliveryMethod.COURIER;
      case "Recolha do Consumidor":
        return DeliveryMethod.PICKUP;
      default:
        return DeliveryMethod.HOME_DELIVERY;
    }
  }
}

class Store {
  final String id;
  final String ownerId;
  final DateTime? createdAt;
  String? backgroundImageUrl;
  String? imageUrl;
  String? name;
  String? slogan;
  String? description;
  String? city;
  String? address;
  String? municipality;
  LatLng? coordinates;
  List<ProductAd>? productsAds;
  List<Order>? orders;
  List<DeliveryMethod> preferredDeliveryMethod;
  List<Basket>? baskets;
  List<UserView>? viewsByUserDateTime;
  List<NotificationItem>? notifications = [];

  Store({
    required this.id,
    required this.ownerId,
    this.createdAt,
    this.backgroundImageUrl,
    this.imageUrl,
    this.name,
    this.slogan,
    this.description,
    this.city,
    this.municipality,
    this.address,
    this.coordinates,
    this.productsAds,
    this.orders,
    required this.preferredDeliveryMethod,
    this.baskets,
    this.viewsByUserDateTime,
    this.notifications,
  });

  void set setPreferredDeliveryMethod(
    List<DeliveryMethod> preferredDeliveryMethod,
  ) => this.preferredDeliveryMethod = preferredDeliveryMethod;

  List<Review>? get storeReviews {
    return productsAds
            ?.expand((ad) => ad.adReviews ?? [])
            .toList()
            .cast<Review>() ??
        null;
  }

  IconData deliveryIcon(DeliveryMethod method) {
    switch (method) {
      case DeliveryMethod.COURIER:
        return Icons.local_shipping;
      case DeliveryMethod.HOME_DELIVERY:
        return Icons.home;
      case DeliveryMethod.PICKUP:
        return Icons.storefront;
    }
  }

  double get averageRating {
    if (storeReviews == null || storeReviews!.isEmpty) return 0.0;
    final total = storeReviews!
        .where((r) => r.rating != null)
        .fold(0.0, (sum, r) => sum + r.rating!);
    final count = storeReviews!.where((r) => r.rating != null).length;
    return count == 0 ? 0.0 : total / count;
  }

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      ownerId: json['ownerId'],
      createdAt:
          (json['createdAt'] is cf.Timestamp)
              ? (json['createdAt'] as cf.Timestamp).toDate()
              : json['createdAt'],
      name: json['name'] ?? '',
      slogan: json['slogan'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      municipality: json['municipality'],
      coordinates:
          json['coordinates'] != null
              ? LatLng(
                json['coordinates']['latitude'],
                json['coordinates']['longitude'],
              )
              : null,

      imageUrl: json['imageUrl'] ?? '',
      backgroundImageUrl: json['backgroundImageUrl'],
      productsAds:
          json['productsAds'] != null
              ? List<ProductAd>.from(
                json['productsAds'].map((x) => ProductAd.fromJson(x)),
              )
              : [],
      viewsByUserDateTime:
          json['viewsByUserDateTime'] != null
              ? (json['viewsByUserDateTime'] as List).map((item) {
                final key = DateTime.parse(item.keys.first);
                final value = item.values.first;
                return UserView(date: key, user: value);
              }).toList()
              : [],
      preferredDeliveryMethod:
          json['deliveryMethods'] != null
              ? (json['deliveryMethods'] as List)
                  .map((x) => DeliveryMethodExtension.fromString(x))
                  .toList()
              : [],
      notifications:
          json['notifications'] != null
              ? (json['notifications'] as List)
                  .map((x) => NotificationItem.fromJson(x))
                  .toList()
              : [],
    );
  }
}
