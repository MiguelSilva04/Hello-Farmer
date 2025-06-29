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
  double averageRating = 0.0;

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
    required this.averageRating,
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

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      ownerId: json['ownerId'],
      createdAt:
          (json['createdAt'] is cf.Timestamp)
              ? (json['createdAt'] as cf.Timestamp).toDate()
              : json['createdAt'],
      name: json['name'] ?? '',
      slogan: json['subName'] ?? '',
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
      averageRating:
          json['averageRating'] != null
              ? (json['averageRating'] as double)
              : 0.0,
    );
  }
  factory Store.fromMap(Map<String, dynamic> map, String documentId) {
    return Store(
      id: documentId,
      ownerId: map['ownerId'],
      createdAt:
          map['createdAt'] is cf.Timestamp
              ? (map['createdAt'] as cf.Timestamp).toDate()
              : map['createdAt'],
      name: map['name'] ?? '',
      slogan: map['subName'] ?? '',
      description: map['description'] ?? '',
      city: map['city'] ?? '',
      address: map['address'] ?? '',
      municipality: map['municipality'],
      coordinates:
          map['coordinates'] != null
              ? LatLng(
                map['coordinates']['latitude'],
                map['coordinates']['longitude'],
              )
              : null,
      imageUrl: map['imageUrl'] ?? '',
      backgroundImageUrl: map['backgroundImageUrl'],
      productsAds:
          map['productsAds'] != null
              ? List<ProductAd>.from(
                map['productsAds'].map((x) => ProductAd.fromJson(x)),
              )
              : [],
      viewsByUserDateTime:
          map['viewsByUserDateTime'] != null
              ? (map['viewsByUserDateTime'] as List).map((item) {
                final key = DateTime.parse(item.keys.first);
                final value = item.values.first;
                return UserView(date: key, user: value);
              }).toList()
              : [],
      preferredDeliveryMethod:
          map['deliveryMethods'] != null
              ? (map['deliveryMethods'] as List)
                  .map((x) => DeliveryMethodExtension.fromString(x))
                  .toList()
              : [],
      notifications:
          map['notifications'] != null
              ? (map['notifications'] as List)
                  .map((x) => NotificationItem.fromJson(x))
                  .toList()
              : [],
      averageRating:
          map['averageRating'] != null
              ? (map['averageRating'] as double)
              : 0.0,
    );
  }
  Store copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? city,
    double? averageRating,
    List<ProductAd>? productsAds,
    // add other fields as needed
  }) {
    return Store(
      id: id ?? this.id,
      ownerId: this.ownerId,
      preferredDeliveryMethod: this.preferredDeliveryMethod,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      city: city ?? this.city,
      averageRating: averageRating ?? this.averageRating,
      productsAds: productsAds ?? this.productsAds,
      // add other fields as needed
    );
  }
}
