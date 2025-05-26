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
  AdVisibility? visibility = AdVisibility.PUBLIC;
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
  }) : description = description ?? "",
       price =
           price ??
           "${product.price!.toStringAsFixed(2)}€/${product.unit.toDisplayString()}" {
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
}
