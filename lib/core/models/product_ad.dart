import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:harvestly/core/models/review.dart';
import 'producer_user.dart';
import 'product.dart';
import 'store.dart';
import 'user_view.dart';

enum HighlightType { SEARCH, HOME }

extension HighlightTypeExtension on HighlightType {
  String toDisplayString() {
    switch (this) {
      case HighlightType.SEARCH:
        return "Destaque no topo da pesquisa";
      case HighlightType.HOME:
        return "Destaque na página principal";
    }
  }
}

class ProductAd {
  final String id;
  Product product;
  final DateTime createdAt;
  String description = "";
  String price;
  String highlight = "Não está destacado";
  DateTime? highlightDate;
  HighlightType? highlightType;
  List<UserView>? viewsByUserDateTime;
  List<String>? keywords;
  bool? visibility;
  List<Review>? adReviews;
  ProductAd({
    required this.id,
    required this.createdAt,
    required this.product,
    String? description,
    String? price,
    String? highlight,
    this.viewsByUserDateTime,
    this.highlightDate,
    this.visibility,
    this.highlightType,
    this.keywords,
    this.adReviews,
  }) : description = description ?? "",
       price =
           price ??
           "${product.price.toStringAsFixed(2)}€ | ${product.unit.toDisplayString()}" {
    if (highlightDate != null) {
      final now = DateTime.now();
      final diff = now.difference(highlightDate!);
      if (diff.inDays >= 1) {
        this.highlight = "Este anúncio está destacado há ${diff.inDays} dias";
      } else if (diff.inHours >= 1) {
        this.highlight = "Este anúncio está destacado há ${diff.inHours} horas";
      } else if (diff.inMinutes >= 1) {
        this.highlight =
            "Este anúncio está destacado há ${diff.inMinutes} minutos";
      } else {
        this.highlight =
            "Este anúncio está destacado há ${diff.inSeconds} segundos";
      }
    } else if (highlight != null) {
      this.highlight = highlight;
    } else {
      this.highlight = "Não está destacado";
    }
  }

  List<DeliveryMethod> preferredDeliveryMethods(List<ProducerUser> users) {
    final user = users.firstWhere(
      (u) => u.stores.any((s) => s.productsAds!.any((ad) => ad.id == id)),
    );

    final store = user.stores.firstWhere(
      (s) => s.productsAds!.any((ad) => ad.id == id),
    );

    return store.preferredDeliveryMethod;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': cf.Timestamp.fromDate(createdAt),
      'product': {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'unit': product.unit.toDisplayString(),
        'stock': product.stock,
        'minAmount': product.minAmount,
        'category': product.category,
        'season': product.season.toDisplayString(),
        'imageUrls': product.imageUrls,
      },
      'description': description,
      'price': price,
      'highlight': highlight,
      'highlightDate':
          highlightDate != null ? cf.Timestamp.fromDate(highlightDate!) : null,
      'highlightType': highlightType?.toString(),
      'visibility': visibility,
      'keywords': keywords,
      'viewsByUserDateTime':
          viewsByUserDateTime?.map((v) => v.toJson()).toList(),
      'adReviews': adReviews ?? [],
    };
  }

  static ProductAd fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    return ProductAd(
      id: json['id'] ?? '',
      createdAt:
          (json['createdAt'] is cf.Timestamp)
              ? (json['createdAt'] as cf.Timestamp).toDate()
              : json['createdAt'],
      product: Product(
        name: json['title'] ?? '',
        imageUrls:
            json['imageUrls'] != null
                ? List<String>.from(json['imageUrls'])
                : [],
        category: json['category'] ?? '',
        stock: (json['stock'] ?? 0).toInt(),
        price: (json['price'] ?? 0).toDouble(),
        minAmount: (json['minQty'] ?? 0).toInt(),
        unit: Unit.values.firstWhere(
          (u) =>
              u.toDisplayString().toLowerCase() ==
              (json['unit'] ?? '').toString().toLowerCase(),
          orElse: () => Unit.KG,
        ),
        season: _determineSeason(now),
      ),
      description: json['description'],
      price: json['price']?.toString(),
      highlight: json['highlight'],
      highlightDate:
          json['highlightDate'] is cf.Timestamp
              ? (json['highlightDate'] as cf.Timestamp).toDate()
              : DateTime.tryParse(json['highlightDate']?.toString() ?? ''),
      visibility: json['visibility'] ?? true,
      highlightType:
          json['highlightType'] != null
              ? HighlightType.values.firstWhere(
                (h) => h.toString() == json['highlightType'],
              )
              : null,
      viewsByUserDateTime:
          json['viewsByUserDateTime'] != null
              ? (json['viewsByUserDateTime'] as List)
                  .map((item) => UserView.fromJson(item))
                  .toList()
              : null,
      keywords:
          json['keywords'] != null ? List<String>.from(json['keywords']) : null,
      adReviews: json['adReviews'] ?? [],
    );
  }

  static Season _determineSeason(DateTime now) {
    final month = now.month;
    if ([3, 4, 5].contains(month)) return Season.SPRING;
    if ([6, 7, 8].contains(month)) return Season.SUMMER;
    if ([9, 10, 11].contains(month)) return Season.AUTUMN;
    if ([12, 1, 2].contains(month)) return Season.WINTER;
    return Season.ALL;
  }

  @override
  String toString() {
    return '''
      id: $id,
      createdAt: $createdAt,
      product: {
        id: ${product.id},
        name: ${product.name},
        price: ${product.price.toStringAsFixed(2)}€,
        unit: ${product.unit.toDisplayString()},
        stock: ${product.stock},
        minAmount: ${product.minAmount},
        category: ${product.category},
        season: ${product.season.toDisplayString()},
        imageUrls: ${product.imageUrls.join(', ')}
      },
      description: $description,
      price: $price,
      highlight: $highlight,
      highlightDate: $highlightDate,
      highlightType: ${highlightType?.toDisplayString() ?? "Nenhum"},
      visibility: ${visibility.toString().split('.').last}
    ''';
  }
}
