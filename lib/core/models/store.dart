import 'package:harvestly/core/models/notification.dart';

import 'basket.dart';
import 'order.dart';
import 'product_ad.dart';
import 'store_review.dart';

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
}

class Store {
  static int _idCounter = 0;
  final String id;
  final DateTime createdAt;
  String? backgroundImageUrl;
  String? imageUrl;
  String? name;
  String? subName;
  String? description;
  String? location;
  String? address;
  List<String>? preferredMarkets;
  List<ProductAd>? productsAds;
  List<StoreReview>? storeReviews;
  List<Order>? orders;
  List<DeliveryMethod>? preferredDeliveryMethod;
  List<Basket>? baskets;
  List<Map<DateTime, String>>? viewsByUserDateTime;

  Store({
    required this.createdAt,
    this.backgroundImageUrl,
    this.imageUrl,
    this.name,
    this.subName,
    this.description,
    this.location,
    this.address,
    this.preferredMarkets,
    this.productsAds,
    this.storeReviews,
    this.orders,
    this.preferredDeliveryMethod,
    this.baskets,
    this.viewsByUserDateTime,
  }) : id = (_idCounter++).toString();

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      name: json['name'] ?? '',
      subName: json['subName'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      backgroundImageUrl: json['backgroundImageUrl'],
      preferredMarkets:
          json['preferredMarkets'] != null
              ? List<String>.from(json['preferredMarkets'])
              : [],
      productsAds:
          json['productsAds'] != null
              ? List<ProductAd>.from(
                json['productsAds'].map((x) => ProductAd.fromJson(x)),
              )
              : [],
      storeReviews:
          json['storeReviews'] != null
              ? List<StoreReview>.from(
                json['storeReviews'].map((x) => StoreReview.fromJson(x)),
              )
              : [],
      viewsByUserDateTime:
          json['viewsByUserDateTime'] != null
              ? List<Map<DateTime, String>>.from(
                (json['viewsByUserDateTime'] as List).map((item) {
                  final key = DateTime.parse(item.keys.first);
                  final value = item.values.first;
                  return {key: value};
                }),
              )
              : [],
      preferredDeliveryMethod:
          json['preferredDeliveryMethod'] != null
              ? List<DeliveryMethod>.from(
                (json['preferredDeliveryMethod'] as List).map(
                  (x) => DeliveryMethod.values.firstWhere(
                    (e) => e.toString() == 'DeliveryMethod.$x',
                    orElse: () => DeliveryMethod.HOME_DELIVERY,
                  ),
                ),
              )
              : [],
    );
  }
}
