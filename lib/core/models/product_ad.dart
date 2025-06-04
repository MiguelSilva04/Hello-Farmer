import 'package:harvestly/core/models/review.dart';
import 'package:harvestly/core/models/store.dart';

import 'product.dart';

enum AdVisibility { PUBLIC, PRIVATE }

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
  final Product product;
  String description = "";
  String price;
  String highlight = "Não está destacado";
  DateTime? highlightDate;
  HighlightType? highlightType;
  List<DeliveryMethod> preferredDeliveryMethods;
  List<Map<DateTime, String>>? viewsByUserDateTime;
  List<String>? keywords;
  AdVisibility? visibility = AdVisibility.PUBLIC;
  List<Review>? adReviews;
  ProductAd({
    required this.id,
    required this.product,
    required this.preferredDeliveryMethods,
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
           "${product.price!.toStringAsFixed(2)}€ | ${product.unit.toDisplayString()}" {
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

  static ProductAd fromJson(Map<String, dynamic> json) {
    return ProductAd(
      id: json['id'] ?? '',
      product: Product.fromJson(json['product']),
      preferredDeliveryMethods:
          (json['preferredDeliveryMethods'] as List<dynamic>?)
              ?.map(
                (e) => DeliveryMethod.values.firstWhere(
                  (dm) => dm.toString() == e,
                ),
              )
              .toList() ??
          [],
      description: json['description'],
      price: json['price']?.toString(),
      highlight: json['highlight'],
      highlightDate:
          json['highlightDate'] != null
              ? DateTime.parse(json['highlightDate'])
              : null,
      visibility:
          json['visibility'] != null
              ? AdVisibility.values.firstWhere(
                (v) => v.toString() == json['visibility'],
              )
              : null,
      highlightType:
          json['highlightType'] != null
              ? HighlightType.values.firstWhere(
                (h) => h.toString() == json['highlightType'],
              )
              : null,
      viewsByUserDateTime:
          json['viewsByUserDateTime'] != null
              ? (json['viewsByUserDateTime'] as List)
                  .map<Map<DateTime, String>>(
                    (item) => {DateTime.parse(item['date']): item['user']},
                  )
                  .toList()
              : null,
    );
  }
}
