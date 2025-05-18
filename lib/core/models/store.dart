import 'product_ad.dart';
import 'store_review.dart';

class Store {
  static int _idCounter = 0;
  final String id;
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

  Store({
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
  }) : id = (_idCounter++).toString();
}
